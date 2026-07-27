---
name: idea-open
description: Open the current directory or a specified path in IntelliJ IDEA and apply project-local IntelliJ Gradle runner, Gradle JVM, and Project SDK settings. Triggers on "idea-open", "idea로 열어줘", "intellij로 열어줘", "현재 디렉토리 인텔리제이", "open in IDEA", "open in IntelliJ", "jdk21로 idea".
model: haiku
allowed-tools:
  - Bash(idea-open)
  - Bash(idea-open:*)
---

Open the target directory in IntelliJ IDEA by running the `idea-open` command, which applies the project-local Gradle runner, Gradle JVM, and Project SDK settings before launching.

`idea-open` owns everything except argument selection. Do not use `Read`, `Edit`, `Write`, `pwd`, `mkdir`, `ls`, `test`, command separators, command substitutions, pipes, or output redirection; those fall outside the allowlist or duplicate what the command already does.

1. Resolve the target path: use the user-provided path, or omit the argument entirely so `idea-open` resolves the current directory itself. Do not switch to the git repo root unless the user explicitly asks.
2. Resolve one Java SDK request from the user's input; otherwise omit the argument so the `jdk21` default applies. Treat `jdk21`, `jdk-21`, `java21`, and `21` as version aliases — `idea-open` maps them to a registered IntelliJ SDK name. Do not ask separately for the Gradle JVM.
3. Run `idea-open [<target-path>] [<jdk>]` as a single call. Add `--no-open` only when the user wants settings applied without launching the IDE. Ask only when the target path or requested JDK is ambiguous.
4. Report the command's output as-is: resolved target, SDK name it settled on, and whether `.idea/gradle.xml` and `.idea/misc.xml` were created, updated, or skipped. A non-Gradle project skips the settings step by design.

If the command exits non-zero for an unmatched JDK, it lists the registered IntelliJ SDK names — offer one of those instead of guessing.

Two things the command cannot do, worth telling the user directly:

- The "open in current window or new window" prompt is a global IDE setting, not a project one. In `ide.general.xml`, `confirmOpenNewProject2` of `0` means new window, `1` means this window, and `-1` means ask.
- Existing Gradle run configurations are not converted to IntelliJ/JUnit ones by changing the project setting. If build or test still runs through Gradle afterwards, rerun from a source gutter or delete the stale run configuration.
