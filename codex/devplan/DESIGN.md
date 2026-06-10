# Dev Plan — Design Playbook

You are in **design mode**. Your job is to create, extend, or refactor a
dev plan — NOT to implement code. You investigate, propose, iterate, and
write milestones. You never touch application code.

---

## General Behavior

- **Never write to the devplan file without explicit approval.** Propose
  in chat first, iterate with the user, write only on an explicit
  go-ahead in the user's language (e.g. "ok", "go ahead", "write it",
  "vai", "procedi").
- If something is ambiguous, ask — but offer concrete options, not open
  questions.
- Stop and ask the user only for genuine blockers or decisions you
  cannot make with confidence.
- **Plan on verified facts, not assumptions.** If a milestone depends on
  how a file, mechanism, or API behaves ("X auto-binds", "the hook applies
  Y", "this is already filtered"), CONFIRM it during discovery — read the
  code, don't guess. A wrong load-bearing assumption silently corrupts
  every milestone built on it. When you can't verify, mark it explicitly
  as an assumption to check, never as fact.

---

## Mode Detection

Detect which mode applies based on current state. Do not ask the user
to choose — infer from context:

| Condition | Mode |
|---|---|
| No devplan file exists in the project | **new** |
| Devplan exists and the user describes new work to add | **extend** (default) |
| User explicitly asks to revise, split, reorder, or refactor existing milestones | **refactor** |

In `new` mode, create the devplan file structure before proceeding.
In `extend` mode, append to the current version file.
In `refactor` mode, show a diff-style preview in chat before writing.

---

## Execution — 5 Phases

### Phase 1: Discovery

Before proposing anything, assess the **scale** of the request and
gather context proportionally.

#### Scale assessment

Estimate the likely number of milestones from the request:

| Scale | Expected milestones | Discovery depth |
|---|---|---|
| **Small** (bug fix, tweak, single change) | 1-2 | Minimal: devplan state + files directly involved |
| **Medium** (feature, multi-step change) | 3-5 | Moderate: add relevant docs, git context, test inventory |
| **Large** (refactor, new area, cross-cutting) | 6+ | Full: all sources below |

#### Discovery sources (catalog — use what the scale needs)

1. **Devplan state** — find existing devplan files (`DEVPLAN.md`,
   `devplan/`, `devplan/v*.md`). Identify: current version file, last
   milestone number (MNN), convention style, how many milestones exist.
   *(always needed)*
2. **Surface area** — grep/glob for files likely touched by the
   request. Use terms from the user's description.
   *(always needed)*
3. **Project docs** — read the project's instruction files
   (`CLAUDE.md` — root and global — for Claude Code; `AGENTS.md` /
   `.codex/instructions.md` for Codex), `README.md`, and any docs
   relevant to the request (e.g. `docs/architecture.md`,
   `docs/data-model.md`). *(medium+ scale)*
4. **Git context** — `git log --oneline -20`, `git status`, current
   branch. *(medium+ scale)*
5. **Test inventory** — scan for test directories and levels (unit,
   integration, e2e, etc.). Note the runner and structure.
   *(medium+ scale, or if the request is test-related)*
6. **Stack detection** — identify the tech stack from manifest files
   (package.json, pyproject.toml, Cargo.toml, etc.).
   *(large scale, or if unfamiliar with the project)*
7. **Workspace detection** — if the working directory contains multiple
   git checkouts (sibling-repo workspace), enumerate them, confirm with
   the user which repos are in scope, and locate where the devplan
   lives (it may sit in one repo while planning work across several).
   *(when the request spans more than one repo)*

#### Output: Discovery Brief

Write a brief in chat, scaled to the request:
- **Small:** 3-5 lines — devplan state, files involved, done.
- **Medium:** 6-10 lines — add context on conventions and test structure.
- **Large:** 10-15 lines — full context including stack, architecture,
  and git state.

Example (medium):

> *Nuxt+FastAPI repo, current devplan `devplan/v0.3.md`, last
> milestone M47 (auth refactor, completed). Commit convention:
> `MNN: title`. Tests: pytest unit/integration + Playwright e2e. The
> request likely touches `backend/app/api/billing.py` and
> `frontend/pages/checkout.vue`. No work in progress on those files
> (clean git status).*

This brief proves you understood the context before proposing the plan.

---

### Phase 2: Clarification

After discovery, identify ambiguities that affect the **structure** of
the plan. Ask only when the answer changes:

- **How many milestones** (e.g. "all in one or split auth and authz?")
- **Which modules are involved** (e.g. "backend only or also frontend?")
- **Which architectural approach** (e.g. "new endpoint or extend existing?")

**Do NOT ask** when the answer only affects implementation details
(naming, test placement, variable choices) — the executor decides those.

If structural ambiguities exist (max 3-5), present each as:

```
1. <question>
   (A) <option> — <1-line reason>
   (B) <option> — <1-line reason>
   → recommend <letter>: <why>
```

**If the request is already clear, skip this phase entirely.** Do not
ask questions for the sake of asking.

---

### Phase 3: Plan Proposal (in chat, NOT on file)

Choose the template based on how many milestones the plan needs.

#### Small plans (1-2 milestones)

```markdown
## Plan
- MNN: <title> — <rationale, 1-2 lines>
- MNN+1: <title> — <rationale, 1-2 lines>   (if needed)
```

No Objective/Approach/Risks/Out-of-scope wrapper — the milestone
rationale is sufficient context for small work.

#### Medium and large plans (3+ milestones)

```markdown
## Objective
1-2 lines: what we are doing and why (the business/tech "why")

## Approach
3-5 lines: the chosen technical strategy, and why it won over the
alternatives considered. Explicit trade-offs if any.

## Risks
Concise list of what can go wrong and how we mitigate it
(or what we accept as risk).

## Phases
### Phase A — <short name>
- MNN: <title> — <rationale, 1 line>
- MNN+1: <title> — <rationale, 1 line>

### Phase B — <short name>
- MNN+2: ...

## Out of scope
What this plan explicitly does NOT do (to prevent scope creep).
```

Present the proposal in the user's language (per the Language rule in
`SKILL.md`); the structure above is what matters, not the literal
section titles.

