---
name: prune-comments
description: Remove comments that the code already explains; keep only intent the code can't show. Triggers on "주석 정리", "주석 다듬기", "comment cleanup", "prune comments".
---

`prune-comments <file-or-dir>` (no path → recently edited file)

## Principle

Code shows WHAT. Comments should only show WHY — intent, constraints, and context not visible from the code itself.

The test: for each clause, ask "If I deleted this, would a reader seeing this file cold be confused about something they couldn't recover within ~30s of reading the code?" If no, cut; otherwise, keep.

Modify comments only, never the surrounding code. If a comment mixes kept and removed clauses, rewrite to preserve the kept ones.

## Remove (code already shows this)

- Restates the next statement (`// increment count` above `count++`).
- Paraphrases names or types.
- Section headers (`// --- helpers ---`).
- "Used by X" / "Called from Y" — grep shows this.
- Task or PR narration (`// added for #1234`).
- Commented-out code.

## Keep (intent the code can't show)

- WHY behind a non-obvious choice: constraints, invariants, ordering, limitations, workarounds, empirically chosen magic numbers.
- Pointers requiring outside lookup: tickets, RFCs, upstream bugs, vendor docs, design docs.
- TODO / FIXME / HACK / NOTE — keep the marker; trim attached prose only if it restates code.
- Module / class / method docstring: apply the test; also keep one sentence of purpose if the name is ambiguous.

## Never touch

- Directives and pragmas (`# noqa`, `# type: ignore`, `@ts-expect-error`, `# pragma: no cover`, shebangs, encoding pragmas, modelines, `# region`).
- License / copyright headers; files marked `@generated` or `DO NOT EDIT`.
- Tool-tag lines and their continuations (`@param`, `@returns`, `:param name:`, `:returns:`); doctest `>>>` blocks.

## Example

Trim — the lead-in restates `range(3)`:

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

Keep — the constraint is invisible from the type:

```typescript
// Use Map (not object): V8 reorders integer-like string keys ascending,
// which corrupts insertion order for numeric IDs.
const cache = new Map<number, Entry>();
```
