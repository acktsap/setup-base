#!/bin/sh

set -eu

ORCA=${ORCA_BIN:-/usr/local/bin/orca}

MODE=pr
EXPLICIT_URL=
SELECTOR_OVERRIDE=

SELECTOR=
URL=
URL_KIND=
WORKTREE_BRANCH=
WORKTREE_PATH=

die() {
  printf '%s\n' "$*" >&2
  exit 1
}

usage() {
  cat <<'EOF'
usage: orca-ide-open-browser [--repo | --pr | URL] [--worktree SELECTOR]

Open a URL in the Orca IDE's built-in browser, in the browser window belonging
to the current working directory's worktree, and focus it.

positional arguments:
  URL               Open this URL unchanged.

options:
  --pr              Open the current branch's PR. On the default branch, opens
                    the repository instead. This is the default.
  --repo            Open the repository page.
  --worktree SEL    Target another Orca window by selector (e.g. path:/repo/root
                    for the main workspace). Default: the cwd's own worktree.
  -h, --help        Show this help.

Each git worktree owns a separate browser window, so the default target is the
cwd's worktree rather than the main workspace.

Exit status is 3 when the tab was created but landed in the wrong window.
EOF
}

# jq is the only hard dependency beyond orca/gh; fail loudly rather than
# silently producing empty selectors.
require_jq() {
  command -v jq >/dev/null 2>&1 || die "jq not found in PATH"
}

json_get() {
  filter="${1:?filter is required}"
  json="${2?json is required}"
  printf '%s' "$json" | jq -r "$filter // empty"
}

parse_args() {
  while [ $# -gt 0 ]; do
    case $1 in
      --pr)
        MODE=pr
        ;;
      --repo)
        MODE=repo
        ;;
      --worktree)
        [ $# -ge 2 ] || die "--worktree requires a selector"
        SELECTOR_OVERRIDE=$2
        shift
        ;;
      -h|--help)
        usage
        exit 0
        ;;
      http://*|https://*)
        MODE=url
        EXPLICIT_URL=$1
        ;;
      -*)
        die "unknown option: $1"
        ;;
      *)
        die "unrecognized argument: $1 (a URL must start with http:// or https://)"
        ;;
    esac
    shift
  done
}

# The `current`/`active` selector has placed tabs in the wrong window, so the
# worktree is always resolved to an explicit id: before anything else runs.
resolve_worktree() {
  if [ -n "$SELECTOR_OVERRIDE" ]; then
    SELECTOR=$SELECTOR_OVERRIDE
    return
  fi

  worktree_json=$($ORCA worktree current --json) ||
    die "orca worktree current failed; is the Orca daemon running?"

  [ "$(json_get '.ok' "$worktree_json")" = true ] ||
    die "orca worktree current returned an error: $worktree_json"

  worktree_id=$(json_get '.result.worktree.id' "$worktree_json")
  WORKTREE_BRANCH=$(json_get '.result.worktree.branch' "$worktree_json")
  WORKTREE_PATH=$(json_get '.result.worktree.path' "$worktree_json")

  if [ -n "$worktree_id" ]; then
    SELECTOR="id:$worktree_id"
  elif [ -n "$WORKTREE_BRANCH" ]; then
    # Orca reports branches as refs/heads/<name> but matches its selectors
    # against the short name it displays.
    SELECTOR="branch:${WORKTREE_BRANCH#refs/heads/}"
  else
    die "could not resolve a worktree id or branch from: $worktree_json"
  fi
}

resolve_url() {
  case $MODE in
    url)
      URL=$EXPLICIT_URL
      URL_KIND="url"
      ;;
    repo)
      URL=$(gh repo view --json url -q .url) || die "gh repo view failed"
      URL_KIND="repository"
      ;;
    pr)
      repo_json=$(gh repo view --json url,defaultBranchRef) || die "gh repo view failed"
      repo_url=$(json_get '.url' "$repo_json")
      default_branch=$(json_get '.defaultBranchRef.name' "$repo_json")
      branch=${WORKTREE_BRANCH#refs/heads/}

      if [ -z "$branch" ] || [ "$branch" = "$default_branch" ]; then
        URL=$repo_url
        URL_KIND="repository (on default branch $default_branch)"
      else
        URL=$(gh pr view --json url -q .url) ||
          die "no pull request found for branch $branch"
        URL_KIND="pull request"
      fi
      ;;
  esac

  [ -n "$URL" ] || die "resolved an empty URL"
}

open_tab() {
  create_json=$($ORCA tab create --url "$URL" --worktree "$SELECTOR" --json) ||
    die "orca tab create failed for selector $SELECTOR"

  # The page id lives at result.browserPageId; the top-level id is the request id.
  PAGE_ID=$(json_get '.result.browserPageId' "$create_json")
  [ -n "$PAGE_ID" ] || die "orca tab create returned no browserPageId: $create_json"

  # tab create only opens in the background.
  $ORCA tab switch --page "$PAGE_ID" --worktree "$SELECTOR" --focus >/dev/null ||
    die "orca tab switch failed for page $PAGE_ID"
}

verify_placement() {
  current_json=$($ORCA tab current --worktree "$SELECTOR" --json) ||
    die "orca tab current failed for selector $SELECTOR"

  current_page=$(json_get '.result.tab.browserPageId' "$current_json")
  current_worktree=$(json_get '.result.tab.worktreeId' "$current_json")
  title=$(json_get '.result.tab.title' "$current_json")

  if [ "$current_page" != "$PAGE_ID" ]; then
    printf 'tab landed in the wrong window (expected page %s, active page %s)\n' \
      "$PAGE_ID" "${current_page:-none}" >&2
    printf 'raw: %s\n' "$current_json" >&2
    exit 3
  fi

  printf 'opened %s\n' "$URL_KIND"
  printf '  url:      %s\n' "$URL"
  printf '  page:     %s\n' "$PAGE_ID"
  printf '  worktree: %s\n' "${current_worktree:-$SELECTOR}"
  [ -z "$WORKTREE_PATH" ] || printf '  path:     %s\n' "$WORKTREE_PATH"
  [ -z "$title" ] || printf '  title:    %s\n' "$title"
}

main() {
  require_jq
  parse_args "$@"
  resolve_worktree
  resolve_url
  open_tab
  verify_placement
}

main "$@"
