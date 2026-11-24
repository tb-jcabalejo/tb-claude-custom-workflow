# Ticketboat admin-frontend (Claude Code)

Claude Code port of `.cursor/`. The Cursor tree stays the source for Cursor; this tree is what Claude Code loads. When the workflow changes, update both.

## Session contract

- Refine the request, then hand off (`.claude/rules/token-policy.md`).
- Plan → Code → Review/Test → Plan (`.claude/rules/compounding-dev-cycle.md`).
- ASK / PLAN / AGENT mean the behaviors in `.claude/rules/claude-code.md`.
- Graphify phase budget: `.claude/rules/graphify.md`. Routine orientation uses `graphify query` / `path` / `explain`, not the full `/graphify` skill.
- Do not commit, push, or open a pull request unless the user explicitly asks in this message.

## Commands

| Command | What it does |
|---|---|
| `/feature-plan <slug>` | Write `docs/plans/<slug>.md`, plus a mockup when the UI changes and no design exists |
| `/project-manager <plan-path>` | Code, review, then browser QA; rework until production ready |
| `/apply-ticket <issue>` | Read one Linear issue and write a plan (plus a mockup when needed). Stops after PLAN |
| `/refine-spec <issue>` | Tighten a Linear issue spec. No product code |
| `/create-ticket` | Create one Linear issue |
| `/new-task` | Task breakdown only (not the full cycle) |
| `/api-new`, `/api-test` | FastAPI endpoint or pytest for an endpoint |
| `/code-cleanup`, `/code-optimize` | Refactor or measure-first performance pass |
| `/trace-flow <page or action>` | Read-only trace of a page or action to `docs/traces/<slug>.md` |
| `/nrd-review <owner/repo#N \| --local>` | NRD Sight–style PR review: material findings only (critical / important / consider, Fix / Where / Cost), checked against the linked Linear ticket. Saves `docs/reviews/…`; posts only with `--post`; `--compare` grades it against NRD Sight's own review |
| `/nrd-scan <repo> [paths]` | NRD Sight–style security scan to `docs/scans/<repo>-<date>.md` with rule ids and a fix brief; Linear tickets only after you confirm |
| `/manual-test <plan-path>` | Browser QA with Playwright: open the changed pages, check every AC, write `docs/qa/<slug>-qa-N.md`. Runs automatically at the end of `/project-manager`. `--login` opens Chrome so you sign in once; the tester reuses that session |
| `/daily-report [48h \| since <date time>]` | Read-only daily report (done, next working day, blockers) from Linear, local git commits/pushes (`.claude/scripts/daily-git-activity.sh`), and Teams |

After `/feature-plan` or `/apply-ticket`, run `/clear`, then `/project-manager <plan-path>`.

Linear commands need the Linear MCP connected in Claude Code.

## Subagents

Commands live in `.claude/commands/`. Subagents are defined in `.claude/agents/` and spawned with the Agent tool by name: `backend-architect`, `frontend-architect`, `backend-reviewer`, `frontend-reviewer`, `nrd-reviewer`, `qa-tester`, `tech-stack-researcher`, `technical-writer`. Reviewers (including `nrd-reviewer`) and `qa-tester` have no Write or Edit tools. `qa-tester` starts its own Playwright MCP server (needs Node.js 18+ and Chrome).
