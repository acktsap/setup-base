---
name: orca-ide-open-browser
description: Open a URL, the current GitHub repository, or the current PR in the Orca IDE's built-in browser tab. Triggers on "orca 브라우저로 열어줘", "orca ide 내장 브라우저", "open in orca browser", "orca-ide-open-browser".
model: haiku
allowed-tools:
  - Bash(/usr/local/bin/orca tab create *)
  - Bash(/usr/local/bin/orca tab switch *)
  - Bash(/usr/local/bin/orca tab list *)
  - Bash(/usr/local/bin/orca tab current *)
  - Bash(/usr/local/bin/orca worktree current *)
  - Bash(gh pr view *)
  - Bash(gh repo view *)
---

Orca is an Electron IDE; its `orca` CLI opens built-in browser tabs. Do not use `open` or redirect-HTML workarounds.

Run only the allowed commands as separate tool calls. Do not wrap them in shell scripts, variable assignments, command substitutions, pipes, `jq`, `echo`, or output redirection; those extra shell operations fall outside the skill's allowlist and trigger permission prompts. Read JSON from each command's output and copy the needed value into the next command.

**Each git worktree has its own browser window.** A worktree (e.g. `.worktree/NELO-1234`) has a browser separate from the main workspace window. During a `do-jira-task` / worktree flow the shell cwd is inside that worktree, so **default to the cwd's worktree, not the main workspace.** Only target another window when the user explicitly asks for it.

**Do not rely on the `current`/`active` selector for `tab create` — it is unreliable and has placed tabs in the wrong window.** Resolve the cwd's worktree explicitly first and target it by `id:`, using `branch:` only if the worktree id is missing.

1. Resolve the target worktree explicitly: run `/usr/local/bin/orca worktree current --json` and read `result.worktree.id` and `result.worktree.branch`. Build the selector as `id:<result.worktree.id>` when `id` is present; otherwise use `branch:<result.worktree.branch>`. Quote the whole `--worktree` value because ids contain `::` and `/`. Use this same selector verbatim in every step below. Only override this default (e.g. `path:<repo-root>` for the main workspace) when the user says they're viewing a different window.
2. Resolve URL:
   - Use a URL supplied by the user unchanged.
   - For "this repository", run `gh repo view --json url -q .url`.
   - For "this PR", first run `gh repo view --json url,defaultBranchRef`. If `result.worktree.branch` equals `defaultBranchRef.name`, use the repository `url`; otherwise run `gh pr view --json url -q .url` and use the PR URL.
3. Create the tab: `/usr/local/bin/orca tab create --url <URL> --worktree "<selector>" --json`. Take the page id from `result.browserPageId` — NOT the top-level `id`.
4. Focus it: `/usr/local/bin/orca tab create` only opens the tab in the background, so switch to it with `/usr/local/bin/orca tab switch --page <browserPageId> --worktree "<selector>" --focus` — pass the SAME selector.
5. Verify placement with `/usr/local/bin/orca tab current --worktree "<selector>" --json` and confirm `result.tab.browserPageId` matches the page you created and `result.tab.worktreeId` matches the intended worktree. `browser_no_tab` means the tab landed in the wrong window — re-create it with the correct explicit `id:` selector. (`tab list` without a `--worktree` selector reports the cwd worktree's tabs only, so an empty list there does not mean the tab failed.)
6. Report the tab id and which window (worktree) it opened in.
