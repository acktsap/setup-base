## Git

- Do not append any AI co-author trailer to commit messages, including `Co-Authored-By: Claude ...` or `Co-Authored-By: Codex ...`. Commit with just the subject and body, with no Claude, Codex, or other AI co-author footer.

## Testing

- When writing unit tests, apply the `write-london-unit-test` skill's rules as you author each test, not as a later pass: default to the minimal set that covers the contract, including each applicable boundary, null/empty case, and error path, and do not add tests or `verify()` calls the skill would consider redundant.

## Code Intent

- When writing or modifying code, treat `clarify-code-intent` as an authoring-time gate, not a cleanup pass: as you write each comment or doc, default to none and add it only if it clears the skill's cut-test: a non-obvious WHY, contract, or constraint that a cold reader cannot recover from the code. This still applies when the mechanics are obvious. Do not write comments the skill lists under "Remove."

## Java Documentation

- When writing or modifying Java, apply the Java documentation skills at authoring time as a default-deny gate: add Javadoc only where the skills call for it: a non-obvious boundary, invariant, contract, or constraint, including the caller-visible contract of published API, SPI, or extension-point elements, such as nullability, threading, ordering, or lifecycle. Keep each doc within that element's own responsibility.
- Package boundaries → `java-package-info-javadoc`.
- Public, interface, SPI, abstract types, factories, or core domain objects → `java-class-javadoc`.
- Public, protected, interface, SPI, extension-point, or complex methods → `java-method-javadoc`.

## Loop

- When `/loop` would offer a cloud-vs-session choice (e.g. interval ≥ 60m), skip that prompt and default to session-only. Set up a cloud/durable schedule only if I explicitly ask for one ("schedule", "cloud", "durable").
