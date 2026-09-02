# Methods And Exceptions

## Interface Methods

Write method Javadoc for every new or changed interface method. State the contract that callers and implementations must follow, including relevant preconditions, return guarantees, nullability, ordering, side effects, lifecycle constraints, or implementation obligations. Include only established contract facts; do not invent guarantees from the current implementation.

Do not restate what the method name, parameter names, return type, or annotations already say. Use `@param` and `@return` only when they carry contract information beyond the signature. A subinterface override needs Javadoc only when it refines the inherited contract, and an implementing class must not repeat the interface Javadoc.

Preserve unrelated content in existing Javadoc. When the interface method's contract changes, edit only the affected contract statements and tags.

## Interface Method Template

Use this shape and omit every line that does not convey a non-obvious contract:

```java
/**
 * {Caller-visible guarantee or behavior not conveyed by the signature.}
 * {Implementation obligation, when one exists.}
 *
 * @param input {Non-obvious caller obligation, when needed.}
 * @return {Non-obvious return guarantee, when needed.}
 * @throws ExceptionType {Caller-visible triggering condition, when needed.}
 */
ReturnType method(ParameterType input);
```

## Other Methods

Do not add method- or constructor-level Javadoc to explain purpose, parameters, return values, lifecycle, side effects, ordering, performance, or other contracts. Prefer a precise method name, parameter names that identify each argument's role, and extraction into small, cohesive methods.

Preserve existing Javadoc without rewriting, expanding, normalizing, or deleting it, except for an affected `@throws` tag.

## The `@throws` Exception

Add or update an `@throws` tag only when all of these are true:

- the exception condition is caller-visible
- the triggering condition is not obvious from the signature, standard Java convention, or a validation annotation
- the condition is established by the code or tests rather than inferred speculatively

Describe the triggering condition, not merely the exception type. Outside interface methods, do not add a summary, `@param`, `@return`, or other tags to accompany a new `@throws` tag.

```java
/**
 * @throws IllegalStateException if no planner is registered for the request type
 */
ExecutionPlan create(Request request);
```

If a Javadoc block already exists, add or change only the affected `@throws` tag and leave its other content untouched. Do not document unchecked exceptions whose conditions are ordinary language or library behavior, such as null dereferences, index errors, or unsupported collection mutations.
