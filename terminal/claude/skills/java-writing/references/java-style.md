# Java Style

Defer to more-specific package conventions for naming, ordering, formatting, and exceptions.

## Instance and Static Methods

- Keep object responsibilities on instances even without field access. Reserve `static` for class-level behavior such as
  factories, utility operations, constant initialization, and required entry points. Do not make private helpers static
  merely because possible.
- This holds in test code too: a fixture or assertion helper on a test class is an instance method, not
  `private static`. Static *fields* — constants, shared immutable fixtures — stay fine everywhere.
- The exception is a class that exists only as a namespace for static members, such as a per-module `TestSupports`.
  There, every member is static by design; see `utility-class.md`. Put a helper that several test classes share in
  such a holder rather than making it static on one test class.
- Extract a collaborator or value type when a helper becomes independently reusable; do not accumulate static helpers.

```java
final class TextNormalizer {
    String normalize(String input) {
        return input.trim();
    }

    static TextNormalizer create() {
        return new TextNormalizer();
    }
}
```

## Private Helpers

- Keep every method at a single level of abstraction. A helper earns its place by hiding a lower level from its caller —
  naming a mechanism, a classification, or a policy — so the caller reads as one story rather than a mix of what and how.
- Do not extract a helper that sits at the caller's own level. One that only forwards to another call, or whose body reads
  the same as its name, adds indirection without raising the caller.
- A helper that mixes levels itself cannot be named honestly. Needing a name like `doItAndAlsoThat` means the body holds
  two steps that belong to different levels; split them or inline them.
- Prefer restructuring the caller over adding a helper to deduplicate. Merging branches that shared a tail removes the
  duplication and the need for the helper together.
- Do not write Javadoc on private helpers. The name and signature must carry the intent; rename or extract further until
  they do, and use at most a short `//` comment for what still cannot be expressed that way.

```java
// Avoid - same level as the caller, forwarding only.
private void writeBreadcrumbs(HttpServletResponse response, String id, Breadcrumbs breadcrumbs) {
    String filename = "breadcrumbs-%d-%s.txt".formatted(breadcrumbs.logTime(), toFilenameSafe(id));
    writeAttachment(response, filename, TEXT_PLAIN, breadcrumbs.content(), LABEL_BREADCRUMBS);
}

// Prefer - each helper names one lower level, so the caller stays a single story.
try {
    content = client.getObject(bucket, key).getObjectContent();
    return Optional.of(decompressing(content));
} catch (Exception e) {
    if (isAbsent(e)) {
        return Optional.empty();
    }

    release(content);
    throw new ResponseException(ErrorCode.UNEXPECTED_ERROR, e, "failed to retrieve crash event detail");
}
```

## Declaration Order

- Order declarations as constants, other static fields, instance fields, static factories, constructors, other static
  methods, instance methods, and nested types.
- Within each group, order `public`, `protected`, package-private, then `private`. Keep overloads adjacent.
- Keep static factories and constructors together, with static factories first. Do not mix non-factory static methods
  into the construction section.

```java
class Processor {
    public static final int DEFAULT_LIMIT = 100;
    private static int activeCount;
    private final Repository repository;
    private final int limit;

    public static Processor create(Repository repository) {
        return create(repository, DEFAULT_LIMIT);
    }

    static Processor create(Repository repository, int limit) {
        return new Processor(repository, limit);
    }

    Processor(Repository repository, int limit) {
        this.repository = repository;
        this.limit = limit;
    }

    public static boolean supports(Input input) {
        return input != null;
    }

    protected static Input normalize(Input input) {
        return input;
    }

    static boolean hasActiveProcessors() {
        return activeCount > 0;
    }

    private static String keyOf(Input input) {
        return input.toString();
    }

    public Result process(Input input) {
        return load(input);
    }

    protected Result validate(Result result) {
        return result;
    }

    Result preview(Input input) {
        return process(input);
    }

    private Result load(Input input) {
        return repository.load(keyOf(input));
    }

    record State(int count) {
    }
}
```

## Immutability

- Prefer immutable values and state. Defensively copy mutable data inputs that will be retained; local mutation is
  acceptable during construction, but do not publish mutable state.
- Store and return collections as non-null, unmodifiable snapshots. Use `List.copyOf`, `Set.copyOf`, or `Map.copyOf`
  when their null-rejection and iteration-order semantics fit the contract, and use the corresponding `of()` for empty
  results. Copy mutable elements when the snapshot must isolate their state. Expose a live view only when explicitly
  required by the contract.

