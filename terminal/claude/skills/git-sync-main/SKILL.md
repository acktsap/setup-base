---
name: git-sync-main
description: Checkout master/main branch, pull latest changes, and prune stale remote references. Use when switching back to the default branch to start fresh.
allowed-tools:
  - Bash(git branch *)
  - Bash(git checkout main)
  - Bash(git checkout master)
  - Bash(git pull)
  - Bash(git fetch --prune)
---

Sync the current git repository to the latest state of the default branch.

## Steps

1. Detect the default branch by running `git branch --list main master`. Use `main` if it exists, otherwise `master`. Never rely on `git remote show origin` as the remote HEAD may point to a non-default branch.
2. Run `git checkout <default-branch>` to switch to the default branch.
3. Run `git pull` to fetch and merge the latest changes.
4. Run `git fetch --prune` to clean up stale remote-tracking references.
5. Report the result to the user.
