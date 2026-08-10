# Java Unit Tests

Read this after `write-london-unit-test`; it adds only Java test-data and assertion conventions.

## Generated Test Data

- When Fixture Monkey is available, use it for structured objects and collections. Generate valid values, constrain only
  scenario-defining fields and relationships, and leave unrelated attributes randomized.
- Express constraints with `giveMeBuilder`, `set`, `setLazy`, `setPostCondition`, and `setInner`.
- Prefer refactor-safe selectors such as `javaGetter(Type::property)` for object properties. Use `TypeReference` and
  `InnerSpec` for generic containers and their entries.
- Generate standalone scalars with an appropriate source such as `UUID` or `ThreadLocalRandom`.
- Use fixed literals, including stub returns, only when the exact value is the contract: boundaries, protocol constants,
  and known-answer cases.

## Property-Oriented Assertions

- Keep ordinary JUnit `@Test` methods; do not introduce jqwik `@Property`, `@ForAll`, or `@Provide`.
- Derive expected results from generated inputs and assert the smallest relationship or invariant that should hold for
  any allowed generated value.
- Constrain required validity and categories instead of relying on chance.
- Keep explicit tests for null, empty, boundary, branch, and error cases. Random generation complements rather than
  replaces contract partitions.

## Assertions

- Use AssertJ when it can express the contract.

## Comments

- Default to no comment on a test. The method name states the scenario and the expected outcome, and the body shows the
  setup; a Javadoc or inline comment that retells either is restatement even when it rewords it.
- Motivation is restatement too. Why the asserted outcome matters, what would break otherwise, and what bug the test
  guards belong in the name, or in the contract doc of the code under test — not in prose above the test.
- When a comment feels necessary, the usual cause is a name that stops at the action. Extend the name to carry the
  condition and the outcome instead of adding prose.

  ```java
  // Avoid - the comment carries what the name omitted.
  /** A zero-padded tail would decode as a silently truncated page, so a short write must not pass. */
  @Test
  void decompressShouldFail() {

  // Prefer - the name carries it.
  @Test
  void decompressShouldFailWhenThePageDecompressesToFewerBytesThanDeclared() {
  ```

- Comment a test only for what neither the name nor the body can carry: a ticket or spec that fixed an expected literal,
  or why the test is shaped oddly (a sleep, an ordering dependency, a skip condition, a deliberately degraded double).
- Test support types — fixtures, builders, fakes, custom doubles — follow the production rules in `java-javadoc`, since a
  reader meets them without a test name to explain them.
