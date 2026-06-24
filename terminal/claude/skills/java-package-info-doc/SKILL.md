---
name: java-package-info-doc
description: Write or update Java package-info.java documentation that defines package responsibility, boundaries, non-responsibilities, and extension points. Use whenever modifying Java files in a meaningful package, adding a package, reviewing package boundaries, or creating package-info.java files.
---

`java-package-info-doc <package-or-directory>` - ensure meaningful Java packages have boundary documentation.

## Goal

Document package responsibility and boundaries so future maintainers and agents can decide what belongs in the package and what must stay elsewhere.

Write minimal documentation. Prefer boundary and responsibility facts over implementation details.

## When To Add Or Update

Create or update `package-info.java` for every meaningful package, including packages such as:

- `execution`
- `config`
- `metrics`
- `plugin`
- `scheduler`

Skip only trivial, generated, or purely mechanical packages where no durable boundary can be stated. If a Java change moves responsibility across package boundaries, update the affected `package-info.java` files in the same change.

## Required Content

Every package doc must include:

- `Responsibility`: what this package owns.
- `Non-responsibilities`: what this package explicitly does not own.

Add `Extension points` only when the package intentionally exposes externally extensible types.

## Template

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

- Prefer no Javadoc over low-value Javadoc; add documentation only when it clarifies a boundary, contract, invariant, side effect, or performance constraint.
- Document responsibility and contract, not implementation steps.
- Make boundaries concrete enough to guide where future code should and should not be added.
- Keep prose short; use bullet lists for exclusions.
- Do not invent boundaries. Infer them from package contents, names, tests, and nearby docs; report uncertainty when evidence is insufficient.
- Avoid generic text such as "Contains execution classes" or "Package for utilities."
