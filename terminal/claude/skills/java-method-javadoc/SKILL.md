---
name: java-method-javadoc
description: Write or update Java method-level Javadoc that documents caller-visible contracts, preconditions, postconditions, exceptions, side effects, and performance constraints. Use whenever modifying public APIs, protected APIs, interface methods, SPI methods, extension points, or complex Java methods.
---

`java-method-javadoc <method-or-file>` - document Java method contracts.

## Goal

Document the method contract: what callers must satisfy before calling and what the method guarantees after returning. Do not describe internal implementation steps.

## When To Write

Always write or update method-level Javadoc for:

- public APIs
- protected APIs
- interface methods
- SPI methods
- extension points

Usually skip:

- simple getters and setters
- simple private helper methods

Write Javadoc even for non-public methods when there is:

- a complex algorithm
- a strong precondition
- performance-sensitive behavior
- a side effect

## Contract Content

Include `Contract` when the method has caller-visible preconditions or postconditions.

Preconditions describe what must be true before calling:

- `request must already be validated.`
- `caller must hold the scheduler lock.`

Postconditions describe what is guaranteed after return:

- `returned list preserves insertion order.`
- `returned collection is unmodifiable.`

Use `@throws` to describe when exceptions occur. Do not only name the exception type.

Add optional sections only when they matter:

- `Side effects`: when external state changes.
- `Performance`: when the method is hot-path or must avoid expensive work.

## Template

```java
/**
 * Creates an execution plan.
 *
 * Contract:
 * - request must already be validated.
 * - returned plan is immutable.
 *
 * @param request validated request
 * @return immutable execution plan
 * @throws IllegalArgumentException if the request is invalid
 */
ExecutionPlan create(Request request);
```

Side effects example:

```java
/**
 * Side effects:
 * - Persists metrics to the database.
 * - Publishes events to Kafka.
 */
```

Performance example:

```java
/**
 * Performance:
 * Invoked on every record. Must not perform blocking I/O.
 */
```

## Writing Rules

- Prefer no Javadoc over low-value Javadoc; add documentation only when it clarifies a boundary, contract, invariant, side effect, or performance constraint.
- Document responsibility and contract, not implementation details.
- Help future maintainers and agents understand where changes are allowed and where they are not.
- Keep docs minimal, but always state important boundaries and contracts.
- Avoid IDE-generated Javadoc such as `@param request request` or `@return result`.
- Do not invent contracts. Derive them from type signatures, validation, tests, docs, and established behavior; report uncertainty when evidence is insufficient.
