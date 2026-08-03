# Package Javadoc

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

Every package doc that is worth writing must state what the package owns. When that responsibility
is the only concern documented, write it directly without a `Responsibility:` label.

Use labeled sections only when optional concerns also matter:

- `Non-responsibilities`: what this package explicitly does not own when ownership is likely to be confused.
- `Invariant`: package-wide domain rules or cross-type consistency constraints.
- `Extension points`: only when the package intentionally exposes externally extensible types.

## Template

Single-responsibility example:

```java
/**
 * Executes benchmark workloads and records their observable results.
 */
package com.foo.execution;
```

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

## Write From The Layer, Not From The Current Arrangement

State what the package owns at the level of its layer. A package doc outlives the code that happens
to sit in it today, so it must not lean on which types currently live there, which collaborator holds
the counterpart, or which feature prompted the package.

Cut a clause when it names a sibling package's role, a specific job or use case, or a placement
decision that a later refactor would invalidate.

```java
// Wrong - pins today's arrangement and a neighbouring package's role:
/**
 * Identifiers and limits the execution package is written against, kept out of the transport package's wire models.
 */
package com.foo.domain;

// Right - the layer's own responsibility:
/**
 * Domain model of the benchmark workloads.
 */
package com.foo.domain;
```

## Writing Rules

- Prefer no Javadoc over low-value Javadoc; add documentation only when it clarifies package responsibility, durable boundaries, ownership confusion, package-wide invariants, or extension points.
- Document responsibility and boundaries, not implementation steps.
- Describe the layer, not the current contents: no clause that a type moving in or out would falsify.
- Make boundaries concrete enough to guide where future code should and should not be added.
- Keep prose short; use bullet lists for exclusions only when exclusions clarify a likely ownership mistake.
- Omit section labels when only one concern is documented; use them to separate multiple concerns, not as mandatory boilerplate.
- Do not rewrite useful prose package Javadoc only to force the section labels in the examples.
- Do not invent boundaries. Infer them from package contents, names, tests, and nearby docs; report uncertainty when evidence is insufficient.
- Avoid generic text such as "Contains execution classes" or "Package for utilities."
