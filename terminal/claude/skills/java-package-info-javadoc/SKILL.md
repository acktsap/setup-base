---
name: java-package-info-javadoc
description: Write or update Java package-info.java documentation that defines package responsibility, durable boundaries, optional non-responsibilities, package-wide invariants, and extension points. Use when adding, renaming, moving, or splitting packages; changing responsibility across package boundaries; or creating/updating package-info.java for API-facing or shared packages with durable ownership rules.
---

`java-package-info-javadoc <package-or-directory>` - ensure meaningful Java packages have boundary documentation.

## Goal

Document package responsibility and boundaries so future maintainers and agents can decide what belongs in the package and what must stay elsewhere.

Write minimal documentation. Prefer boundary and responsibility facts over implementation details.

## When To Add Or Update

Create or update `package-info.java` when a package has a durable boundary worth documenting, such as:

- API-facing or shared packages whose ownership is not obvious from their contents
- packages that own an architectural layer, integration boundary, extension point, or cross-package rule
- new, renamed, moved, or split packages whose role should guide future code placement
- existing package docs affected by a responsibility move across package boundaries

Usually skip:

- generated packages
- DTO-only or simple value-object-only packages
- mapper-only, repository-only, or framework glue packages whose convention explains the boundary
- one-class, feature-internal, or purely mechanical leaf packages
- test fixture packages

If a skipped package owns a non-obvious external integration, transaction, security, serialization, lifecycle, dependency, or package-wide invariant boundary, document that boundary anyway.

If a Java change moves responsibility across package boundaries, update the affected `package-info.java` files in the same change.

## Required Content

Every package doc that is worth writing must include:

- `Responsibility`: what this package owns.

Add optional sections only when they matter:

- `Non-responsibilities`: what this package explicitly does not own when ownership is likely to be confused.
- `Invariant`: package-wide domain rules or cross-type consistency constraints.
- `Extension points`: only when the package intentionally exposes externally extensible types.

## Template

Boundary example with optional exclusions and extension points:

```java
/**
 * Responsibility:
 * Execute benchmark workloads.
 *
 * Non-responsibilities:
 * - Config validation
 * - Metrics persistence
 *
 * Extension points:
 * - BenchmarkRunner
 */
package com.foo.execution;
```

## Writing Rules

- Prefer no Javadoc over low-value Javadoc; add documentation only when it clarifies package responsibility, durable boundaries, ownership confusion, package-wide invariants, or extension points.
- Document responsibility and boundaries, not implementation steps.
- Make boundaries concrete enough to guide where future code should and should not be added.
- Keep prose short; use bullet lists for exclusions only when exclusions clarify a likely ownership mistake.
- Do not rewrite useful prose package Javadoc only to force the section labels in the examples.
- Do not invent boundaries. Infer them from package contents, names, tests, and nearby docs; report uncertainty when evidence is insufficient.
- Avoid generic text such as "Contains execution classes" or "Package for utilities."
