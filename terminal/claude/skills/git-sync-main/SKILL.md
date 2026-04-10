---
name: git-sync-main
description: Checkout main/master, pull latest, prune stale remotes.
allowed-tools:
  - Bash(git branch *)
  - Bash(git checkout main)
  - Bash(git checkout master)
  - Bash(git pull)
  - Bash(git fetch --prune)
---

1. Detect default branch: `git branch --list main master` (main 우선). `git remote show origin` 사용 금지.
2. `git checkout <branch>` → `git pull` → `git fetch --prune`
3. Report result.
