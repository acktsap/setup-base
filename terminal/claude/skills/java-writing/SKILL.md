---
name: java-writing
description: >-
  Apply Java team writing style and route Java documentation before editing Java source or Java tests.
  Use when writing, modifying, or reviewing `.java` files, including tasks that begin without mentioning Java
  but discover Java production code or tests during implementation.
---

`java-writing <file-or-task>` - load Java team style before editing Java.

## Workflow

1. Before editing any Java source or Java test, read `references/java-style.md`.
2. Apply it while writing touched code; preserve unrelated code and prefer a more specific package convention.
   Do not change an established API or lifecycle contract solely for style conformance.
3. For Java unit tests, use `write-london-unit-test`, then read `references/unit-test.md`.
4. For Javadoc kept or added by the code-intent gate, use `java-javadoc`.
5. For a class used only as a namespace for static members, read `references/utility-class.md`.

## References

- `references/java-style.md`: common Java style rules for production and test code.
- `references/unit-test.md`: Java unit-test data generation and property-oriented assertion style.
- `references/utility-class.md`: design and writing rules for non-instantiable static utility classes.
