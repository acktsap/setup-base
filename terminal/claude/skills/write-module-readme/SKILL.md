---
name: write-module-readme
description: Write or update a module-level README.md. Triggers on "모듈 README", "module readme", "write module readme", "모듈 설명 작성", "서브모듈 README".
---

Write a README.md for the specified module directory.

## Trigger

`write-module-readme <module-path>`

If no path is given, use the current working directory.

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
- Do not summarize implementation details — that is the code's job.
- If the module already has a README.md, update it instead of overwriting. Preserve any human-written content that is still accurate.
- Use the project's markdown conventions.

## Examples

### Good: domain service module

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

### Good: small utility module

```markdown
# hash-id

Generate URL-safe, collision-resistant short IDs from UUIDs.

## Why

Multiple services needed human-readable IDs for logs and URLs.
Standard base64 includes characters that break URL parsing.
```

### Good: CLI tool module

```markdown
# db-migrate

Run and rollback database migrations in order.

## Why

ORM auto-migration silently dropped columns in production.
This module enforces explicit, versioned, reversible migrations.

## Constraints

- Migrations must be idempotent — re-running a migration must not fail.
- No down migration is generated automatically. Authors must write both up and down.
- Requires an advisory lock. Two instances cannot migrate concurrently.
```

### Bad: implementation summary (do not write like this)

```markdown
# event-router

## Architecture

EventRouter class receives events through the `dispatch()` method.
It iterates over registered handlers and calls `handler.handle(event)`.
Failed handlers are retried up to 3 times with exponential backoff.
Dead-lettered events are emitted via the `onDeadLetter` callback.

## API

- `EventRouter.register(eventType, handler)` — register a handler
- `EventRouter.dispatch(event)` — dispatch an event
- `EventRouter.onDeadLetter(callback)` — set dead-letter callback

## File Structure

- `router.ts` — main router class
- `retry.ts` — retry logic
- `types.ts` — type definitions
```

This is bad because:
- API signatures belong in code or generated docs, not README.
- File structure is visible from `ls`.
- Implementation details (retry count, exponential backoff) will go stale.
- Missing the actual useful information: why this exists and what it does not do.
