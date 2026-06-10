---
name: devplan
description: Design or execute a Markdown dev plan. Routes to one of three modes — `design` (create/update the plan), `TDD` (test-first execution, recommended default), or `IDD` (implementation-first execution for exploratory work). Use when the user wants to plan work, or execute an existing devplan milestone by milestone with strong autonomy.
---

# Devplan — Router

This skill has three modes:

- **`design`** — create, extend, or refactor a dev plan. Investigates
  the codebase, proposes milestones in chat, writes to file only after
  approval.
- **`TDD` (Test Driven Development) — RECOMMENDED DEFAULT.** Write
  tests first based on the business requirement, run them red, implement
  until green, simplify, docs, devplan, commit & push. Use for
  milestones with clear, testable requirements.
- **`IDD` (Implementation Driven Development).** Implement first, write
  tests covering the finished code, simplify, docs, devplan, commit &
  push. Use for exploratory work (spikes, prototypes, investigations).

## Scope

This skill covers ALL code changes — features, refactors, AND bug fixes.
Bug fixes are not exempt from the devplan workflow. A bug fix is a small
plan (`design` mode detects this automatically via scale assessment).
The rule is: investigate freely, but write to devplan and get approval
before changing any code.

## Mode selection

Parse the first token of the args:

- `design` or `design <description>` → design mode
- `TDD <devplan-path>` → TDD mode
- `IDD <devplan-path>` → IDD mode
- `<devplan-path>` (path alone, no mode token) → TDD (default)
- no args → ask the user, in their language, whether they want
  `design` (create/update the plan) or execution — `TDD` (recommended)
  or `IDD` (exploratory)

A token counts as a devplan path if any of these are true:

- it contains `/`
- it ends with `.md` or `.markdown` (case-insensitive)
- its basename starts with `DEVPLAN` (case-insensitive)

If the token is ambiguous, prefer asking once rather than silently
routing to the wrong mode.

## Language

Chat interactions (questions, proposals, recaps) happen in the user's
language. Devplan **file** content is written in English — unless the
project's existing devplan already uses another language, in which
case match it.

## Routing

1. Announce the mode at the very start: `Mode: design`, `Mode: TDD`,
   or `Mode: IDD`.
2. Read the corresponding playbook file (in this skill directory):
   - design → `DESIGN.md`
   - TDD → `TDD.md`
   - IDD → `IDD.md`
3. Follow that playbook end-to-end. Do not load any other playbook
   unless the chosen playbook explicitly instructs a per-milestone
   fallback.