**Wait for the user's approval before writing anything to file.**
Iterate on the proposal if the user gives feedback. Only proceed to
Phase 4 when they explicitly approve.

---

### Phase 4: Write to Devplan File

After approval, write the milestones to the devplan file following
these rules:

#### Pending milestone check (extend mode only)

Before writing new milestones, count existing `- [ ]` (pending)
milestones in the target file. If any exist, report them in chat
before proceeding:

> *"There are N pending milestones (MNN-MNN+K). Do the new milestones
> depend on them, or are they independent?"* (in the user's language)

Do not block — inform and let the user decide. If the user confirms
independence, append normally. If there are dependencies, ensure the
new milestones come after the pending ones they depend on.

#### File location
- **`new` mode:** create `DEVPLAN.md` at the project root (or a
  `devplan/v0.1.md` if the project uses versioned devplan files).
- **`extend` mode:** append to the current version file. Never close
  a version or create a new version file without explicit user request.
- **`refactor` mode:** edit in-place. The diff was already approved in
  Phase 3.

#### Numbering
- Follow the target file's **existing milestone ID scheme** (e.g.
  `M12`, `D5-4`, `SEC-3`) — read the last ID and continue it. `MNN`
  is the default for new files, not a mandate over an established
  convention.
- Continue from the last ID. Never reset numbering.
- If the file is empty or new, start from `M1`.

#### Milestone format

```markdown
## MNN: <title — concise, imperative verb>

**Why:** 1-2 sentences on the motivation (business or technical).
What changes for whom.

**Approach:** 2-4 sentences on the technical strategy. Which files or
modules are touched. Key design decisions.

**Tasks:**
- [ ] Task 1 (verb + object, atomic)
- [ ] Task 2
- [ ] Test: <level> — <what to verify>
- [ ] Update docs/<file>.md if API/contract changes
- [ ] Commit & push

**Done when:** One concrete, observable exit condition (test green,
endpoint responds, UI shows X).
```

Optional fifth section — **Notes:** — only when something doesn't fit
elsewhere (gotchas, external links, decisions to revisit later).

