---
name: idea-open
description: Open the current directory or a specified path in IntelliJ IDEA and apply project-local IntelliJ Gradle runner, Gradle JVM, and Project SDK settings. Triggers on "idea-open", "idea로 열어줘", "intellij로 열어줘", "현재 디렉토리 인텔리제이", "open in IDEA", "open in IntelliJ", "jdk21로 idea".
model: haiku
allowed-tools:
  - Bash(pwd)
  - Bash(python3 /Users/user/workspace/git/setup-base/terminal/claude/skills/idea-open/scripts/configure-intellij-project.py *)
  - Bash(test -x /usr/local/bin/idea)
  - Bash(/usr/local/bin/idea *)
---

Open the target directory in IntelliJ IDEA using the JetBrains Toolbox `idea` launcher and make Gradle run/test actions use IntelliJ for Gradle projects.

Run only the allowed commands as separate tool calls. Do not use `Read`, `Edit`, `Write`, `mkdir`, `ls`, `echo`, shell scripts, command separators, command substitutions, pipes, or output redirection; those operations fall outside the skill's allowlist or trigger extra permission prompts.

For Gradle projects, creating or updating `<target-path>/.idea/gradle.xml` and `<target-path>/.idea/misc.xml` before opening is the skill's default behavior. The script owns only this invariant: IntelliJ must load `delegatedBuild=false`, `testRunner=PLATFORM`, the Gradle JVM, the Project SDK, and a root Gradle link from project-local files before it creates run or test configurations. It does not infer Gradle import state, wait for sync, back up `.idea` stubs, or edit existing run configurations. Ask only when the target path or requested JDK name is ambiguous.

IntelliJ's "open in current window or new window" prompt is controlled by the global IDE setting `confirmOpenNewProject2`, not by project files. Do not pass unsupported launcher flags for this. If the user wants the prompt gone, tell them to set IntelliJ's global "Open project in" preference once; in `ide.general.xml`, `confirmOpenNewProject2=0` means new window, `1` means this window, and `-1` means ask.

1. Resolve the target path: use the user-provided path, or run `pwd` and use that exact current directory. Do not switch to the git repo root unless the user explicitly asks.
2. Resolve one Java SDK request from the user's input; otherwise use `jdk21` as the default request. Treat `jdk21`, `jdk-21`, `java21`, and `21` as Java version aliases, not necessarily IntelliJ SDK names. Do not ask separately for the Gradle JVM.
3. Prepare with `python3 /Users/user/workspace/git/setup-base/terminal/claude/skills/idea-open/scripts/configure-intellij-project.py "<target-path>" "<jdk-request>" --phase prepare`. Do not manually create or edit `.idea` files.
4. Read the script's JSON output and use `jdkName` from that output as the actual IntelliJ SDK name. For Gradle projects, `settingsApplied=true` and `preOpenSettingsApplied=true` mean the invariant was applied before opening. For non-Gradle projects, Gradle settings are skipped.
5. Confirm `/usr/local/bin/idea` exists and is executable with `test -x /usr/local/bin/idea`.
6. Open the directory with `/usr/local/bin/idea "<target-path>"`.
7. Do not run a post-open finalize wait. The `finalize` and `apply` phases are compatibility aliases for the same idempotent settings application, not import synchronization.
8. Report the path passed to IntelliJ, the JDK name used, `settingsApplied`, `preOpenSettingsApplied`, and whether Gradle runner, Gradle JVM, and Project SDK settings were applied or skipped. If the user says build or test still runs with Gradle after these settings are applied, tell them to rerun from a source gutter or delete the old Gradle run configuration; existing Gradle run configurations are not converted into IntelliJ/JUnit configurations by changing the project setting.
