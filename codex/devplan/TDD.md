# Devplan Executor — TDD (Test Driven Development) Playbook

## Operating mode

- **Everything is pre-approved.** Never ask for confirmation between
  milestones; run fully autonomously from start to finish.
- Treat the devplan as the source of truth for scope and ordering.
- Work milestone by milestone; do not batch unrelated milestones together.
- Before editing, check the project's instruction files (`CLAUDE.md` —
  root and global — for Claude Code; `AGENTS.md` / `.codex/instructions.md`
  for Codex) plus `README.md` and contributor docs.
- If a milestone is too large → decompose it internally into safe
  substeps and complete them without asking the user to do project
  management.
- If something is ambiguous → pick the most reasonable interpretation
  and proceed.
- Stop and ask the user **only** for real blockers:
  - missing or contradictory devplan requirements
  - changes that would conflict with unknown user work
  - required escalation the environment cannot perform automatically

---

## Preflight (once, before the first milestone)

- **Clean-worktree check.** Run `git status`. If the worktree contains
  uncommitted changes unrelated to this devplan's work, STOP and ask
  the user how to proceed (stash, commit, or include) — this falls
  under the "conflict with unknown user work" blocker. Unrelated work
  must never end up inside a milestone commit.
- **Resume detection.** If a pending milestone already has `[x]` tasks,
  or leftover changes match its scope, a previous run stopped midway.
  Reconcile against the actual code state (verify which tasks are
  truly done), note the resume in the devplan, and continue from the
  real state instead of redoing or skipping work.
- **Commit convention.** Read the repo's commit-message convention from
  recent history (`git log --oneline -20`): milestone-ID prefix style
  (e.g. `M12: title`, `D5-4: title`) and any trailers used
  consistently. Use it for every milestone commit; default to
  `MNN: <title>` if the repo has no clear convention.

---

## Execution loop (repeat for each milestone)

### 1. 📋 Plan & understand the requirement

- Read the current milestone from the devplan.
- Validate that it is executable with high confidence. Prefer milestones
  that include `Why`, `Approach`, `Tasks`, and `Done when`. If the plan
  is simpler, infer the missing structure only when the requirement is
  still unambiguous from the heading and tasks.
- **State the business requirement in your own words** (1-2 sentences).
  What user-visible behavior changes? What contract must hold? If you
  cannot articulate this clearly, the milestone is exploratory — fall
  back to IDD for this milestone (read `IDD.md` and follow it for this
  milestone only) and note the fallback in the devplan with reasoning.
- Identify prerequisites from previous milestones and the current code
  state.
- Announce: *"▶ Milestone X: [name] (TDD)"*

### 2. 🧪 Write tests FIRST

Write tests at all applicable levels (see Test policy below) BEFORE any
implementation. Tests must encode the BUSINESS REQUIREMENT, not the
implementation details.

### 3. 🔴 Run tests — they MUST fail

Run all the runnable tests you just wrote. They MUST fail (red).

