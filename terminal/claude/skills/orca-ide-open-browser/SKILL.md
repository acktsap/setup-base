---
name: orca-ide-open-browser
description: Open a URL in the Orca IDE's built-in browser tab. Triggers on "orca 브라우저로 열어줘", "orca ide 내장 브라우저", "open in orca browser", "orca-ide-open-browser".
allowed-tools:
  - Bash(orca tab create *)
  - Bash(gh pr view *)
---

Orca is an Electron IDE; its `orca` CLI opens built-in browser tabs. Do not use `open` or redirect-HTML workarounds.

1. Resolve URL: use the given URL, or for "this PR" run `gh pr view --json url -q .url`.
2. Run `orca tab create --url <URL>` (add `--worktree active` to scope to a worktree's browser).
3. Report the tab id.
