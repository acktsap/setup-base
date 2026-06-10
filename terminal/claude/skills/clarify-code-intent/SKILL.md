---
name: clarify-code-intent
description: Improve comments and docs so they capture non-obvious intent, caller-visible contracts, invariants, and why-context; prune comments that only restate code. Triggers on "주석 정리", "주석 다듬기", "comment cleanup", "prune comments", "의도 정리", "clarify code intent", "intent comments", "contract docs", "API contract comments".
---

`clarify-code-intent <file-or-dir>` (no path -> only the single unambiguous recently edited file)

## Goal

Make intent explicit at the most durable surface. Do not add comments merely to make code look explained or AI-friendly; reduce implicit knowledge so both people and tools have less to infer.

Default mode is comments/docs-only. Change names, types, validations, tests, or design docs only when the user explicitly asks for broader intent clarification beyond comments. Never change runtime behavior unless explicitly requested.

Prefer intent in this order when the requested scope allows it:

1. Clear domain names, types, validations, and error messages.
2. Tests whose names and scenarios express the requirement.
3. Public API / SDK / interface contract docs.
4. Module README or ADR for cross-cutting decisions.
5. Inline comments for local WHY that code cannot show.

When the user asks for comment cleanup only, modify comments/docs only and never change behavior. If intent belongs in tests, types, or design docs outside the requested scope, report it instead of broadening the edit.

## Comment Test

Code shows WHAT. Comments should show WHY: intent, contracts, constraints, and context not visible from the code itself.

For each clause, ask: "If I deleted this, would a reader seeing this file cold be confused about something they could not recover within ~30s of reading the code?" If no, cut it. If yes, keep or tighten it.

If a comment mixes kept and removed clauses, rewrite it to preserve only the useful intent.

## Remove (code already shows this)

- Restates the next statement (`// increment count` above `count++`).
- Paraphrases names or types.
- Decorative section headers (`// --- helpers ---`); keep navigational headers when they clarify large or non-obvious structure.
- "Used by X" / "Called from Y" when usage is trivially discoverable; keep it if it documents external, framework, generated, reflective, or operational coupling.
- Task or PR narration (`// added for #1234`).
- Commented-out code.
- Docstrings/Javadoc/TSDoc/KDoc that only repeat the symbol name, parameters, return type, or implementation steps.
- Comments added only so an AI reviewer can understand obvious control flow.

## Keep Or Improve (intent the code can't show)

- WHY behind a non-obvious choice: constraints, invariants, ordering, limitations, workarounds, empirically chosen magic numbers.
- Pointers requiring outside lookup: tickets, RFCs, upstream bugs, vendor docs, design docs.
- TODO / FIXME / HACK / NOTE - keep the marker; trim attached prose only if it restates code.
- Module / class / method docstring: apply the test; also keep one sentence of purpose if the name is ambiguous.
- Public API, SDK, and interface docs that define caller-visible contracts: preconditions, postconditions, side effects, error behavior, ordering guarantees, compatibility notes, security/privacy constraints, or domain invariants. Only state behavior backed by existing docs, tests, API specs, or clearly established caller-visible behavior.
- Operational constraints a caller or maintainer must know: retry safety, idempotency, consistency windows, backpressure, data retention, logging sensitivity, or rollout limitations.

## Never touch

- Directives and pragmas (`# noqa`, `# type: ignore`, `@ts-expect-error`, `# pragma: no cover`, shebangs, encoding pragmas, modelines, `# region`).
- License / copyright headers; files marked `@generated` or `DO NOT EDIT`.
- Tool-tag lines and their continuations (`@param`, `@returns`, `:param name:`, `:returns:`); doctest `>>>` blocks.

## Workflow

1. Identify the user's scope: comment pruning, intent clarification, or API contract documentation.
2. Skip generated files and files with "DO NOT EDIT".
3. Remove comments that merely restate code.
4. Preserve or tighten comments that explain invisible intent.
5. Add missing comments only when the intent is local, important, supported by evidence, and cannot be represented better in code, tests, or module docs.
6. Do not invent rationale. If the reason or contract is unclear, report the gap instead of guessing or leaving unresolved questions in code.

## Example

Trim - the lead-in restates `range(3)`:

```python
# Retry up to 3 times.
# Auth service returns 503 during its 30s post-deploy warmup (#1421).
for attempt in range(3):
    ...
```

becomes:

```python
# Auth service returns 503 during its 30s post-deploy warmup (#1421).
for attempt in range(3):
    ...
```

Keep - the constraint is invisible from the type:

```typescript
// Use Map (not object): V8 reorders integer-like string keys ascending,
// which corrupts insertion order for numeric IDs.
const cache = new Map<number, Entry>();
```

Keep contract docs - the behavior is caller-visible:

```java
/**
 * Sends each event at most once. Non-idempotent events are dropped on retryable
 * transport failures because downstream creates user-visible incidents.
 */
void publish(Event event);
```
