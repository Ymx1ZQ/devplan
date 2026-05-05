# devplan — Codex variant

A [Codex](https://openai.com/codex) skill that handles the full devplan
lifecycle: planning (`design`) and execution (`TDD` / `IDD`).

> This is the Codex variant of the unified `devplan` skill.
> See the [project README](../../README.md) for the full picture.

## What it does

When invoked, `devplan` routes to one of three modes:

- **`design`** — creates or updates a dev plan through a structured
  discovery → proposal → approval → write → validation workflow.
- **`TDD` (Test Driven Development) — DEFAULT.** For each milestone:
  state the business requirement → write tests at all applicable levels
  → confirm they fail (red) → implement until green → simplify → docs
  → devplan → commit & push.
- **`IDD` (Implementation Driven Development).** For each milestone:
  implement → write tests covering the finished code → simplify → docs
  → devplan → commit & push. Use when the milestone is exploratory.

In execution modes (TDD/IDD) the skill:

1. Discovers and writes tests at all relevant levels (unit, integration, functional, e2e — whatever the project uses)
2. Tightens/simplifies the implementation without changing behavior
3. Updates documentation
4. Updates the devplan checkboxes
5. Commits and pushes after each milestone
6. Moves immediately to the next milestone without asking

Design mode still waits for explicit approval before writing the devplan file.
Execution modes are highly autonomous, but they still stop on real blockers
(missing requirements, conflicts with unknown user work, repo/session limits,
commit/push/auth issues).

## Requirements

- [Codex](https://openai.com/codex) CLI installed and authenticated
- A project with a `DEVPLAN.md` (or equivalent Markdown plan file)
- Git initialized and a remote configured (for push)
- Any repo-local instructions checked first (`AGENTS.md`, `.codex/instructions.md`,
  project README, contributor docs)

## Installation

Use the installer from the project root:

```bash
./install.sh codex
```

Or manually copy this directory into `~/.codex/skills/devplan/`.

## Skill files

- `SKILL.md` — entry point and router (design / TDD / IDD)
- `DESIGN.md` — planning playbook (discovery, proposal, writing, validation)
- `TDD.md` — Test Driven Development execution playbook (default)
- `IDD.md` — Implementation Driven Development execution playbook
- `agents/openai.yaml` — Codex agent configuration

`SKILL.md` loads only the playbook for the chosen mode, so the agent
follows a single self-contained set of instructions per run.

## Usage

Open Codex in your project directory and invoke:

```
$devplan design                    # create or update a dev plan
$devplan TDD                       # execute the plan (TDD, recommended)
$devplan IDD                       # execute the plan (IDD, exploratory)
$devplan TDD devplan/v0.9-wip.md   # TDD on a specific devplan file
$devplan IDD devplan/v0.9-wip.md   # IDD on a specific devplan file
$devplan devplan/v0.9-wip.md       # path alone → defaults to TDD
$devplan                           # asks which mode to use
```

### Choosing a mode

- **Use `design`** to create a new plan, extend an existing one, or refactor milestones. The skill investigates the codebase, proposes the plan in chat, waits for approval, then writes it.
- **Use `TDD` (default)** for milestones with clear, testable requirements: bug fixes, new features with defined behavior, refactors with preserved contracts.
- **Use `IDD`** for exploratory work where the requirement cannot be stated as a contract upfront: spikes, prototypes, investigations, code archaeology. The skill can also fall back to IDD per-milestone automatically when it cannot articulate the requirement clearly in TDD mode.

### Tips

- Make sure your dev plan has clear, actionable milestones before invoking `TDD` or `IDD`
- Pending milestones should use `- [ ]` checkboxes; completed ones use `- [x]`
- The skill respects your project's existing test structure (unit, integration, e2e, etc.)
- If you need to pause mid-run, just interrupt Codex
- Prefer the structured milestone format shown below; it gives Codex enough
  context to execute without guessing
- Simpler plans can be executed only when the milestone intent is already clear

## Devplan format

The executor is most reliable when each milestone includes explicit intent and
exit criteria. Preferred format:

```markdown
## M12: Add retry handling to webhook delivery

**Why:** Failed deliveries currently require manual recovery. The system should
retry transient failures automatically.

**Approach:** Extend the delivery worker to classify retryable failures, persist
attempt state, and expose retry outcomes in the admin view.

**Tasks:**
- [ ] Persist delivery attempt metadata
- [ ] Retry transient failures with bounded backoff
- [ ] Test: integration — delivery succeeds after a transient failure
- [ ] Update docs/webhooks.md if operator behavior changes
- [ ] Commit & push

**Done when:** A transient network failure is retried automatically and the
relevant tests are green.
```

Simpler Markdown plans with milestone headings and checkboxes can still work,
but only when the milestone requirement is unambiguous enough for TDD/IDD
execution.

## License

MIT
