---
name: git-sync-branch
description: Rebase current branch onto latest main/master.
allowed-tools:
  - Bash(git branch *)
  - Bash(git fetch origin main)
  - Bash(git fetch origin master)
  - Bash(git rebase origin/main)
  - Bash(git rebase origin/master)
  - Bash(git rebase --abort)
---

1. Detect default branch: `git branch --list main master` (main 우선). `git remote show origin` 사용 금지.
2. `git fetch origin <branch>` → `git rebase origin/<branch>`
3. Conflict 발생 시 `git rebase --abort` 후 유저에게 보고. 자동 resolve 금지.
4. Report result.
