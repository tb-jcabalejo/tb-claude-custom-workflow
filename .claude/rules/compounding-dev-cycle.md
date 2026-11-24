# Compounding Development Cycle

Claude Code executes ASK / PLAN / AGENT as defined in `.claude/rules/claude-code.md`.

**Plan → Code → Review/Test → Manual QA → Plan.** Each phase ends with a written artifact. Switch modes explicitly (ASK → PLAN → AGENT). Full orchestration detail: `.claude/commands/project-manager.md`.

## Before modes: refine, then hand off

Apply `token-policy.md` Session entry flow first, then enter ASK/PLAN or delegate with that brief—not a vague restatement.

## Modes

| Mode | When | Output | Exit |
|------|------|--------|------|
| **ASK** | Scope/AC unclear | Questions or structured requirements | Scope + success criteria unambiguous |
| **PLAN** | Scope clear | `docs/plans/<feature>.md` (AC, File changes, tasks, Design reference, Manual QA) + `docs/plans/mockups/<feature>.html` when the UI changes and no design exists | Another agent can implement without guessing |
| **AGENT (Code)** | Plan ready | Code + tests + impl notes (Done/Deferred/Assumptions/Env) | Handoff to Review |
| **AGENT (Review)** | Code done | Summary + rework list (Critical/Suggestion/Nice) + test status | No Critical → Manual QA; else rework PLAN |
| **AGENT (QA)** | Review has no Critical; plan has UI-observable AC | `docs/qa/<feature>-qa-N.md` + screenshots (PASS/FAIL/BLOCKED per AC) | All UI AC PASS → production ready; FAIL → rework PLAN; BLOCKED → user clears it |

## Transition (initial)

1. ASK (if needed) → 2. PLAN → 3. Code → 4. Review → 5. Manual QA → 6. Production ready, or 7. rework PLAN → Code → Review → Manual QA until no Critical and no QA FAIL.

## Phase rules (short)

- **PLAN:** Graphify required (`graphify.md`); write concrete **File changes**. After PLAN, run `/clear`, then `/project-manager <plan-path>`. When Frontend tasks change what users see and no design was supplied, generate the mockup (`.claude/skills/ui-mockup/SKILL.md`). Write the **Manual QA** section (route, data, per-AC steps).
- **Code:** Plan-first; implement only to plan; `graphify update .` after substantive edits. Pass **plan path + domain sections**, not full dumps.
- **Review:** Diff-first; rework items must be file/line + change + severity. Critical → rework plan `docs/plans/<feature>-rework-N.md`.
- **Manual QA:** AC-driven only. `qa-tester` opens the exact route in Playwright, runs each UI-observable AC, compares with the mockup, and proves each verdict with a screenshot (`.claude/skills/manual-qa/SKILL.md`). FAIL → rework plan; BLOCKED (auth, env, data) → ask the user.
- **Production ready:** All AC covered by tests; no rule violations; no unresolved high-severity security/data-integrity issues; no Critical rework; Manual QA PASS (or N/A) for every UI-observable AC.

## Cross-phase

- `token-policy.md` for prose budget; `graphify.md` phase budget; `core-standards.md` + domain rules.
- Plan doc is the contract. Trace work to AC-n. No verbal-only handoffs.
