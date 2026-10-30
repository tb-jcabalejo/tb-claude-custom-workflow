# Claude Code mode map

Cursor mode names in this workflow mean the following when running in Claude Code. State the mode when delegating.

| Mode | Behavior |
|---|---|
| **ASK** | Do not edit files. Ask until scope and acceptance criteria are unambiguous. |
| **PLAN** | Create or edit only `docs/plans/**` (and, for `/refine-spec` or `/create-ticket`, the Linear issue via MCP). Do not change application code or run build, test, or install commands. |
| **AGENT (Code)** | Implement the plan. Spawn `backend-architect`, then `frontend-architect`, with the Agent tool. They may edit files and run tests. |
| **AGENT (Review)** | Spawn `backend-reviewer` and `frontend-reviewer`. They are read-only and return a rework list. The parent writes `docs/plans/<feature>-rework-N.md` when Critical items exist. |

Subagent files live in `.claude/agents/`. Identity is the `name` field. Do not use Cursor Task types or Cursor Plan/Ask/Agent mode switches.

After a plan is written, `/clear`, then `/project-manager <plan-path>`, so plan-authoring context does not stack into Code.

Do not commit, push, or open a pull request unless the user explicitly asks.
