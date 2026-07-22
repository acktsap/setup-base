---
name: java-javadoc
description: Write or update Java Javadoc for package, type, and method contracts using default-deny documentation rules. Use when Java work touches package-info.java, public/protected/API/SPI methods, interfaces, abstract or extension types, factories, core domain types, or any non-obvious responsibility, boundary, invariant, lifecycle, threading, ordering, side effect, exception, or performance contract.
---

`java-javadoc <file-or-task>` - decide whether Java Javadoc is needed and load the narrow reference.

## Workflow

1. Start default-deny: prefer no Javadoc over low-value Javadoc.
2. Add or update Javadoc only for a non-obvious caller-visible contract, durable boundary, responsibility, invariant, lifecycle, thread-safety, side effect, exception, ordering, or performance constraint.
3. Load only the reference files that match the changed surface:
   - `references/package-info.md` for package boundaries and `package-info.java`.
   - `references/class.md` for class, interface, abstract type, SPI, extension type, factory, coordinator, or core domain type docs.
   - `references/method.md` for public, protected, interface, SPI, extension-point, or reused internal method contracts.
4. If multiple surfaces are changed, load each matching reference before editing that surface.
5. Keep each Javadoc within the documented element's own responsibility.
6. Do not invent contracts; derive them from code, tests, existing docs, API behavior, package structure, and caller-visible effects. Report uncertainty when evidence is insufficient.

## Shared Rules

- Document responsibility and contract, not implementation steps.
- Do not add IDE-generated or obvious Javadoc.
- Do not rewrite useful existing prose only to force the templates in the references.
- If a doc fails the default-deny test, remove or avoid it even when a matching reference exists.

## References

- `references/package-info.md`: package-level Javadoc and `package-info.java` boundaries.
- `references/class.md`: class, interface, SPI, abstract type, factory, coordinator, and core domain type Javadoc.
- `references/method.md`: method-level Javadoc for caller-visible or durable internal contracts.
