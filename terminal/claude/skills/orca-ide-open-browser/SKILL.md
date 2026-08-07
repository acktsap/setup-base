---
name: orca-ide-open-browser
description: Open a URL, the current GitHub repository, or the current PR in the Orca IDE's built-in browser tab. Triggers on "orca 브라우저로 열어줘", "orca ide 내장 브라우저", "open in orca browser", "orca-ide-open-browser".
model: haiku
allowed-tools:
  - Bash(orca-ide-open-browser)
  - Bash(orca-ide-open-browser:*)
---

Open the target page in the Orca IDE's built-in browser by running the `orca-ide-open-browser` command, which resolves the worktree's browser window, resolves the URL, opens the tab, focuses it, and verifies it landed in the right window.

`orca-ide-open-browser` owns everything except argument selection. Do not call `orca` or `gh` directly, and do not use `Read`, `Edit`, `Write`, `jq`, `echo`, command separators, command substitutions, pipes, or output redirection; those fall outside the allowlist or duplicate what the command already does. Do not use `open` or redirect-HTML workarounds.

1. Pick one argument form and run it as a single call:
   - A URL the user supplied: `orca-ide-open-browser <url>` — passed through unchanged.
   - "this PR" or no stated target: `orca-ide-open-browser`. On the default branch this opens the repository instead, by design.
   - "this repository": `orca-ide-open-browser --repo`.
2. Add `--worktree <selector>` only when the user says they are looking at a different window than the shell's cwd — for example `--worktree path:<repo-root>` for the main workspace. **Each git worktree has its own browser window**, so during a `do-jira-task` / worktree flow the default is already correct and this flag should be omitted.
3. Report the command's output as-is: which kind of page it opened, the URL, the page id, and the worktree it landed in.

Exit status 3 means the tab was created but landed in the wrong window; the command prints the active tab's raw JSON. Report that rather than claiming success.

#### Codex

Codex does not interpret the `allowed-tools` frontmatter, and its sandbox blocks Orca's daemon socket and token under `~/Library/Application Support/orca` as well as internal GitHub network access. Run the command with `sandbox_permissions: "require_escalated"` from the first attempt — do not first try it in the default sandbox. Set `justification` and use this `prefix_rule`:

```text
["orca-ide-open-browser"]
```
