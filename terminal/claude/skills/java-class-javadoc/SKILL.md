---
name: java-class-javadoc
description: Write or update Java class-level Javadoc that documents responsibility, non-responsibility, invariants, and thread-safety. Use whenever modifying public classes, interfaces, abstract classes, SPI types, factories, core domain objects, or reviewing Java type boundaries.
---

`java-class-javadoc <class-or-file>` - document Java type responsibility and caller-visible constraints.

## Goal

Document what a type is responsible for and what it is not responsible for. Do not explain how the implementation works unless that implementation creates a caller-visible contract.

## When To Write

Always consider class-level Javadoc for:

- public classes
- interfaces
- abstract classes
- SPI types
- factories
- core domain objects

Usually skip:

- DTOs
- records
- exceptions
- simple utility classes

If a skipped type has a non-obvious boundary, invariant, or API contract, document that fact anyway.

## Required Content

For documented types, include:

- `Responsibility`: the role the type owns.
- `Non-responsibilities`: roles the type explicitly does not own.

Add optional sections only when they matter:

- `Invariant`: strong state constraints, system-wide assumptions, or facts agents are likely to break.
- `Thread-safety`: only for concurrent or shared objects.

## Template

```java
/**
 * Responsibility:
 * Translates validated YAML objects into runtime configurations.
 *
 * Non-responsibilities:
 * - Schema validation
 * - Default value injection
 * - File I/O
 */
public final class ConfigMapper {
```

Add invariant when needed:

```java
/**
 * Invariant:
 * Returned configurations are immutable.
 */
```

Add thread-safety only when relevant:

```java
/**
 * Thread-safety:
 * This class is thread-safe.
 */
```

## Writing Rules

- Prefer no Javadoc over low-value Javadoc; add documentation only when it clarifies a boundary, contract, invariant, side effect, or performance constraint.
- Document responsibility and contract, not internal implementation.
- Write the minimum useful Javadoc; boundary and contract are mandatory when the type needs documentation.
- Do not add IDE-generated or obvious Javadoc.
- Do not write generic summaries such as "Service implementation" or "Utility class."
- Do not invent responsibilities. Use code, tests, package docs, and existing API behavior as evidence.
