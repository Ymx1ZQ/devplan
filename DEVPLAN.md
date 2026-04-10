# devplan — Dev Plan

Unified skill for both **Claude Code** and **Codex** that handles the full devplan lifecycle:
plan creation/maintenance (`design`) and plan execution (`TDD` / `IDD`).

This project replaces the two standalone repos `claude-devplan-executor` and
`codex-devplan-executor` with a single source of truth that ships both variants
plus a shared installer.

## Milestone format

Each milestone uses 4 required sections — **Why**, **Approach**, **Tasks**,
**Done when** — and an optional **Notes** section when something doesn't fit
elsewhere. Every task is a markdown checkbox.

---

## v0.1 — First release

### Phase A — Scaffolding

#### M1: Project skeleton, git init, top-level files ✅

**Why:** A new repo needs a clean foundation before any content lands. Doing the
git init and .gitignore upfront avoids committing junk later and gives every
following milestone a stable place to land.

**Approach:** Create the target-shaped directory tree (`claude/devplan/`,
`codex/devplan/`, `codex/devplan/agents/`). Initialize git. Add a `.gitignore`
that excludes the usual suspects (`.DS_Store`, editor swap files). Add a
placeholder top-level `README.md` (full content lands in M8). No content for
the variants yet — just empty directories ready to receive files.

**Tasks:**
- [x] Create directory tree: `claude/devplan/`, `codex/devplan/`, `codex/devplan/agents/`
- [x] `git init` in `software/skills/devplan/`
- [x] Write `.gitignore` (`.DS_Store`, `*.swp`, `*.swo`, `.idea/`, `.vscode/`)
- [x] Write placeholder `README.md` with title + 1-line description
- [x] Commit (push skipped — no remote, see Notes)

**Done when:** `software/skills/devplan/` exists, is a git repo with one
initial commit, and contains the empty directory tree ready for content.

**Notes:** Executed in IDD mode (TDD fallback) — pure scaffolding has no testable
business contract. `git push` skipped throughout this devplan: the repo is
local-only per the v0.1 out-of-scope (no remote configured).

---

### Phase B — Migrate existing executor into the new structure

#### M2: Migrate Claude variant (TDD.md, IDD.md, README.md) ✅

**Why:** The current Claude executor (`~/.claude/skills/devplan-executor/`) is
already battle-tested. We bring its source files into the new repo unchanged
in behavior, just relocated and renamed for the new package layout. SKILL.md is
intentionally NOT migrated here — it gets rewritten as the new router in M6.

**Approach:** Copy `TDD.md`, `IDD.md`, and `README.md` (source files only, no
`.git`) from `~/.claude/skills/devplan-executor/` into
`claude/devplan/`. Update internal references inside `TDD.md`/`IDD.md` if any
mention the old `devplan-executor` skill name — they should now refer to
`devplan` (with the TDD/IDD mode being one of three router targets). Update
the variant-level `README.md` to reflect the new skill name and the fact that
this is now a sub-document of a unified skill (not a standalone install).

**Tasks:**
- [x] Copy `TDD.md` → `claude/devplan/TDD.md`
- [x] Copy `IDD.md` → `claude/devplan/IDD.md`
- [x] Copy `README.md` → `claude/devplan/README.md`
- [x] Grep both playbooks for `devplan-executor` references and update to `devplan` (none found — clean)
- [x] Update `claude/devplan/README.md`: skill name, install path, link back to project root
- [x] Verify no broken internal links remain
- [x] Commit (push skipped — no remote)

**Done when:** `claude/devplan/` contains TDD.md, IDD.md, README.md with all
references updated to the new skill name.

**Notes:** Executed in IDD mode (TDD fallback). TDD.md and IDD.md had zero
references to `devplan-executor` — they were already self-contained. README.md
was fully rewritten to reflect the new 3-mode routing and unified install.

---

#### M3: Migrate Codex variant (TDD.md, IDD.md, README.md, agents/openai.yaml) ✅

