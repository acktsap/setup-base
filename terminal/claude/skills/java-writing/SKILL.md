---
name: java-writing
description: >-
  Apply Java team writing style and route Java comments and documentation before editing Java source or Java tests.
  Use when writing, modifying, or reviewing `.java` files, including tasks that begin without mentioning Java
  but discover Java production code or tests during implementation.
---

`java-writing <file-or-task>` - load Java team style before editing Java.

## Workflow

1. Before editing any Java source or Java test, read `references/java-style.md`.
2. Apply it while writing touched code; preserve unrelated code and prefer a more specific package convention.
   Do not change an established API or lifecycle contract solely for style conformance.
3. Review scope: when reviewing Java changes I authored — the local working diff, a branch or PR
   created in this session, or a PR whose author is my account — read `references/java-style.md`
   first and treat its rules as review criteria, flagging violations in touched code as findings.
   When reviewing another author's changes, do not raise findings from this guide: judge their
   code by correctness and the repository's own conventions only.
4. For Java unit tests, use `write-london-unit-test`, then read `references/unit-test.md`.
5. Before writing any comment or Javadoc in touched code, use `comment-writing` as the gate — including when
   the mechanics look obvious. For a Javadoc block that gate keeps or adds, read `references/javadoc.md`
   for placement.
6. For a class used only as a namespace for static members, read `references/utility-class.md`.
7. For a method that calls a remote endpoint, read `references/remote-client.md`.
