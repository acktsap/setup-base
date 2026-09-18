# IntelliJ Setup

- [Keymap](#keymap)
- [Setup](#setup)

## Keymap

`keymaps/macOS copy.xml` is the keymap, linked into every JetBrains IDEA config
directory (`~/Library/Application Support/JetBrains/{IntelliJIdea*,IdeaIC*}/keymaps`).
Edit it in the IDE or in this repo; both sides see the same file.

`setup.sh` also turns off IntelliJ's "safe write"
(`Settings -> Appearance & Behavior -> System Settings`). Safe write saves to a
temp file and renames it over the target, which would replace the symlink with a
plain file on the first settings change.

## Setup

Runs as part of `setup-all.sh`, or on its own:

```shell
./setup.sh
```

Quit IntelliJ first; a running IDE flushes its in-memory settings on exit and
undoes both steps (the script skips itself while the IDE is up).

Every `IntelliJIdea*` / `IdeaIC*` config directory present at run time is
covered, so rerun it after installing a new IDE version. Then pick `macOS copy`
in `Settings -> Keymap` once per version.
