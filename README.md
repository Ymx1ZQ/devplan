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

The installer is multi-assistant. Run it with no target for an
interactive menu, or pass `--target`:

```bash
git clone https://github.com/kiso-run/devplan.git && cd devplan
./install.sh                      # interactive menu
./install.sh --target claude      # ~/.claude/skills/devplan/
./install.sh --target codex        # ~/.codex/skills/devplan/
./install.sh --target opencode     # ~/.config/opencode/skills/devplan/
./install.sh --target gemini        # ~/.gemini/commands/devplan.toml (+ payload)
./install.sh --target agents        # AGENTS.md pointer for Cursor/Windsurf/Copilot/Aider/Continue
./install.sh --target all           # claude + codex + opencode
./install.sh --target manual        # print the folder path; copy it yourself
```

Remote one-liner (no clone; needs `git` + `curl`):

```bash
bash <(curl -fsSL https://raw.githubusercontent.com/kiso-run/devplan/main/install.sh) --target claude
```

`claude`, `codex`, and `opencode` get the `devplan/` folder copied
verbatim — it's the shared [agentskills.io](https://agentskills.io)
`SKILL.md` standard, so one payload serves all three. `gemini` gets a
generated TOML command; `agents` writes an [`AGENTS.md`](https://agents.md)
pointer for the broad tier. Flags: `--force` (overwrite), `--check`
(report `OK`/`DRIFT` vs source, per `--target`), `--agents-dir DIR`.
Or skip the installer — `devplan/` is self-contained, copy it anywhere
your tool reads skills.

## Usage

Invoke however your assistant invokes skills, then pick a mode:

| Assistant | Invocation |
|---|---|
| Claude Code / Codex / opencode | `/devplan design`, `/devplan TDD`, `/devplan IDD`, or `/devplan` |
| Gemini CLI | `/devplan` (installed as a TOML command) |
| Cursor / Windsurf / Copilot / Aider | reference devplan from `AGENTS.md`, then ask |

`design` creates/updates the plan; `TDD` (recommended) and `IDD`
execute it. You can pass a devplan file path directly:

```
/devplan TDD devplan/v0.3.md     # TDD on a specific file
/devplan devplan/v0.3.md         # path alone defaults to TDD
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
├── install.sh         ← multi-assistant installer
├── DEVPLAN.md         ← this project's own dev plan
├── tests/             ← installer test suite (bash tests/test_install.sh)
└── devplan/           ← the flat, assistant-neutral skill payload
    ├── SKILL.md       ← router (design / TDD / IDD)
    ├── DESIGN.md      ← planning playbook
    ├── TDD.md         ← test-first execution playbook
    ├── IDD.md         ← implementation-first execution playbook
    ├── README.md      ← skill payload docs
    └── agents/openai.yaml  ← optional Codex metadata
```

`devplan/` is the whole skill — copy it anywhere your assistant reads
skills, or use `install.sh`.

## Skill docs

- [Skill payload README](devplan/README.md)

## Tests

```bash
bash tests/test_install.sh
```

CI (GitHub Actions) runs this suite on every push and PR.

## License

MIT
