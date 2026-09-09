---
name: write-module-readme
description: Write or update a module-level README.md. Triggers on "모듈 README", "모듈 설명 작성", "서브모듈 README".
---

`write-module-readme <module-path>` (no path → cwd)

## Process

1. Read the module's code: entry points, public API, directory structure.
2. Draft the README focusing only on what the code cannot tell you:
    - What this module is (one line)
    - Why it exists / design intent
    - What it intentionally does not do (boundaries)
    - Non-obvious dependencies or constraints
3. Present the draft to the user for review before writing the file.

## Rules

- Maximum length: 30 lines.
- Skip any section that the code already makes obvious.
- Never write an API signature list, a file tree, or implementation details such as a retry count or backoff
  strategy: they belong in the code or generated docs, are visible from `ls`, or go stale.
- If the module already has a README.md, update it instead of overwriting. Preserve any human-written content that is still accurate.
- Use the project's markdown conventions.

## Example

```markdown
# event-router

Route domain events to registered handlers with retry and dead-letter support.

## Why

The monorepo had three modules each implementing their own dispatch-and-retry loop.
This module extracts that shared concern so consumers only declare handlers.

## Boundaries

- Routes events, does not produce them.
- Retry is per-handler. Circuit breaking is the caller's responsibility.
- No persistence — dead-letter is the caller's problem.
```