**Why:** Same rationale as M2 but for the Codex variant, which has the
additional `agents/openai.yaml` file. Keeping the two variants in lockstep is
the whole point of this repo — anything we do to Claude we mirror in Codex.

**Approach:** Mirror M2 for the Codex source. Copy the markdown playbooks plus
the `agents/openai.yaml`. Adapt internal references the same way. The
README for the Codex variant keeps Codex-specific terminology
(`$devplan` invocation, `~/.codex/skills/` path).

**Tasks:**
- [x] Copy `TDD.md` → `codex/devplan/TDD.md`
- [x] Copy `IDD.md` → `codex/devplan/IDD.md`
- [x] Copy `README.md` → `codex/devplan/README.md`
- [x] Copy `agents/openai.yaml` → `codex/devplan/agents/openai.yaml`
- [x] Grep both playbooks for `devplan-executor` references and update to `devplan` (none found — clean)
- [x] Update `codex/devplan/README.md`: skill name, install path, link back to project root
- [x] Verify the openai.yaml `name`/`description` fields match the new skill name
- [x] Commit (push skipped — no remote)

**Done when:** `codex/devplan/` contains all 5 files (TDD/IDD/README + agents/openai.yaml)
with all references updated.

**Notes:** Executed in IDD mode (TDD fallback). Same as M2: playbooks had zero
old-name references. Updated `openai.yaml` display_name to "Devplan" and
description/prompt to reflect the 3-mode routing.

---

### Phase C — Build the design playbook

#### M4: Write `DESIGN.md` for the Claude variant ✅

**Why:** The design playbook is the new value this repo brings. It codifies
the user's existing planning workflow (discovery → propose → iterate → write
→ validate) so any session that invokes `/devplan design` follows the same
top-PM approach without needing to be re-explained. Without DESIGN.md the
router has nothing to route to.

**Approach:** Write a single self-contained playbook for Claude Code. Structure
follows the 5 phases agreed in chat:

1. **Discovery** — read CLAUDE.md (root + global), README, docs/, find existing
   devplan files, run `git log -20`, detect stack, identify likely-touched
   files via Grep/Glob. Output a 10-15 line Discovery Brief in chat.
2. **Clarification** — only if real ambiguities exist, ask a max-5 numbered
   list with concrete A/B/C options and a recommended pick. Skip entirely if
   request is clear.
3. **Plan proposal in chat** — emit Obiettivo / Approccio / Rischi / Fasi
   (with milestones grouped) / Out of scope. Wait for explicit approval words
   ("ok", "vai", "scrivi", "procedi"). Never write to file in this phase.
4. **Write to file** — append to current devplan version file (never close or
   create versions without explicit ask). Use the milestone format: **Why /
   Approach / Tasks / Done when** (required) + optional **Notes**. Continue
   numbering from last existing `MNN`. No preparation milestones, no time
   estimates, no code in tasks. Each milestone shippable on its own.
5. **Validation** — re-read the file and self-check: every milestone has the
   4 required sections, every task is actionable, dependencies are ordered,
   numbering is continuous, the plan covers the original request. Auto-correct
   on failure, no confirmation needed.

Plus three implicit modes (`new` / `extend` (default) / `refactor`) detected
from context, and a hard guardrail block (don't touch code, don't modify
`- [x]` milestones, don't estimate time, don't invent requirements, don't
create new versions without ask, but **at ~50 milestones suggest in chat**
that the user may want to close the version — final decision is theirs).

**Tasks:**
- [x] Write `claude/devplan/DESIGN.md` with frontmatter (`name`, `description`)
- [x] Section: Discovery (with explicit list of artifacts to read in parallel)
- [x] Section: Clarification (with the "max 5, concrete options, recommend pick" rules)
- [x] Section: Plan proposal (with the exact chat template: Obiettivo/Approccio/Rischi/Fasi/Out of scope)
- [x] Section: Write rules (numbering continuity, append-only on version files, milestone format, no prep milestones)
- [x] Section: Validation (the self-check list)
- [x] Section: Modes (new / extend / refactor)
- [x] Section: Guardrails (the "never" list + the 50-milestone soft suggestion)
- [x] Section: Sinergia with TDD/IDD (shared milestone format = no translation needed)
- [x] Commit (push skipped — no remote)