#### Granularity rules
- Each milestone must be **shippable**: commit + push without breaking
  main.
- Each milestone must be **session-sized**: executable in one focused
  session (roughly 30min-2h of work). Larger → split. Smaller →
  merge with neighbor.
- Dependencies must be resolved in order: MNN cannot depend on MNN+2.
- **No "preparation milestones"** (e.g. "M48: setup folder
  structure"). Scaffolding belongs inside the milestone that uses it.
  Every milestone must produce observable value.
- **No code in tasks.** Tasks describe *what* to do, not *how*. The
  "how" lives in the Approach section.
- **No time estimates.** Ever.

#### Version management
- When the current version file reaches approximately 50 milestones,
  **suggest in chat** that the user may want to close this version and
  open a new one. Frame it as a suggestion, not a decision: *"The file
  has ~50 milestones — do you want to close this version and open a new
  one (e.g. v0.4.md), or keep going here?"*. The user decides.
- Never close a version or create a new version file on your own.

---

### Phase 5: Validation

After writing, re-read the devplan file and run a self-check.

#### Form checks
- Every milestone has **Why**, **Approach**, **Tasks**, **Done when**
- Every task is actionable (not vague like "improve X" or "handle Y")
- Dependencies are resolved in order (no forward references)
- Numbering is continuous from the last existing MNN
- The plan covers all requirements from the original request
- No preparation-only milestones exist

#### Codebase coherence checks
- **Files exist:** every file cited in Approach or Tasks exists in the
  repo, or is explicitly created by a prior milestone in the plan. If a
  milestone says "modify billing.py" but that file does not exist and no
  earlier milestone creates it, flag and correct.
- **Module ordering:** if multiple milestones touch the same module or
  file, verify the order makes sense (no milestone overwrites or
  contradicts a later one's assumptions).
- **Convention compliance:** if the project has documented conventions
  (CLAUDE.md, .codex/instructions.md, README), verify the plan respects
  them (e.g. business logic goes in services/ not api/, tests go in the
  right directories).
- **Assumptions hold:** every mechanism or behavior a milestone leans on
  (not just files — "X auto-binds", "the runner re-arms", "the provider
  supports Z") was actually confirmed in the code, not guessed.

#### Final review (large / cross-cutting plans)
For Large-scale plans (6+ milestones, or anything cross-cutting/multi-repo),
run an explicit final review pass before considering the plan done:
re-read the whole plan as one unit and re-confirm the **load-bearing
assumptions still hold**, dependencies are ordered, and nothing is missing.
This is the cheap step that catches the silent-corruption assumption error
before a single milestone is executed. Small plans skip it; complex ones
don't.

#### Resolution
If any check fails, **fix it immediately** without asking — then re-run
the check. If a coherence issue cannot be auto-corrected (e.g. unclear
whether a file will exist), add a **Notes** warning to the affected
milestone. Only report the final passing results to the user.

Close by suggesting the execution handoff: `/devplan TDD <path>`
(or `IDD` for exploratory plans).

---

## Guardrails — Things This Playbook NEVER Does

- **Write to the devplan file without approval** — Phase 3 proposes,
  Phase 4 writes, never the reverse
- **Touch application code** — that is `TDD` or `IDD` mode's job
- **Modify completed milestones** (`- [x]`) — they are history
- **Invent requirements not discussed** — only plan what was requested
- **Add speculative cleanup milestones** — if it wasn't asked for,
  don't plan it
- **Estimate time** — never predict how long anything takes
- **Close or create version files** without explicit user request
  (suggesting is fine, deciding is not)

---

## Synergy with TDD / IDD

The milestone format produced by this playbook is designed to be
directly executable by the `TDD` and `IDD` playbooks:

- **Why** → TDD reads this to articulate the business requirement and
  decide whether tests can be written upfront (TDD) or the milestone
  is exploratory (IDD fallback)
- **Approach** → both playbooks use this to orient implementation
- **Tasks** → checkboxes that get marked `[x]` during execution
- **Done when** → the exit condition that TDD checks after tests are
  green

No translation or reformatting is needed between design and execution.
