# devplan — Claude Code variant

A [Claude Code](https://claude.ai/code) skill that handles the full devplan
lifecycle: planning (`design`) and execution (`TDD` / `IDD`), fully
autonomously — no interruptions, no confirmation prompts.

> This is the Claude Code variant of the unified `devplan` skill.
> See the [project README](../../README.md) for the full picture.

## What it does

When invoked, `devplan` routes to one of three modes:

- **`design`** — creates or updates a dev plan through a structured
  discovery → proposal → write → validation workflow.
- **`TDD` (Test Driven Development) — DEFAULT.** For each milestone:
  state the business requirement → write tests at all applicable levels
  → confirm they fail (red) → implement until green → simplify → docs
  → devplan → commit & push.
- **`IDD` (Implementation Driven Development).** For each milestone:
  implement → write tests covering the finished code → simplify → docs
  → devplan → commit & push. Use when the milestone is exploratory.

In execution modes (TDD/IDD) the skill:

1. Discovers and writes tests at all relevant levels (unit, integration, functional, e2e — whatever the project uses)
2. Simplifies code and tests without changing behavior (via `/simplify` when available)
3. Updates documentation
4. Updates the devplan checkboxes
5. Commits and pushes after each milestone
6. Moves immediately to the next milestone without asking

It stops only on unresolvable blocking errors.

## Requirements

- [Claude Code](https://claude.ai/code) CLI installed and authenticated
- A project with a `DEVPLAN.md` (or equivalent Markdown plan file)
- Git initialized and a remote configured (for push)

## Installation

Use the installer from the project root:

```bash
./install.sh claude
```

Or manually copy this directory into `~/.claude/skills/devplan/`.

Claude Code auto-discovers skills in `~/.claude/skills/`. No extra configuration needed.

## Skill files

- `SKILL.md` — entry point and router (design / TDD / IDD)
- `DESIGN.md` — planning playbook (discovery, proposal, writing, validation)
- `TDD.md` — Test Driven Development execution playbook (default)
- `IDD.md` — Implementation Driven Development execution playbook

`SKILL.md` loads only the playbook for the chosen mode, so the agent
follows a single self-contained set of instructions per run.

## Usage

Open Claude Code in your project directory and run:

```
/devplan design                    # create or update a dev plan
/devplan TDD                       # execute the plan (TDD, recommended)
/devplan IDD                       # execute the plan (IDD, exploratory)
/devplan TDD devplan/v0.9-wip.md   # TDD on a specific devplan file
/devplan IDD devplan/v0.9-wip.md   # IDD on a specific devplan file
/devplan devplan/v0.9-wip.md       # path alone → defaults to TDD
/devplan                           # asks which mode to use
```

### Choosing a mode

- **Use `design`** to create a new plan, extend an existing one, or refactor milestones. The skill investigates the codebase, proposes the plan in chat, waits for approval, then writes it.
- **Use `TDD` (default)** for milestones with clear, testable requirements: bug fixes, new features with defined behavior, refactors with preserved contracts.
- **Use `IDD`** for exploratory work where the requirement cannot be stated as a contract upfront: spikes, prototypes, investigations, code archaeology. The skill can also fall back to IDD per-milestone automatically when it cannot articulate the requirement clearly in TDD mode.

### Tips

- Make sure your dev plan has clear, actionable milestones before invoking `TDD` or `IDD`
- Pending milestones should use `- [ ]` checkboxes; completed ones use `- [x]`
- The skill respects your project's existing test structure (unit, integration, e2e, etc.)
- If you need to pause mid-run, just interrupt Claude Code (`Ctrl+C`)

## Devplan format

The skill works with any Markdown file that has milestone headings and checkbox task lists. A minimal example:

```markdown
# My Project Dev Plan

## M1: Add user authentication
- [ ] Implement login endpoint
- [ ] Add JWT token generation
- [ ] Write unit tests

## M2: Add password reset flow
- [ ] Send reset email
- [ ] Implement token validation
```

No specific format is required beyond readable headings and checkboxes.

## License

MIT
