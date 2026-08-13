---
name: write-repo-readme
description: Write or update a repository root README that maps the top-level directories. Triggers on "루트 README", "repo README", "저장소 README", "디렉토리 역할 설명", "write-repo-readme".
---

`write-repo-readme` (repo root)

A root README answers one question: which directory do I go to.

1. `ls` the top level. Pick the few directories a newcomer must tell apart, usually 3 to 5.
2. One line each: what it is for, not what is inside it.
3. Show the draft before writing.

## Rules

- Roles only. No file lists, subdirectory enumerations, make targets, or config keys — contents move, roles do not.
- One line per directory. Needs a paragraph → needs its own README.
- No usage instructions. Commands belong to the README that owns them.
- Name a specific child only if there will only ever be one; otherwise "one directory per X".
- Every path must resolve. Verify with `ls` — a dead path is the usual defect here.
- Whole file under ~15 lines.
- Module-level README → use `write-module-readme` instead.
