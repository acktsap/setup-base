---
name: java-javadoc
description: Apply a naming-first Javadoc policy during Java work. Preserve existing Javadoc and package-info.java files, document interface method contracts, and otherwise add only necessary @throws tags.
---

`java-javadoc <file-or-task>` - keep Java intent in the code instead of adding prose documentation.

## Policy

1. Do not add type-, field-, constructor-, or non-interface-method Javadoc, except for the narrow `@throws` case below.
2. Express intent through precise class, method, parameter, field, and local-variable names and through small, cohesive code structure.
3. Preserve existing Javadoc. Do not remove, rewrite, expand, or normalize unrelated content.
4. Leave every `package-info.java` file unchanged: do not create, edit, move, or delete one.
5. Document the contract of every new or changed interface method in method Javadoc. Load `references/method.md` before editing an interface method.
6. Outside interface methods, the only new Javadoc content allowed is an `@throws` tag for a non-obvious, caller-visible exception condition. Load `references/method.md` before adding or changing one.
7. Do not rename an existing public or protected API solely to avoid Javadoc. Prefer expressive names for new code and rename existing symbols only when the task already permits the compatibility impact.

When a changed exception contract requires an `@throws` tag in an existing Javadoc block, change only the affected tag and preserve all surrounding documentation.

## References

- `references/class.md`: naming-first rules for types and fields.
- `references/method.md`: interface method contracts, naming-first rules for other methods, and the narrow `@throws` exception.
- `references/package-info.md`: the do-not-touch rule for `package-info.java`.