```java
record Snapshot(List<Item> items) {
    Snapshot {
        items = List.copyOf(items);
    }

    static Snapshot empty() {
        return new Snapshot(List.of());
    }
}
```

## Optional and Null

- Represent expected absence at public or otherwise reusable single-result method boundaries with `Optional`. Do not use
  `Optional` for fields, parameters, or collection results; use an empty collection instead.
- A tightly scoped private helper may return `null` when its caller handles the absence immediately and the value
  does not escape. Make the nullable contract explicit in its name or with the package's established annotation.
- Otherwise, use `null` only when an external API or framework contract explicitly requires it.

```java
Optional<Item> findItem(UUID id) {
    return Optional.ofNullable(findItemOrNull(id));
}

private Item findItemOrNull(UUID id) {
    return items.get(id);
}

@Override
Output transform(Input input) {
    if (shouldDrop(input)) {
        return null; // Framework contract: null drops the input.
    }
    return convert(input);
}
```

## Time and Clock

- Inject `Clock` when current time affects domain state, decisions, or caller-visible output.
  Use that clock consistently within the owning object.
- Direct time access is acceptable for telemetry or framework-local timestamps that are not part of domain behavior.

```java
final class ExpirationPolicy {
    private final Clock clock;

    ExpirationPolicy(Clock clock) {
        this.clock = clock;
    }

    boolean isExpired(Instant expiresAt) {
        return !clock.instant().isBefore(expiresAt);
    }
}
```

## Streams

- Reserve streams, including their lambdas and method references, for side-effect-free transformations that produce
  a new result.
- Use explicit loops for inspection-only queries, mutation or other side effects, early exit, checked exceptions, and
  per-item error handling.
- Format pipelines vertically: put `source.stream()` on the first line and every operation, including the terminal
  operation, on its own line.

```java
List<Result> results = items.stream()
    .filter(Item::isActive)
    .map(this::toResult)
    .toList();
```

## Fluent Chains

- Format multi-call fluent chains (builders, fluent configurers) vertically like stream pipelines:
  the receiver on the first line, every call — including the terminal `.build()` — on its own line.
  Never fold a builder chain onto one line.
- Assign the built value to a named variable instead of nesting the chain inside another call's
  arguments.

```java
Config config = Config.builder()
    .host(host)
    .port(port)
    .build();
Client client = new Client(config);
```

## Loops

- Use enhanced `for` for ordinary iteration, an index-based loop when the index is needed, and an explicit iterator only
  when iterator operations are required. Do not use `Iterable.forEach` or `stream.forEach` for ordinary iteration.

```java
for (var item : items) {
    process(item);
}

for (var i = 0; i < items.size(); i++) {
    process(i, items.get(i));
}

for (var iterator = items.iterator(); iterator.hasNext(); ) {
    if (shouldRemove(iterator.next())) {
        iterator.remove();
    }
}
```

## Guard Clauses

- Prefer guard clauses for invalid, absent, or skipped cases so the normal path remains unnested. Do not add `else`
  after an unconditional `return` or `throw`.
- Keep mutually exclusive semantic classifications in `if`/`else` or `switch` when that structure is clearer;
  this is not a mechanical ban on `else`.

```java
Result process(Item item) {
    if (!item.isEnabled()) {
        return Result.skipped();
    }

    if (!item.isValid()) {
        throw new IllegalArgumentException("Invalid item");
    }

    return transform(item);
}
```

## Nullable Defaults

- When substituting a default for a nullable value, use an explicit `if (value == null)` reassignment
  before use; do not fold the substitution into a ternary.
- The read, the default substitution, any validation of the same value, and the use form one cohesive
  block: no blank lines inside it. Separate the block from surrounding phases with blank lines
  instead; this refines the guard-clause spacing rule for blocks about a single value.

```java
Duration timeout = config.timeout();
if (timeout == null) {
    timeout = DEFAULT_TIMEOUT;
}
this.timeout = timeout;
```

## Vertical Spacing

- Separate distinct logical phases with a blank line. Leave one after a guard clause before the next statement,
  including between consecutive guards.
- Leave a blank line before a final `return` that follows a multi-line computation or control block. Keep cohesive
  statements together, and keep blank lines empty.