**Done when:** `claude/devplan/DESIGN.md` is a complete, self-contained
playbook that a fresh Claude session could follow end-to-end without any
additional context, and any milestone it produces is directly executable by
`claude/devplan/TDD.md` or `IDD.md` without translation.

**Notes:** Executed in IDD mode (TDD fallback) — content authoring, no testable
code. The playbook is ~200 lines, fully self-contained. Dropped frontmatter
(`name`/`description`) as the Claude skill system uses `SKILL.md` for metadata,
not per-file frontmatter — SKILL.md router handles identification.

---

#### M5: Write `DESIGN.md` for the Codex variant ✅

**Why:** Mirror M4 for Codex so both tools have feature parity. Codex users
deserve the same planning quality as Claude users.

**Approach:** Port `claude/devplan/DESIGN.md` to `codex/devplan/DESIGN.md`,
adapting only Codex-specific details: invocation syntax (`$devplan design`
instead of `/devplan design`), tool names (Codex's file/search tools instead
of Claude's Read/Grep/Glob), any frontmatter keys that differ between the two
skill systems. Content and structure stay identical. Update
`agents/openai.yaml` if it needs to register the new playbook entry.

**Tasks:**
- [x] Copy `claude/devplan/DESIGN.md` → `codex/devplan/DESIGN.md` as starting point
- [x] Replace Claude-specific invocation syntax with Codex equivalents
- [x] Replace Claude tool names with Codex tool equivalents
- [x] Update Codex-specific frontmatter if applicable (N/A — no frontmatter used)
- [x] Update `codex/devplan/agents/openai.yaml` if it needs a DESIGN entry (already updated in M3)
- [x] Diff the two DESIGN.md files and confirm only intentional differences exist
- [x] Commit (push skipped — no remote)

**Done when:** `codex/devplan/DESIGN.md` exists with structural and behavioral
parity with the Claude version, only differing where Codex-specific syntax
requires it.

**Notes:** Executed in IDD mode (TDD fallback). Diff shows 7 change blocks, all
intentional: heading style, section naming to match Codex TDD.md conventions,
project docs discovery adapted for Codex instructions format, tool-agnostic
wording for file search, guardrail formatting.

---

### Phase D — Wire the router

#### M6: Rewrite `SKILL.md` as the design/TDD/IDD router (both variants) ✅

**Why:** This is the single entry point users invoke. Until M6 the new
playbooks exist but nothing routes to them. After M6 the skill is functionally
complete: `/devplan` works.

**Approach:** Write a short (~30-40 line) router for each variant. The router
parses the first argument:

- no arg → ask in chat: *"Vuoi `design` (creare/aggiornare il piano) o
  eseguire (`TDD` raccomandato, o `IDD` per esplorativo)?"*. Recommend TDD as
  default execution mode.
- `design` → load DESIGN.md, forward remaining args
- `TDD` → load TDD.md, forward remaining args
- `IDD` → load IDD.md, forward remaining args
- first arg looks like a path (contains `.md` or `/`) → load TDD.md (default)
  pointing at that file
- unknown arg → ask for clarification, do not assume

The router itself never executes work; it just selects and hands off. Each
playbook stays self-contained.

**Tasks:**
- [x] Write `claude/devplan/SKILL.md` router with frontmatter and the 5-branch logic
- [x] Write `codex/devplan/SKILL.md` router (same logic, Codex syntax)
- [x] Verify both routers explicitly recommend TDD as default execution mode
- [x] Verify both routers load only one playbook per invocation (no eager loading)
- [x] Update `codex/devplan/agents/openai.yaml` to point to the new SKILL.md if needed (already done in M3)
- [x] Manual smoke test: invoke each branch mentally against the router text
- [x] Commit (push skipped — no remote)

**Done when:** Both `SKILL.md` files dispatch correctly to design/TDD/IDD,
recommend TDD by default, and load only the playbook needed for the chosen
branch.

---

### Phase E — Distribution

#### M7: Write `install.sh` ✅

**Why:** Without an installer the only way to use the skill is manual copy.
The installer is the user-facing distribution surface and must work for
both variants from a single command.

**Approach:** A POSIX `bash` script at the repo root. Flags:

- `./install.sh claude` → copy `claude/devplan/` → `~/.claude/skills/devplan/`
- `./install.sh codex` → copy `codex/devplan/` → `~/.codex/skills/devplan/`
- `./install.sh all` (default if no arg) → install both
- `--force` → overwrite existing target without prompting
- without `--force`, if target exists, prompt y/N before overwriting

Copy is `cp -r` from local files only, never `git clone`. Script must:
verify source dirs exist before copying, create parent dirs as needed,
print a clear success message with the install path, exit non-zero on any
failure.

**Tasks:**
- [x] Write `install.sh` with the 3 flag modes + `--force`
- [x] Add `set -euo pipefail` and proper error handling
- [x] Add prompt-before-overwrite logic
- [x] Add success/failure messages with absolute paths
- [x] `chmod +x install.sh`
- [x] Manual dry-run test (run with a fake `HOME` to verify it copies into the right place)
- [x] Commit (push skipped — no remote)

**Done when:** Running `./install.sh all` from a clean checkout installs both
variants into `~/.claude/skills/devplan/` and `~/.codex/skills/devplan/` with
correct files and a clear success message.

---

#### M8: Write project-level `README.md` ✅

**Why:** The placeholder from M1 is not enough. The repo needs a real README
that explains what `devplan` is, the three modes, how to install, and links
to the per-variant docs. This is the first thing anyone (including future-you)
sees when they land on the repo.

**Approach:** A single markdown file at repo root. Sections:

- **What is devplan** — 3-4 lines, agnostic of Claude vs Codex
- **Three modes** — `design` / `TDD` / `IDD` with one-line each
- **Install** — `./install.sh all` (and the flag variants)
- **Usage** — `/devplan design`, `/devplan TDD`, `/devplan IDD`, with the
  default-when-no-arg behavior
- **Project layout** — short tree showing `claude/devplan/`, `codex/devplan/`
- **Per-variant docs** — links to `claude/devplan/README.md` and
  `codex/devplan/README.md`
- **License** — MIT (matching the existing executors)

No emoji. No marketing fluff.

**Tasks:**
- [x] Write `README.md` replacing the M1 placeholder
- [x] Include all sections listed above
- [x] Verify all internal links resolve to real files in the repo (13/13 OK)
- [x] Commit (push skipped — no remote)

**Done when:** Repo root `README.md` is the canonical entry point and
correctly describes the project, modes, install, usage, and layout.

---

#### M9: Smoke test & v0.1 tag ✅

**Why:** Before declaring v0.1 done, verify the whole thing actually installs
and routes correctly end-to-end. Tagging v0.1 marks a stable reference point
to install from.

**Approach:** Run `install.sh` against a temp `HOME` (or accept overwriting
the existing `~/.claude/skills/devplan/` after backing it up), then mentally
walk through `/devplan`, `/devplan design`, `/devplan TDD`, `/devplan IDD`
to confirm each branch loads the right file. Fix anything broken. Tag the
final commit as `v0.1`.

**Tasks:**
- [x] Backup existing `~/.claude/skills/devplan-executor/` and `~/.codex/skills/devplan-executor/` if present (skipped — install goes to new `devplan/` path, old `devplan-executor/` is untouched)
- [x] Run `./install.sh all` from the new repo (dry-run with fake HOME)
- [x] Verify all files landed in the right paths with correct contents (Claude: 5 files, Codex: 5 + agents/openai.yaml)
- [x] Mentally smoke-test each router branch (7/7 branches verified)
- [x] Fix any issue found (none found)
- [x] Tag `v0.1`
- [x] Commit (push skipped — no remote)

**Done when:** A fresh install from this repo produces a working `/devplan`
skill in both Claude Code and Codex, all router branches dispatch correctly,
and the repo has a `v0.1` tag.

---

### Phase F — Refinement

#### M10: Refine DESIGN.md — adaptive discovery, scalable proposal, pending check, precise clarification, codebase-aware validation ✅

**Why:** The v0.1 DESIGN.md works but has 5 weaknesses identified during
review: discovery runs 6 mandatory steps regardless of request size, the
proposal template is heavy for small tasks, extend mode silently ignores
pending milestones, clarification triggers are vague, and validation only
checks form (not substance). Fixing these makes the playbook proportional
to the work and catches real planning errors.

**Approach:** Edit both `claude/devplan/DESIGN.md` and `codex/devplan/DESIGN.md`
in-place. All 5 fixes modify existing sections — no new sections added, the
playbook stays at 5 phases. Changes:

1. **Phase 1 (Discovery):** Add a scale assessment step at the top (small /
   medium / large based on expected milestone count). The 6 discovery sources
   become a catalog — the skill picks only those relevant to the scale. The
   Discovery Brief shrinks proportionally (3-4 lines for small, 10-15 for
   large).

2. **Phase 2 (Clarification):** Replace "real ambiguities" with a concrete
   criterion: ask only when the answer changes the **structure** of the plan
   (number of milestones, modules involved, architectural approach). If it
   only changes an implementation detail, don't ask — the executor decides.

3. **Phase 3 (Proposal):** Add a lightweight template for 1-2 milestone plans
   (just `MNN: title — rationale`, no Obiettivo/Approccio/Rischi/Out of scope
   wrapper). Keep the full template for 3+ milestones.

4. **Phase 4 (Write):** In extend mode, before proposing, count pending
   `- [ ]` milestones. If any exist, report them in chat and ask whether the
   new milestones depend on the pending ones or are independent. Don't block —
   inform and let the user decide.

5. **Phase 5 (Validation):** Add 3 substance checks after the existing form
   checks: (a) files cited in Approach/Tasks exist in the repo or are created
   by a prior milestone, (b) milestones touching the same module are ordered
   sensibly, (c) plan respects project conventions from CLAUDE.md / project
   instructions. If a check fails: auto-correct if possible, otherwise add a
   Notes warning to the milestone.

**Tasks:**
- [x] Update Phase 1 in `claude/devplan/DESIGN.md`: add scale assessment, make sources a catalog not a checklist, scale the Discovery Brief
- [x] Update Phase 2 in `claude/devplan/DESIGN.md`: replace "real ambiguities" with the structural-impact criterion
- [x] Update Phase 3 in `claude/devplan/DESIGN.md`: add lightweight template for 1-2 milestone plans
- [x] Update Phase 4 in `claude/devplan/DESIGN.md`: add pending milestone check in extend mode
- [x] Update Phase 5 in `claude/devplan/DESIGN.md`: add 3 codebase-coherence checks
- [x] Port all 5 changes to `codex/devplan/DESIGN.md`
- [x] Diff both DESIGN.md files and confirm only intentional differences exist (same 7 blocks as before, all intentional)
- [x] Commit (push skipped — no remote)

**Done when:** Both DESIGN.md playbooks scale discovery and proposal to the
request size, warn about pending milestones before extending, ask clarification
only for structure-changing ambiguities, and validate plan coherence against
the actual codebase — not just format.

---

## Out of scope for v0.1

- Publishing to a public GitHub repo (local-only for now)
- CI / automated tests for the installer
- A `devplan uninstall` command
- Support for skill systems other than Claude Code and Codex
- Auto-update mechanism
- Telemetry of any kind
