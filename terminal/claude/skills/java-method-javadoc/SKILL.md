---
name: java-method-javadoc
description: Write or update Java method-level Javadoc that documents caller-visible contracts, preconditions, postconditions, exceptions, externally visible side effects, and performance constraints. Use when modifying API, SPI, extension, or reused internal Java methods whose caller-visible or durable internal contract is non-obvious or not encoded by signatures, annotations, validation, or inherited documentation.
---

`java-method-javadoc <method-or-file>` - document Java method contracts.

## Goal

Document the method contract: what callers must satisfy before calling and what the method guarantees after returning. Do not describe internal implementation steps.

## When To Write

Consider writing or updating method-level Javadoc for API-facing methods when their caller-visible contract is non-obvious, including:

- SPI methods and extension points
- protected APIs intended for subclassing
- interface methods whose inherited contract is absent or insufficient
- methods with lifecycle, validation, ordering, mutability, exception, side-effect, or performance constraints

Usually skip:

- simple getters and setters
- methods whose contract is fully expressed by the name, signature, annotations, or inherited Javadoc
- simple framework overrides that only adapt or delegate to the conventional hook
- simple private helper methods

Write Javadoc for non-public methods only when they act as reused internal APIs or have a durable contract, such as:

- a strong precondition
- an ordering, mutability, concurrency, or performance guarantee
- an externally visible, non-local, durable, or concurrency-visible side effect

For complex algorithms without a durable caller or internal contract, prefer a short implementation comment or a refactor over method Javadoc.

## Contract Content

Include `Contract` when the method has caller-visible preconditions or postconditions.

Preconditions describe what must be true before calling:

- `request must already be validated.`
- `caller must hold the scheduler lock.`

Postconditions describe what is guaranteed after return:

- `returned list preserves insertion order.`
- `returned collection is unmodifiable.`

Use `@throws` to describe when exceptions occur if those exceptions are part of the caller-visible contract. Do not only name the exception type.

Add optional sections only when they matter:

- `Side effects`: when external, durable, shared, or otherwise non-local state changes.
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
 * @throws IllegalStateException if no planner is registered for the request type
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
- Do not repeat inherited Javadoc unless the method changes or sharpens the inherited contract.
- Do not rewrite useful prose Javadoc only to force the section labels in the examples.
- Do not invent contracts. Derive them from type signatures, validation, tests, docs, and established behavior; report uncertainty when evidence is insufficient.
