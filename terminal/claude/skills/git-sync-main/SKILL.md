---
name: git-sync-main
description: Checkout master/main branch, pull latest changes, and prune stale remote references. Use when switching back to the default branch to start fresh.
---

Sync the current git repository to the latest state of the default branch.

## Steps

1. Detect the default branch name (master or main) by checking `git remote show origin` or existing local branches.
2. Run `git checkout <default-branch>` to switch to the default branch.
3. Run `git pull` to fetch and merge the latest changes.
4. Run `git fetch --prune` to clean up stale remote-tracking references.
5. Report the result to the user.
