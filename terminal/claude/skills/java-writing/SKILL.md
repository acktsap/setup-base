---
name: java-writing
description: Apply Java team writing style and route Java documentation before editing Java source or Java tests. Use when writing, modifying, or reviewing `.java` files, including tasks that begin without mentioning Java but discover Java production code or tests during implementation.
---

`java-writing <file-or-task>` - load Java team style before editing Java.

## Workflow

1. Before editing any Java source or Java test, read `references/java-style.md`.
2. Apply the style rules while writing the first draft, not as a cleanup pass.
3. Preserve unrelated existing code even when it does not follow this style.
4. If the task changes Java tests, also use the test skills required by the active AGENTS instructions.
5. If the task changes Java contracts or documentation-worthy boundaries, use `java-javadoc`.

## Javadoc Routing

Use `java-javadoc` whenever package, type, or method Javadoc may be needed. It is the Java Javadoc entry point and loads package/type/method references lazily.

## References

- `references/java-style.md`: common Java style rules for production and test code.
