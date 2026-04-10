---
name: refactor-align-order
description: Align declaration order across related files so items appear in consistent sequence.
---

`align-order <source-file> <target-file>`

- source-file: the file whose order is the canonical reference
- target-file: the file to reorder

If only one file is given, treat it as the target and infer the source:
- test file → source file is the corresponding production code
- Dockerfile / deploy config → source file is the application config
- implementation → source file is the interface/abstract class

If inference fails, ask the user.

## Items

- An item is a logical declaration unit: function/method, config key, env variable, enum value, etc.
- Each item includes its attached comments, annotations/decorators, and leading blank lines as a single movable block.

## Matching

- Match items between source and target by name, not by position.

## Reorder rules

1. Reorder declarations in the target to mirror the source's order.
2. Only reorder — do not add, remove, or rename anything.
3. Items that exist in the target but not in the source: ask the user where to place each one individually (e.g., keep at original position, move to the end, group before/after a specific item).
4. Items that exist in the source but not in the target: ignore them (do not add).