```java
Set<String> collectNames(List<Item> items) {
    if (items.isEmpty()) {
        return Set.of();
    }

    Set<String> names = new HashSet<>();
    for (Item item : items) {
        names.add(item.name());
    }

    return Set.copyOf(names);
}
```

## Exception Handling

- Catch an exception only to recover, compensate, perform failure-specific cleanup or failure accounting, or enforce an
  abstraction boundary's failure contract. At that boundary, translate lower-level exceptions, preserve the original
  cause, and let exceptions already valid for the contract propagate unchanged.
- Catch the narrowest relevant type. Catch `Exception` only at a deliberate failure-containment boundary, or to make a
  declared single failure type total, where any other escaping exception would violate the documented contract.
- Handle interruption and cancellation separately from ordinary failures. Propagate them when possible; if
  `InterruptedException` is caught rather than propagated, restore the interrupt status.
- For a non-obvious caller-visible exception contract, apply `java-javadoc`: add `@throws` and describe the triggering
  condition, not just the exception type.

```java
/**
 * @throws LoadException if the content cannot be read
 */
String load(Path path) {
    try {
        return Files.readString(path);
    } catch (IOException e) {
        throw new LoadException("Failed to load content", e);
    }
}
```

## Submitted Tasks

- Submit first, then await. Hold the futures in a plain list in submission order; key them only when a caller consumes
  the key, and do not keep a parallel structure of labels or failures alongside them.
- `Future.get` already surfaces the task's failure. Let it throw instead of collecting failures to rethrow later; add
  aggregation only when the scope must not leave submitted work unobserved, such as during shutdown or when partial
  work is not idempotent.
- Unwrap `ExecutionException` and pass its cause to the translated exception. The wrapper itself carries no information
  a caller can act on.
- Handle `InterruptedException` separately from task failure: restore the interrupt status and propagate.
- Let each task name its own subject in the exception it throws, so the submitter needs no per-task bookkeeping to
  report where the work stopped.

```java
List<Future<?>> submitted = new ArrayList<>();
for (Item item : items) {
    submitted.add(executor.submit(() -> handle(item)));
}

for (Future<?> future : submitted) {
    try {
        future.get();
    } catch (InterruptedException e) {
        Thread.currentThread().interrupt();
        throw new IllegalStateException("Interrupted while handling items", e);
    } catch (ExecutionException e) {
        throw new IllegalStateException("Failed to handle items", e.getCause());
    }
}
```

## Resource Ownership

- Close only resources whose ownership the current scope retains. Treat injected or borrowed resources as non-owned
  unless their contract transfers ownership; release them through the owner's lifecycle or API when required.
- Use try-with-resources when ownership remains within the lexical scope. Give a long-lived owner an explicit lifecycle
  such as `AutoCloseable` or a framework lifecycle, and release every owned resource there according to its lifecycle
  contract.
- Protect resources already acquired if a later acquisition fails, and ensure one close failure does not skip remaining
  owned resources.

```java
final class ArchiveReader implements AutoCloseable {
    private final ZipFile archive;
    private final ExecutorService executor;

    ArchiveReader(Path path, ExecutorService executor) throws IOException {
        archive = new ZipFile(path.toFile());
        this.executor = executor; // Borrowed; its owner manages shutdown.
    }

    @Override
    public void close() throws IOException {
        archive.close();
    }
}
```

## Call Results

- Bind a call's result to a named local before invoking anything on it, whenever the producing call does
  more than navigate — it acquires or opens something, performs I/O, mutates state, or decides which
  instance you get. Chaining collapses two distinct steps into one line, so the acquisition reads as
  incidental to the use and the intermediate value is left unnamed for the debugger and stack trace.
- Chains of plain accessors that only walk an existing structure need no local; naming each hop there adds
  noise without separating any step.

```java
// Avoid - acquiring the range disappears into the read.
var read = openRange().read(bytes, offset, count);

// Prefer - obtain, then use.
var range = openRange();
var read = range.read(bytes, offset, count);

// Fine - navigation only, nothing is acquired or decided.
MessageType schema = reader.getFooter().getFileMetaData().getSchema();
```

## Local Variable Types

- Use explicit local types; allow `var` only in classic and enhanced `for` loop headers.

```java
for (var i = 0; i < count; i++) {
    Result result = loadResult(i);
    results.add(result);
}
```
