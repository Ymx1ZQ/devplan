# devplan

Unified skill for **Claude Code** and **Codex** that handles the full devplan
lifecycle: planning (`design`) and execution (`TDD` / `IDD`).

One skill, three modes:

- **`design`** — create, extend, or refactor a dev plan. Investigates the
  codebase, proposes milestones in chat, and writes to file only after explicit
  approval.
- **`TDD`** (recommended default) — test-first execution. For each milestone:
  state the requirement, write tests, run them red, implement until green,
  simplify, docs, devplan, commit, and push when the repo/session allows it.
- **`IDD`** — implementation-first execution. For each milestone: implement,
  write tests covering the finished code, simplify, docs, devplan, commit, and
  push when the repo/session allows it. Use for exploratory work.

## Install

One-liner (no clone required):

```bash
bash <(curl -fsSL https://raw.githubusercontent.com/kiso-run/devplan/main/install.sh)
```

Requires `git` and `curl`. To install only one variant, append the target:

```bash
bash <(curl -fsSL https://raw.githubusercontent.com/kiso-run/devplan/main/install.sh) claude
bash <(curl -fsSL https://raw.githubusercontent.com/kiso-run/devplan/main/install.sh) codex
```

From a local clone:

```bash
./install.sh            # install both variants (default)
./install.sh claude     # Claude Code only
./install.sh codex      # Codex only
./install.sh --force    # overwrite existing install without prompting
./install.sh --check    # compare installed copies against the source tree
```

`--check` makes no changes: it reports `OK` or `DRIFT` per variant and
exits non-zero if an installed copy differs from the source (or is
missing) — useful to spot hand-edited installs before they get wiped
by the next `--force`.

The installer copies the skill files into the target tool's skill directory:
- Claude Code: `~/.claude/skills/devplan/`
- Codex: `~/.codex/skills/devplan/`

## Usage

| Tool | Command | What it does |
|---|---|---|
| Claude Code | `/devplan design` | Create or update the dev plan |
| Claude Code | `/devplan TDD` | Execute milestones (test-first) |
| Claude Code | `/devplan IDD` | Execute milestones (implementation-first) |
| Claude Code | `/devplan` | Ask which mode to use |
| Codex | `$devplan design` | Create or update the dev plan |
| Codex | `$devplan TDD` | Execute milestones (test-first) |
| Codex | `$devplan IDD` | Execute milestones (implementation-first) |
| Codex | `$devplan` | Ask which mode to use |

You can also pass a devplan file path directly:

```
/devplan TDD devplan/v0.3.md     # TDD on a specific file
/devplan devplan/v0.3.md         # path alone defaults to TDD
$devplan TDD devplan/v0.3.md     # Codex variant
$devplan devplan/v0.3.md         # Codex variant, path alone defaults to TDD
```

## Devplan format

The executor works best with the structured milestone format produced by
`design` mode:

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

Simpler Markdown plans can still be executed when milestone intent is
unambiguous, but they are not the preferred format for reliable TDD/IDD runs.

## Project layout

```
devplan/
├── README.md          ← you are here
├── install.sh         ← installer script
├── DEVPLAN.md         ← this project's own dev plan
├── tests/             ← installer + lockstep test suites (bash tests/test_*.sh)
├── claude/
│   └── devplan/       ← Claude Code variant (→ ~/.claude/skills/devplan/)
│       ├── SKILL.md   ← router (design / TDD / IDD)
│       ├── DESIGN.md  ← planning playbook
│       ├── TDD.md     ← test-first execution playbook
│       ├── IDD.md     ← implementation-first execution playbook
│       └── README.md  ← variant-specific docs
└── codex/
    └── devplan/       ← Codex variant (→ ~/.codex/skills/devplan/)
        ├── SKILL.md
        ├── DESIGN.md
        ├── TDD.md
        ├── IDD.md
        ├── README.md
        └── agents/
            └── openai.yaml
```

## Per-variant docs

- [Claude Code variant](claude/devplan/README.md)
- [Codex variant](codex/devplan/README.md)

## License

MIT
