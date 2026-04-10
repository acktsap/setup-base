---
name: write-london-unit-test
description: Write unit tests following London School (mockist) TDD style.
---

`write-london-unit-test <class-or-method>` — read target source first, then write tests.

## Core Principles

### Test the contract

Test what the method promises (its contract), not how it works internally. If the contract does not change, the test should not break.

### Mock all collaborators

Only the SUT is real. Every dependency is a mock.

### Verify behavior, not state

Assert the SUT calls the right methods with the right arguments, the right number of times.

### No shared state between tests

No shared setup or class-level fields. Each test creates its own mocks and SUT inline.

### Constructor injection only

Wire mocks via constructor. No reflection or annotation-driven injection.

## Test Method Structure

### Naming

```
{action}Should{expectedResult}When{condition}
```

### Given-When-Then

Each test follows this strict ordering:

1. Given: Declare test variables → declare mock variables → configure stubs → construct SUT
2. When: Call exactly one method on the SUT
3. Then: Verify interactions and/or assert return values

The three phases should be visually distinguishable by whitespace, without requiring comments to label them.

## Test Organization

### Flat structure for simple classes

One level of test methods directly inside the test class.

### Nested classes for complex scenarios

Group related test methods under a nested class when a single class has many behaviors worth grouping (e.g., per-method or per-scenario).

## Test Data

Use a test data generator (Fixture Monkey, AutoFixture, faker). Only constrain fields relevant to the test — randomize everything else. Assert against generated values, not hardcoded ones.

Mock return values must also be randomized (UUID, Fixture Monkey, etc.). Extract all values into named variables before mock setup — never inline values inside `given().willReturn()` or `willThrow()`.

## Anti-patterns

- No shared setup (`@Mock`, `@InjectMocks`, `beforeEach`, `setUp`). Construct explicitly per test.
- No `test` prefix in method names.
- No state-only assertions when the SUT delegates. Verify the call.
