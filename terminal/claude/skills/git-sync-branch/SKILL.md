---
name: git-sync-branch
description: Rebase the current branch onto the latest master/main. Use when you need to sync your feature branch with the latest default branch changes.
---

Sync the current feature branch by rebasing it onto the latest default branch.

## Steps

1. Detect the default branch name (master or main) by checking `git remote show origin` or existing local branches.
2. Run `git fetch origin <default-branch>` to fetch the latest changes from remote.
3. Run `git rebase origin/<default-branch>` to rebase the current branch onto the latest default branch.
4. If a rebase conflict occurs, abort the rebase with `git rebase --abort` and report the conflict to the user. Do NOT attempt to resolve conflicts automatically.
5. Report the result to the user.
