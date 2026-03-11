---
name: git-checkout
description: List local git branches and checkout a selected one. Use when the user wants to switch branches.
---

Help the user switch to a different local git branch.

## Parameters

- Optional: a keyword or partial branch name to filter/match branches.

## Steps

1. Run `git branch --sort=-committerdate` to list all local branches sorted by recent activity.
2. If a parameter is provided, filter branches by fuzzy matching against the keyword (partial match, case-insensitive). Show only the matching branches.
3. If no parameter is provided, show all branches.
4. Present the branches to the user in a numbered list.
5. If there is exactly one match, confirm with the user and checkout that branch.
6. If there are multiple matches, ask the user which branch they want to checkout by number or name.
7. Run `git checkout <selected-branch>` to switch to the chosen branch.
8. Report the result to the user.
