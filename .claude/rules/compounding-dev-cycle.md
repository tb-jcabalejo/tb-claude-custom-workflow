# Compounding Development Cycle

Claude Code executes ASK / PLAN / AGENT as defined in `.claude/rules/claude-code.md`.

**Plan → Code → Review/Test → Plan.** Each phase ends with a written artifact. Switch modes explicitly (ASK → PLAN → AGENT). Full orchestration detail: `.claude/commands/project-manager.md`.

## Before modes: refine, then hand off

Apply `token-policy.md` Session entry flow first, then enter ASK/PLAN or delegate with that brief—not a vague restatement.

## Modes

| Mode | When | Output | Exit |
|------|------|--------|------|
| **ASK** | Scope/AC unclear | Questions or structured requirements | Scope + success criteria unambiguous |
| **PLAN** | Scope clear | `docs/plans/<feature>.md` (AC, File changes, tasks) | Another agent can implement without guessing |
| **AGENT (Code)** | Plan ready | Code + tests + impl notes (Done/Deferred/Assumptions/Env) | Handoff to Review |
| **AGENT (Review)** | Code done | Summary + rework list (Critical/Suggestion/Nice) + test status | No Critical → production ready; else rework PLAN |

## Transition (initial)

1. ASK (if needed) → 2. PLAN → 3. Code → 4. Review → 5. Production ready, or 6. rework PLAN → Code → Review until no Critical.

## Phase rules (short)

- **PLAN:** Graphify required (`graphify.md`); write concrete **File changes**. After PLAN, run `/clear`, then `/project-manager <plan-path>`.
- **Code:** Plan-first; implement only to plan; `graphify update .` after substantive edits. Pass **plan path + domain sections**, not full dumps.
- **Review:** Diff-first; rework items must be file/line + change + severity. Critical → rework plan `docs/plans/<feature>-rework-N.md`.
- **Production ready:** All AC covered by tests; no rule violations; no unresolved high-severity security/data-integrity issues; no Critical rework.

## Cross-phase

- `token-policy.md` for prose budget; `graphify.md` phase budget; `core-standards.md` + domain rules.
- Plan doc is the contract. Trace work to AC-n. No verbal-only handoffs.
