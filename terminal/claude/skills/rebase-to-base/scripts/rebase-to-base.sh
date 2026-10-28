#!/usr/bin/env bash
# Rebase the current branch onto the latest base and record each conflicted file as it stood
# with markers, so the resolution can later be shown as a conflicted -> resolved diff.
#
# Usage:
#   rebase-to-base.sh start [base]   fetch + rebase onto origin/<base>; exit 2 on conflict
#   rebase-to-base.sh diff           unified diff of every recorded conflict vs its resolution
#   rebase-to-base.sh continue       stage resolved files and continue; exit 2 on a new conflict
#   rebase-to-base.sh abort          abort the rebase and drop the recorded state
#   rebase-to-base.sh push           force-push the branch with --force-with-lease
set -euo pipefail

STATE_DIR="$(git rev-parse --path-format=absolute --git-path rebase-to-base)"

die() { echo "error: $*" >&2; exit 1; }

resolve_base() {
	if [[ -n "${1:-}" ]]; then
		echo "$1"
		return
	fi
	local head
	if head="$(git symbolic-ref --quiet --short refs/remotes/origin/HEAD 2>/dev/null)"; then
		echo "${head#origin/}"
		return
	fi
	for b in main master; do
		if git show-ref --verify --quiet "refs/remotes/origin/$b"; then
			echo "$b"
			return
		fi
	done
	die "cannot resolve base branch; pass it explicitly"
}

# Snapshots are keyed by rebase step so a file that conflicts in two commits keeps both versions.
snapshot_conflicts() {
	local step files
	step="$(cat "$(git rev-parse --git-path rebase-merge/msgnum)" 2>/dev/null || echo 0)"
	files="$(git diff --name-only --diff-filter=U)"
	[[ -z "$files" ]] && return 1
	while IFS= read -r f; do
		mkdir -p "$STATE_DIR/snapshots/$step/$(dirname "$f")"
		cp "$f" "$STATE_DIR/snapshots/$step/$f"
	done <<< "$files"
	echo "CONFLICT at step $step ($(git log -1 --format='%h %s' REBASE_HEAD 2>/dev/null || true)):"
	sed 's/^/  /' <<< "$files"
	return 0
}

after_rebase_step() {
	if git rev-parse --verify --quiet REBASE_HEAD >/dev/null && snapshot_conflicts; then
		echo "Resolve the files above, then run: rebase-to-base.sh continue"
		exit 2
	fi
	if [[ -d "$(git rev-parse --git-path rebase-merge)" ]]; then
		die "rebase stopped without a file conflict; inspect with git status"
	fi
	echo "REBASED $(cat "$STATE_DIR/old_sha" | cut -c1-8) -> $(git rev-parse --short=8 HEAD) onto origin/$(cat "$STATE_DIR/base")"
}

cmd_start() {
	[[ -z "$(git status --porcelain --untracked-files=no)" ]] || die "working tree has uncommitted changes"
	local base branch
	base="$(resolve_base "${1:-}")"
	branch="$(git branch --show-current)"
	[[ -n "$branch" ]] || die "detached HEAD"
	[[ "$branch" != "$base" ]] || die "already on base branch $base"

	git fetch origin --prune --quiet
	rm -rf "$STATE_DIR"
	mkdir -p "$STATE_DIR"
	git rev-parse HEAD > "$STATE_DIR/old_sha"
	echo "$base" > "$STATE_DIR/base"
	echo "$branch" > "$STATE_DIR/branch"

	if git merge-base --is-ancestor "origin/$base" HEAD; then
		echo "UP_TO_DATE $branch already contains origin/$base"
		exit 0
	fi
	git rebase "origin/$base" >/dev/null 2>&1 || true
	after_rebase_step
}

cmd_diff() {
	[[ -d "$STATE_DIR/snapshots" ]] || { echo "no recorded conflicts"; return; }
	local step f
	for step in $(ls "$STATE_DIR/snapshots" | sort -n); do
		while IFS= read -r f; do
			f="${f#./}"
			diff -u \
				--label "a/$f (conflicted, step $step)" \
				--label "b/$f (resolved)" \
				"$STATE_DIR/snapshots/$step/$f" "$f" || true
		done < <(cd "$STATE_DIR/snapshots/$step" && find . -type f | sort)
	done
}

cmd_continue() {
	[[ -f "$STATE_DIR/old_sha" ]] || die "no rebase started by this script; run start first"
	local step f
	step="$(cat "$(git rev-parse --git-path rebase-merge/msgnum)" 2>/dev/null || echo 0)"
	if [[ -d "$STATE_DIR/snapshots/$step" ]]; then
		while IFS= read -r f; do
			f="${f#./}"
			if grep -qE '^(<<<<<<<|=======$|>>>>>>>)' "$f"; then
				die "conflict markers remain in $f"
			fi
			git add -- "$f"
		done < <(cd "$STATE_DIR/snapshots/$step" && find . -type f)
	fi
	GIT_EDITOR=true git rebase --continue >/dev/null 2>&1 || true
	after_rebase_step
}

cmd_abort() {
	git rebase --abort 2>/dev/null || true
	rm -rf "$STATE_DIR"
	echo "ABORTED at $(git rev-parse --short=8 HEAD)"
}

cmd_push() {
	[[ -d "$(git rev-parse --git-path rebase-merge)" ]] && die "rebase still in progress"
	local branch
	branch="$(git branch --show-current)"
	git push --force-with-lease origin "$branch"
}

case "${1:-}" in
	start) shift; cmd_start "$@" ;;
	diff) cmd_diff ;;
	continue) cmd_continue ;;
	abort) cmd_abort ;;
	push) cmd_push ;;
	*) sed -n '2,10p' "$0"; exit 1 ;;
esac
