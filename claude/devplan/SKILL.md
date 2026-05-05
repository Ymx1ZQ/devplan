---
name: devplan
description: Design or execute a Markdown dev plan. Routes to one of three modes — `design` (create/update the plan), `TDD` (test-first execution, recommended default), or `IDD` (implementation-first execution for exploratory work). Use when the user wants to plan work, or execute an existing DEVPLAN.md milestone by milestone.
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
- no args → ask the user: *"Vuoi `design` (creare/aggiornare il piano)
  o eseguire? Per l'esecuzione: `TDD` (raccomandato) o `IDD`
  (esplorativo)."*

A token is a devplan path if it contains `.md` or `/`.

## Routing

1. Announce the mode at the very start: `Mode: design`, `Mode: TDD`,
   or `Mode: IDD`.
2. Read the corresponding playbook file with the Read tool:
   - design → `DESIGN.md` (in this skill directory)
   - TDD → `TDD.md` (in this skill directory)
   - IDD → `IDD.md` (in this skill directory)
3. Follow that playbook end-to-end. Do not load any other playbook.
