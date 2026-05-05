# Devplan Executor — IDD (Implementation Driven Development) Playbook

## Operating mode

- Treat the devplan as the source of truth for scope and ordering.
- Work milestone by milestone; do not batch unrelated milestones together.
- Be highly autonomous inside the current permissions and repository state.
- In Codex, check repo-local instructions before editing (`AGENTS.md`,
  `.codex/instructions.md`, `README.md`, contributor docs).
- Do not stop for routine confirmations. Stop only for real blockers:
  - missing or contradictory devplan requirements
  - changes that would conflict with unknown user work
  - required escalation the environment cannot perform automatically
- Prefer implementing the next concrete milestone over proposing a plan.

## Execution loop

For each milestone:

1. Read the milestone carefully.
2. Validate that the milestone is executable with high confidence. Prefer
   milestones that include `Why`, `Approach`, `Tasks`, and `Done when`. If the
   plan is simpler, infer the missing structure only when the requirement is
   still unambiguous from the heading and tasks.
3. Identify prerequisites from previous milestones and current code state.
4. Announce the milestone briefly: `▶ Milestone X: [name] (IDD)`.
5. Implement the code.
6. Add or update tests at the right levels (see Test policy). Tests are
   written AFTER the implementation and must PASS immediately.
7. Run the tests you can run locally.
8. Tighten/simplify the implementation if needed without changing behavior.
   Re-run tests after simplification.
9. Update documentation that the milestone affects.
10. Update the devplan checkbox/status and note important deviations.
11. Commit and push if the repository/session allows it.
12. Move directly to the next milestone unless blocked.

## Test policy

Discover the project's real test structure first. Check:

- `tests/` layout
- test README or contributor docs
- project scripts (`Makefile`, `package.json`, `justfile`, CI config, custom runners)

Then apply this rule:

- Always add unit coverage for new logic when unit tests exist.
- Add higher-level tests when the milestone changes user-visible behavior, cross-module integration, workflows, or recovery paths.
- Prefer the highest already-established level in the repo:
  - integration
  - live
  - functional
  - e2e
- If a higher-level test cannot be run locally, still write it when justified, validate collection/parsing if possible, and record that it needs a real run.

Avoid overfitting tests to a single prompt or log line. Test the behavioral class instead.

## Implementation standards

- Prefer general runtime fixes over prompt-only tweaks when the failure is structurally detectable.
- Avoid special cases that exist only to satisfy one test.
- Keep changes narrow, composable, and reversible.
- Preserve existing user-facing behavior unless the milestone explicitly changes it.
- If a milestone is too large, decompose it internally into safe substeps and complete them without asking the user to do project management.

## Devplan updates

After finishing a milestone:

- mark checklist items complete
- add brief notes on key decisions or justified deviations
- keep the devplan accurate enough that another agent could resume from it

If you discover the milestone is incomplete or the proposed fix is insufficient, update the devplan with the missing work instead of silently drifting.

## Git behavior

- Commit after each completed milestone.
- Push after each completed milestone when network/auth/repo policy allows it.
- If push or commit requires escalation, authentication, or network access not currently available, treat that as an operational blocker and surface it clearly.
- Never rewrite or discard unrelated user changes.

The milestone is complete only after:

1. relevant tests were run or accounted for
2. the devplan was updated
3. changes were committed
4. the commit was pushed, or the exact push blocker was recorded clearly

## Completion

When the requested devplan scope is finished:

- run the broadest local test set that is practical
- summarize completed milestones (Mode: IDD)
- report tests run, tests not run, and residual risks
- call out any follow-up work already added back into the devplan
- ensure the final completed state has already been committed and pushed

## Reminders

- Do not turn execution into a long planning exercise.
- Do not mark a milestone done if its relevant tests are still red.
- Do not stop after code changes without checking whether docs/devplan/tests also need updates.
- Do not ignore functional/regression implications when a milestone changes planner, prompts, recovery, or file/workflow behavior.
- Do not use IDD as an excuse for vague scope; the milestone still needs a
  concrete objective and observable completion state.
