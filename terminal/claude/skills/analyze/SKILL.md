---
name: analyze
description: Analyze codebase for context understanding. Use when starting work on a new codebase or exploring unfamiliar code.
---

Analyze the codebase to build working context. Focus on what's needed to effectively contribute.

## Pre-Analysis

1. **Check existing context first** - Read CLAUDE.md, README.md, and memory files before analyzing. Skip sections already well-documented.
2. **Determine depth** - If the user specifies a scope (e.g., a specific module or feature), focus analysis there. Otherwise, do a full sweep.
3. **Use parallel exploration** - For large codebases, use the Explore agent in parallel to cover different areas (e.g., one for project structure, one for dependencies, one for conventions).

## Analysis Framework

### 1. Architecture Overview
- Project structure and organization pattern (monorepo, microservice, library, etc.)
- Entry points and main execution flow
- Key directories and their responsibilities

### 2. Tech Stack & Dependencies
- Languages, frameworks, and major libraries
- Build system and tooling
- External services or APIs

### 3. Code Conventions
- Naming patterns (files, functions, variables)
- Code organization style
- Error handling approach
- Testing patterns if present

### 4. Key Abstractions
- Core data structures and models
- Important interfaces or base classes
- Shared utilities and helpers

### 5. Working Notes
- Non-obvious gotchas or quirks
- Areas of complexity to be aware of
- Implicit assumptions in the code

## Output Format

Use concise bullet points. Prioritize actionable insights over exhaustive documentation.
Structure output so it can be quickly scanned when returning to the codebase later.

## Save Results

After analysis, save key findings to the project's memory directory (e.g., `memory/codebase.md`).
- Only save stable, verified facts — not speculative observations.
- Update existing memory files if they already exist rather than creating duplicates.
- This allows future sessions to skip re-analysis.
