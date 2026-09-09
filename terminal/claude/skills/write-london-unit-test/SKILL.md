---
name: write-london-unit-test
description: Write unit tests following London School (mockist) TDD style.
---

`write-london-unit-test <class-or-method>` — read target source first, then write tests.

## Core Principles

### Test the contract

Test what the method promises (its contract), not how it works internally. If the contract does not change, the test should not break.

### Test only the essential properties

Write a test when a plausible mistake in the SUT would change an outcome someone depends on: a routing decision, a boundary, an aggregation, an ordering guarantee, or success turning into silent failure. One test per such decision.

Skip the rest. A test that costs a screen of stubbing to pin one line of plumbing is not cheap insurance; it is a second copy of the code that has to be edited every time the first one moves.

Do not write a test for:

- **Pass-through and delegation with no decision** — a value handed to a *collaborator* unchanged, a getter. Both halves must hold: the value leaves the SUT for another object, *and* some existing test would fail if it broke. A one-line body alone does not qualify — a contract the type owns is a decision however short its implementation (`return bytes` meaning "an uncompressed page decompresses to itself" is one), and if nothing else exercises that path, nothing would catch it breaking. Check the second half rather than assuming it.
- **Language or framework plumbing the SUT only relays** — unwrapping an `ExecutionException` and rethrowing its cause, wrapping a checked exception, restoring an interrupt flag. The worst realistic regression is a cosmetic one, such as an extra frame in a stack trace.
- **The absence of code** — an exception that propagates because nothing catches it. There is no branch to pin; the test only forbids a future change.
- **Where a call happens** — that a clock is read once outside the loop, that a field is computed before another. Pin the observable outcome, not the shape of the code.
- **Constructor validation on a value type** — a record, value object, or settings type whose constructor rejects a null, blank, or out-of-range argument. Each guard is a single assertion that fails loudly at construction, so nothing downstream can observe the invalid value. Test the code that *reads* the value and decides something from it instead. This holds however the type is populated, including a framework binding it from configuration.

When a guarantee matters operationally but is only observable end to end — a failed unit of work must surface to the caller or scheduler rather than being swallowed — cover it at the acceptance level instead of by stubbing internals.

### Mock all collaborators

Only the SUT is real. Every dependency is a mock.

### Verify behavior, not state

Assert the SUT calls the right methods with the right arguments, the right number of times.

If the return value already proves the interaction happened, asserting on the return value is enough — skip the redundant `verify()`.

Prefer argument matchers over an `ArgumentCaptor`. When the constraint on an argument is expressible as a matcher —
equality, a prefix, a type, a range — state it inside `verify()`; the expectation then reads on one line and a
mismatch reports both the expected and the actual argument. Reach for a captor only when the assertion must compute
something from the argument that no matcher expresses readably — decompressing it, parsing it, or asserting on the
fields of an object the SUT constructed — and bind the captured value to `actual` as below.

```java
// Prefer - the constraint is a matcher.
verify(client).listKeys(and(startsWith(prefix), endsWith(suffix)));

// Captor - the assertion decodes the argument first.
ArgumentCaptor<byte[]> captor = ArgumentCaptor.forClass(byte[].class);
verify(client).put(anyString(), captor.capture());
byte[] actual = captor.getValue();

assertThat(decompress(actual)).isEqualTo(expected);
```

### No helper methods

A unit test has no private helper methods. The test body holds the whole scenario, so a reader learns what is
exercised without jumping, and no two tests get coupled through shared setup.

Where the urge comes from, and where it goes instead:

- **repeated fixture construction** — register the type on the module's shared generator holder (a `TestSupports`
  style utility class) so plain generation yields a valid value everywhere, rather than re-deriving it per test class.
- **a value that needs converting before the assertion** — do not convert. Assert against the shape the SUT already
  returns: iterate the iterator it hands back instead of draining it into a list.
- **the same few setup lines in two tests** — repeat them. Duplication between tests is cheaper than indirection.

Anything genuinely shared across test classes belongs in the module's test-support holder, never as a method on one
test class.

### No shared state between tests

No shared setup or class-level fields. Each test creates its own mocks and SUT inline.

### Constructor injection only

Wire mocks via constructor. No reflection or annotation-driven injection.

When the production constructor hides a collaborator (a no-arg constructor that builds its own dependency), add a package-private constructor that takes the collaborator and keep the test in the same package, so the test injects a double through it — preferred over reflection, field injection, or static mocking.

## Test Method Structure

### Naming

```
{action}Should{expectedResult}When{condition}
```

### Given-When-Then

Each test follows this strict ordering:

1. Given: setup, in four sub-steps with no blank lines between them:
   1. value variables (primitives, strings, enums — anything generated via fixture-monkey / random helpers)
   2. mock declarations (`Type x = mock();` lines, no stubbing yet)
   3. stub setup (`when(...).thenReturn(...)` / `thenThrow(...)`)
   4. SUT construction
2. When: Call exactly one method on the SUT
3. Then: Verify interactions and/or assert return values

The three phases (Given/When/Then) should be visually distinguishable by a blank line between them, without requiring comments to label them. Within Given, do not insert blank lines between the four sub-steps — the blank line is reserved for the phase boundary.

In Then, bind the value under assertion to a named local — conventionally `actual` — before asserting on it. This applies to the SUT's return value, a captured argument, and a helper's result alike, and it applies even when a single field is asserted. Assertions then read as property checks on one named subject rather than re-deriving it each line. Separate the binding from the assertions with a blank line, the same way the phases are separated.

```java
@Test
void processShouldPublishResultCarryingRequestIdWhenInputIsValid() {
    String requestId = UUID.randomUUID().toString();
    Input input = fixtureMonkey.giveMeOne(Input.class);
    Publisher publisher = mock();
    Processor sut = new Processor(publisher);

    sut.process(input, requestId);

    ArgumentCaptor<Result> captor = ArgumentCaptor.forClass(Result.class);
    verify(publisher).publish(captor.capture());
    Result actual = captor.getValue();

    assertThat(actual.requestId()).isEqualTo(requestId);
}
```

## Test Data

Use a test data generator (Fixture Monkey, AutoFixture, faker). Only constrain fields relevant to the test — randomize everything else. Assert against generated values, not hardcoded ones — that is, derive the *expected* side from the generated inputs instead of pinning literals. This does **not** mean asserting the whole value: assert the property that expresses the contract (a size, a key's presence, a single field), and compute its expected form from the generated data. A coarser assertion (e.g. `hasSameSizeAs(input)`) is fine when that property is the contract; do not add finer value checks the contract does not require, especially when they would couple the test to an implementation detail (rounding, truncation, formatting).

Mock return values must also be randomized (UUID, Fixture Monkey, etc.). Extract all values into named variables before mock setup — never inline values inside `given().willReturn()` or `willThrow()`.

## Anti-patterns

- No `test` prefix in method names.
- No fixed exception message strings — couples tests to wording. Assert type only, or type plus a test-injected identifier when multiple paths share the type.
- No fake dressed as a mock: a stub that runs the submitted work, replays a queue, or otherwise simulates the collaborator's behavior. Stub the return value, and if the SUT hands work to a collaborator, capture it and run it in the Then phase where the reader can see it.