If any runnable test passes before implementation, either:
- the test is wrong (it doesn't actually test the new behavior), or
- the behavior already exists (re-evaluate the milestone scope).

Tests that cannot be run locally are exempt from the red check.

### 4. 🛠️ Develop until green

- Implement the minimum code needed to make the failing tests pass.
- Run the relevant tests after each meaningful change.
- Iterate until ALL runnable tests are green.
- Don't over-engineer — simplification comes later.

### 5. ✨ Simplify

- Run `/simplify` if the environment provides it; otherwise do an
  explicit simplification pass on code + tests by hand.
- Structure only, no behavior changes.
- Re-run tests: they must stay green.

### 6. 📝 Update documentation

- Update README, docstrings, diagrams — all reflecting the final code.
- If the milestone adds a public API or interface, document it explicitly.

### 7. 🎯 Verify "Done when"

- Verify the milestone's **Done when** condition explicitly — run the
  command, hit the endpoint, observe the behavior it describes. Green
  tests alone do not count unless the condition says exactly that.
- If the condition cannot be verified locally (needs credentials,
  external services), record precisely what remains to be verified
  manually.

### 8. ✅ Update the devplan

- Mark the milestone as done:
  `- [x] Milestone X: Name ✅`
- Note important deviations, decisions made, and how "Done when" was
  verified.
- Keep the devplan accurate enough that another agent could resume
  from it.
- If you discover the milestone is incomplete or the proposed fix is
  insufficient, update the devplan with the missing work instead of
  silently drifting. Never rewrite completed (`- [x]`) milestones —
  plan corrections land in the pending ones or in a note.

### 9. 📦 Commit & push

- Stage ONLY the files touched by this milestone (explicit paths —
  never `git add -A` / `git add .`).
- Commit following the repo's convention detected in preflight
  (default `MNN: <title>`).
- Push to the active branch when network/auth/repo policy allows it.
- If push or commit requires escalation, authentication, or network
  access not currently available, record the exact blocker in the
  devplan and surface it clearly — then continue with the next
  milestone only if that is safe.
- Never rewrite or discard unrelated user changes.
- Announce: *"✅ Milestone X complete — moving to Milestone Y"* and
  **immediately proceed to the next milestone**.

---

## Test policy

**First run (once per devplan execution):** discover the project's real
test structure. Check:

- `tests/` layout (e.g. `tests/unit/`, `tests/integration/`,
  `tests/live/`, `tests/functional/`, `tests/e2e/`)
- test README or contributor docs
- project scripts (`Makefile`, `package.json`, `justfile`, CI config,
  custom runners) to learn how each level is organized and run

Then apply this rule:

- **Always add unit coverage** for new logic. Cover: happy path, edge
  cases, error cases. Everything external is mocked.
- Add higher-level tests when the milestone changes user-visible
  behavior, cross-module integration, workflows, or recovery paths.
  Prefer the highest already-established level in the repo
  (integration, live, functional, e2e).
- For tests that cannot be run locally (credentials, external services,
  special infrastructure): write them when justified, verify they parse
  (`--collect-only` or equivalent), and note in the devplan that they
  need a manual run.

Avoid overfitting tests to a single prompt or log line. Test the
behavioral class instead.

In TDD mode, write all applicable test levels BEFORE implementation and
confirm the runnable ones fail.

## Implementation standards

- Prefer general runtime fixes over prompt-only tweaks when the failure
  is structurally detectable.
- Avoid special cases that exist only to satisfy one test.
- Keep changes narrow, composable, and reversible.
- Preserve existing user-facing behavior unless the milestone
  explicitly changes it.

---

## Completion

When all milestones are done:

1. Run the broadest local test set that is practical (all levels you
   can run locally) to verify everything works together.
2. Show the final recap:

```
🎉 DevPlan complete!
Mode: TDD
Milestones: X/X ✅
Tests: all green ✅
Documentation: updated ✅

[list of milestones with one-line summary each]
[tests written but not run locally, and why]
[any intentional TODOs, tech debt, or residual risks left behind]
[follow-up work already added back into the devplan]
```

3. Ensure the final completed state has already been committed and
   pushed (or the exact blocker recorded in the devplan).

---

## Rules

- ❌ Never mark a milestone done if its relevant tests are not green
- ❌ Never ask for approval between milestones
- ❌ Never prompt "Do you want to proceed?" — everything is pre-approved
- ❌ Never write the implementation before the tests (this is TDD mode)
- ❌ Do not turn execution into a long planning exercise
- ❌ Do not pretend a vague milestone is TDD-ready; if the contract is
  unclear, either make the scope explicit in the devplan or fall back
  to IDD with a note
- ✅ Runnable tests must FAIL before implementation begins (classic
  TDD red→green)
- ✅ Encode the business requirement in tests, not the implementation
- ✅ Ambiguity → choose and proceed
- ✅ Milestone too large → decompose internally without flagging it
- ❌ Never mark a milestone done without verifying its **Done when**
  condition
- ❌ Never stage with `git add -A` / `git add .` — explicit paths only
- ✅ The devplan is the source of truth — note any deviations in it
- ✅ Match the repo's commit-message convention (detected in preflight)
- ✅ Commit and push after every milestone, always on the current
  active branch
- 🛑 Stop ONLY for blocking errors you cannot resolve autonomously
