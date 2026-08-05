# Remote Client Methods

Read this for a method that calls a remote endpoint on a caller's behalf.

- Enforce the endpoint's documented request limits locally, before issuing the request, so a caller that exceeds one
  fails with a message naming the limit instead of receiving the remote rejection.
- Verify that the response answers the request before returning it, comparing identity and order rather than count. A
  same-size response with substituted or reordered entries passes a count check.
- Never let a missing entry read as a value. Where absence and a meaningful value share a representation, a truncated or
  partially failed response is indistinguishable from a real answer.
- Substitute an empty collection for an absent payload and let that verification reject it; do not return it.
- Pass the remote representation through unchanged. Interpreting it needs context the client does not have.
- Declare one failure type for the operation and make it total: rethrow that type unchanged so its message survives, and
  translate every other exception with the cause attached.
- Document the limits, the ordering guarantee, and the failure condition, per `java-javadoc`. They are caller-visible
  contract rather than implementation detail.

```java
/**
 * One entry per requested key, in request order, for at most {@link #MAX_CHUNK_SIZE} keys.
 *
 * @throws IllegalArgumentException if the chunk is empty or holds more than {@link #MAX_CHUNK_SIZE} keys
 * @throws IllegalStateException if the request fails, or the response does not echo every requested key in order
 */
List<Entry> findEntries(List<String> keys) {
    if (keys.isEmpty() || keys.size() > MAX_CHUNK_SIZE) {
        throw new IllegalArgumentException("keys must hold 1 to %d, but held %d"
            .formatted(MAX_CHUNK_SIZE, keys.size()));
    }

    try {
        Envelope<List<Entry>> response = fetch(keys);
        List<Entry> entries = Optional.ofNullable(response)
            .flatMap(Envelope::payload)
            .orElseGet(List::of);
        List<String> answered = entries.stream()
            .map(Entry::key)
            .toList();
        if (!answered.equals(keys)) {
            throw new IllegalStateException("Lookup must echo every requested key in order, got %s for %s: %s"
                .formatted(answered, keys, response));
        }

        return entries;
    } catch (IllegalStateException e) {
        throw e;
    } catch (Exception e) {
        throw new IllegalStateException("Lookup failed for %d keys".formatted(keys.size()), e);
    }
}
```
