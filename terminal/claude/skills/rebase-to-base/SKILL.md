---
name: rebase-to-base
description: >
  Rebase the current branch onto the latest base branch (origin/HEAD, main, or master, or one the
  user names) with a script, resolve any conflicts, and show the resolution as a unified git diff
  of each conflicted file (with markers) against its resolved version, then optionally force-push
  with --force-with-lease. Triggers on phrases like "최신 master로 rebase", "rebase 하고 force push",
  "base로 rebase 해줘", "conflict 해결한거 diff로 보여줘", "rebase onto latest main",
  "rebase and force push", "rebase-to-base".
argument-hint: "[base-branch] [--push]"
---

# Rebase To Base

The rebase itself is mechanical, so `scripts/rebase-to-base.sh` does it. Your job is to resolve the
conflicts it stops on and to show how you resolved them.

## Fixed facts (do not ask the user)

- Script: `~/.claude/skills/rebase-to-base/scripts/rebase-to-base.sh` (run it from the repo or
  worktree that has the branch checked out).
- The base defaults to `origin/HEAD`, then `main`, then `master`. Pass a base only if the user
  named one.
- The script records each conflicted file *with markers* under `$(git rev-parse --git-path
  rebase-to-base)` at the moment the conflict happens. `diff` compares those snapshots with the
  working tree, so the output stays correct even after an IDE auto-stages the files.
- The force-push is always `--force-with-lease`, never bare `--force`.

Collect per run: the base (only if the user named one) and whether to push. "force push" in the
request counts as permission to push.

## Steps

1. Start the rebase:
   ```bash
   bash ~/.claude/skills/rebase-to-base/scripts/rebase-to-base.sh start {base?}
   ```
   - `UP_TO_DATE`: report it and stop. Skip the push.
   - `REBASED old -> new`: there were no conflicts. Go to step 4.
   - exit 2 with `CONFLICT at step N`: go to step 2.
   - The script refuses to run with a dirty working tree. If it does, report that. Never stash on
     the user's behalf.

2. Resolve every listed file:
   - Read the conflicted file and read the commit on each side (`git log -1 -p REBASE_HEAD --
     {file}` and the base's commits touching it), so you resolve by intent rather than by picking
     a side.
   - Keep both sides when they add independent things. When a signature changed on the base, carry
     the new shape into this branch's lines.
   - A hunk often ends before a closing `}` that both sides share. Restore that brace and the
     separator, such as a blank line or `@Test`, between the two kept blocks.
   - If the intent is ambiguous (both sides change the same logic differently), stop and ask. Do
     not guess.

   Then compile and run the tests that touch the conflicted files, using the project's build tool.
   Do this before continuing.

3. Show the resolution, then continue:
   ```bash
   bash ~/.claude/skills/rebase-to-base/scripts/rebase-to-base.sh diff
   bash ~/.claude/skills/rebase-to-base/scripts/rebase-to-base.sh continue
   ```
   Paste the full `diff` output to the user in a ```diff block. `-` lines are the markers and
   dropped text, and `+` lines are what you added. If `continue` exits 2 again, a later commit
   conflicted: repeat steps 2–3. `diff` prints every recorded step.

4. Push, only when the user asked:
   ```bash
   bash ~/.claude/skills/rebase-to-base/scripts/rebase-to-base.sh push
   ```
   If the lease is rejected, the remote moved. Report it and do not retry with `--force`.

To give up at any point, run `rebase-to-base.sh abort`. It restores the original commit.

## Output

Reply in Korean with:
- old → new SHA, and the base it was rebased onto
- the commit on the base that caused each conflict, plus a one-line rule for each file's
  resolution (e.g. "양쪽 메서드 모두 유지")
- the full resolution diff in a ```diff block
- which compile/tests ran and their result
- the push result, or that no push was done
