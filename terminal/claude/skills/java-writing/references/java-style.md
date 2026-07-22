# Java Style

Read this before writing or rewriting Java production code or Java tests.

## Scope

- Apply these rules to new code and code already being rewritten for the task.
- Do not rewrite unrelated existing code only to satisfy this style.
- Prefer the surrounding package's established naming, ordering, formatting, and exception style when it is more specific than this file.

## Loops

- Write explicit `for` loops for ordinary iteration.
- Do not add enhanced `for` loops (`for (Item item : items)`).
- Do not add `Iterable.forEach(...)` or `stream.forEach(...)` for ordinary iteration.
- For indexed data, prefer an index-based loop.
- For non-indexed `Iterable` or `Iterator` data, write an explicit iterator loop.

```java
for (var i = 0; i < items.size(); i++) {
    Item item = items.get(i);
    process(item);
}

for (var iterator = items.iterator(); iterator.hasNext(); ) {
    Item item = iterator.next();
    process(item);
}
```

## Local Variable Types

- Use explicit local variable types by default.
- Use `var` only in `for` loop headers.
- Do not use `var` for ordinary assignments, method results, builders, optionals, streams, or `try`-with-resources variables.
- Do not use `var` in enhanced `for` loops because enhanced `for` loops are not added under this style.

```java
for (var i = 0; i < count; i++) {
    Result result = loadResult(i);
    results.add(result);
}
```
