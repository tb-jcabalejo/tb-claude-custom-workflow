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
| `/feature-plan <slug>` | Write `docs/plans/<slug>.md` only |
| `/project-manager <plan-path>` | Code, then review, then rework until production ready |
| `/apply-ticket <issue>` | Read one Linear issue and write a plan. Stops after PLAN |
| `/refine-spec <issue>` | Tighten a Linear issue spec. No product code |
| `/create-ticket` | Create one Linear issue |
| `/new-task` | Task breakdown only (not the full cycle) |
| `/api-new`, `/api-test` | FastAPI endpoint or pytest for an endpoint |
| `/code-cleanup`, `/code-optimize` | Refactor or measure-first performance pass |
| `/trace-flow <page or action>` | Read-only trace of a page or action to `docs/traces/<slug>.md` |

After `/feature-plan` or `/apply-ticket`, run `/clear`, then `/project-manager <plan-path>`.

Linear commands need the Linear MCP connected in Claude Code.

## Subagents

Commands live in `.claude/commands/`. Subagents are defined in `.claude/agents/` and spawned with the Agent tool by name: `backend-architect`, `frontend-architect`, `backend-reviewer`, `frontend-reviewer`, `tech-stack-researcher`, `technical-writer`. Reviewers have no Write or Edit tools.
