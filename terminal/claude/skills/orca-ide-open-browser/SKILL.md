---
name: orca-ide-open-browser
description: Open a URL in the Orca IDE's built-in browser tab. Triggers on "orca 브라우저로 열어줘", "orca ide 내장 브라우저", "open in orca browser", "orca-ide-open-browser".
model: haiku
allowed-tools:
  - Bash(/usr/local/bin/orca tab create *)
  - Bash(/usr/local/bin/orca tab switch *)
  - Bash(/usr/local/bin/orca tab list *)
  - Bash(gh pr view *)
---

Orca is an Electron IDE; its `orca` CLI opens built-in browser tabs. Do not use `open` or redirect-HTML workarounds.

**Placement is cwd-sensitive.** `orca tab create` opens the tab "in the current worktree" — the browser belonging to whichever worktree your shell's cwd is inside. Each git worktree (e.g. `.worktree/NELO-1234`) has its own browser, separate from the main workspace window. `--worktree active`/`current` just means "cwd's worktree" and changes nothing. So if your cwd is inside a worktree (common during a `do-jira-task` / worktree flow) the tab lands in that worktree's browser, NOT the main window — and the user, looking at the main window, sees nothing open. Always target the window the user is actually viewing with an explicit `--worktree` selector.

1. Resolve URL: use the given URL, or for "this PR" run `gh pr view --json url -q .url`.
2. Pick the target worktree selector. If unsure which window the user is viewing, default to the main workspace (`branch:main`, or `path:<repo-root>`). Supported selectors: `branch:<branch>`, `issue:<number>`, `name:<displayName>`, `path:<path>`, `id:<repo-id>::<path>`, or `active`/`current` (cwd's worktree).
3. Create the tab: `/usr/local/bin/orca tab create --url <URL> --worktree <selector> --json`. Take the page id from `result.browserPageId` in the JSON — NOT the top-level `id`.
4. Focus it: `orca tab create` only opens the tab in the background, so switch to it with `/usr/local/bin/orca tab switch --page <browserPageId> --worktree <selector> --focus` — pass the SAME `--worktree` selector used in step 3.
5. Verify placement with `/usr/local/bin/orca tab list --json` and confirm the new tab's `worktreeId` matches the intended window. If it landed in the wrong worktree, re-create it with the correct selector.
6. Report the tab id and which window (worktree) it opened in.
