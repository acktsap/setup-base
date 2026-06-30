---
name: java-class-javadoc
description: Write or update Java class-level Javadoc that documents responsibility, caller-visible boundaries, invariants, and thread-safety. Use when modifying API-facing or boundary-owning Java types, SPI and extension types, factories or coordinators that choose policy or workflow, abstract/interface contracts, or behavior-bearing core domain types whose responsibility, invariants, lifecycle, or threading are not obvious.
---

`java-class-javadoc <class-or-file>` - document Java type responsibility and caller-visible constraints.

## Goal

Document what a type is responsible for and any caller-visible boundary it owns. Do not explain how the implementation works unless that implementation creates a caller-visible contract.

## When To Write

Consider class-level Javadoc for types that own a caller-visible boundary or contract, including:

- API-facing classes and interfaces whose role is not obvious from the type name or signature
- abstract classes, SPI types, and extension points
- factories or coordinators that choose policy or workflow
- services that own workflow, authorization, transaction boundaries, idempotency, integration contracts, or domain policy
- behavior-bearing core domain types that own policy or workflow
- shared or concurrent types with lifecycle, invariant, or thread-safety constraints

Usually skip:

- DTOs
- exceptions
- records and simple value objects without non-obvious invariants
- ordinary controllers, delegating CRUD services, repositories, configuration beans, adapters, serializers, annotations, test fixtures, and framework implementations whose role is obvious from convention
- generated types
- simple utility classes

If a skipped type has a non-obvious boundary, invariant, normalization or unit rule, identity rule, serialization compatibility concern, lifecycle, thread-safety, security, integration contract, error taxonomy, retry or recovery semantics, annotation retention rule, or annotation processor/framework behavior, document that fact anyway.

## Required Content

For documented types, include at least one section that justifies the Javadoc:

- `Responsibility`: the role the type owns, when the type owns behavior or a boundary.
- `Invariant`: strong state constraints, system-wide assumptions, or value-object facts agents are likely to break.

Add optional sections only when they matter:

- `Non-responsibilities`: roles the type does not own when ownership is likely to be confused.
- `Thread-safety`: only for concurrent or shared objects.

## Template

Boundary example with optional exclusions:

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

Value object invariant example:

```java
/**
 * Invariant:
 * Amount is stored in normalized USD minor units.
 */
public record MoneyAmount(long cents) {
```

Thread-safety example:

```java
/**
 * Responsibility:
 * Shares scheduler state across worker threads.
 *
 * Thread-safety:
 * This class is thread-safe.
 */
public final class SchedulerState {
```

## Writing Rules

- Prefer no Javadoc over low-value Javadoc; add documentation only when it clarifies a boundary, contract, invariant, lifecycle, or thread-safety constraint.
- Document responsibility and contract, not internal implementation.
- Stay within the type's own responsibility (SRP). Do not describe a collaborator's, downstream's, or upstream's behavior, and do not name a specific collaborator to justify this type's behavior. When a cross-boundary fact matters, state it as this type's own contract or as its requirement on others — not as a description of how the other component works.

  ```java
  // Wrong - justifies this type by describing a collaborator's behavior (leaks SRP, couples to it):
  /**
   * ... Emitting an item more than once is safe because the downstream store's upsert merges
   * duplicates by key.
   */

  // Right - states only this type's own contract and its requirement on collaborators:
  /**
   * Forwards each changed item, possibly more than once after a restart.
   * Consumers must therefore be idempotent.
   */
  ```
- Write the minimum useful Javadoc; responsibility is mandatory for behavior or boundary owners, invariant may be primary for invariant-only value types, and exclusions are optional.
- Do not add IDE-generated or obvious Javadoc.
- Do not write generic summaries such as "Service implementation" or "Utility class."
- Do not rewrite useful prose Javadoc only to force the section labels in the examples.
- Do not invent responsibilities. Use code, tests, package docs, and existing API behavior as evidence.
