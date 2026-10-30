---
description: Create a feature plan file for the compounding cycle. Writes only docs/plans. Output is for /project-manager.
argument-hint: [feature-slug]
disable-model-invocation: true
---

**Scope of this command:** This command produces **only** a feature plan document. It writes the plan file only: no implementation. It does **not** spawn Code or Review agents. For the full cycle, run **project-manager** with the plan path after this command.

## Claude Code: plan file only

Write only `docs/plans/<feature-slug>.md`. Do not implement application code, create other files, or run build or test commands. If asked to also implement, decline and point to `/project-manager` with this plan. PLAN behavior: `.claude/rules/claude-code.md`.

## Rules to follow

- **Token policy:** Apply `.claude/rules/token-policy.md` first—**refine** the user’s feature request into a tight plan brief (Session entry flow), then author the plan doc; no filler.
- **Graph-first (PLAN phase):** Before exploring product repos for technical design or file mapping, apply `.claude/rules/graphify.md` phase budget and `.claude/skills/graphify-navigation/SKILL.md` (`graphify query "…" --budget 1500` / `path` / `explain`). Write concrete paths into **File changes**. Do not load the full `/graphify` skill for routine query.
- **Compounding cycle:** Follow the **Plan** phase in `.claude/rules/compounding-dev-cycle.md` (scope, acceptance criteria, technical approach, task list; handoff rule: plan complete when another agent can implement without guessing).
- **Project-manager handoff:** Align with `.claude/commands/project-manager.md`: PLAN writes the plan only. `/project-manager` then runs Code (implementing subagents) and Review (read-only subagents). See `.claude/rules/claude-code.md`.
- **Feature-planning skill:** Apply `.claude/skills/feature-planning/SKILL.md` so the plan includes all required sections for project-manager.

## Feature / plan target

$ARGUMENTS

**Interpret the arguments as:** a feature name or slug (e.g. `user-profile`, `auth-login`). The plan file path MUST be `docs/plans/<feature-slug>.md` (e.g. `docs/plans/user-profile.md`). If the user provides a path, use it only if it is under `docs/plans/`; otherwise derive the slug and use `docs/plans/<slug>.md`. If arguments are empty, ask the user for the feature name or slug.

## Required plan sections (strict)

Include every section below so **project-manager** can load and delegate without guessing. Use the feature-planning skill for task-block structure.

1. **Scope / Metadata** (optional but recommended)
   - `Security: critical` or `Performance: critical` when the feature has security or performance acceptance criteria.

2. **Feature Overview**
   - Problem, audience, key functionality.

3. **Acceptance criteria**
   - Testable conditions (Given/When/Then or checklist). Number them (AC-1, AC-2, …) for traceability.

4. **Technical design**
   - Components, endpoints, schema, data flow; references to `core-standards.md`, `api-routes-python.md` (Python backend), `api-routes-csharp.md` / `csharp-backend.md` (C# backend), `react-frontend.md` (frontend) where relevant.

5. **Backend tasks**
   - For backend-architect. FastAPI, Pydantic, SQLAlchemy/asyncpg: Setup → Database → API → Security. Dependencies, env vars, file changes.

6. **C# Backend tasks** (when the feature touches admin-api-csharp)
   - For backend-architect (auto-selects C#). ASP.NET Core, EF Core/Dapper: Setup → Database → API → Security. Dependencies, env vars, file changes.

7. **Frontend tasks**
   - For frontend-architect. React, Ant Design, Jotai, TanStack Query: Components → Pages → Integration → Polish. API contract, file changes.

8. **Integration & testing**
   - Unit/integration and critical path coverage.

9. **File changes**
   - New and modified files (list).

10. **Dependencies / env**
   - Packages, env vars, config changes.

## Detailed output format (mandatory)

Produce a **detailed** plan so project-manager and implementers can work without guessing. For each section, include the level of detail below.

### Task analysis / metadata (at top of plan, after title)
- **Type**: [Feature / Bug Fix / Refactor / Infrastructure]
- **Complexity**: [Small / Medium / Large / Very Large] with 1–2 sentence justification
- **Estimated effort**: X hours or days
- **Priority**: [High / Medium / Low] (optional, if known)

### Technical design
- **Backend**: FastAPI routers, Pydantic models, endpoints (method, path, request/response shape). References: `api-routes-python.md`, `python-backend.md`.
- **Frontend**: React components, Ant Design usage, Jotai/React Query; which endpoints are called (API contract).
- **Data model / schema**: Main entities, DB (PostgreSQL) if applicable.

### Backend tasks
- Phase 1 – Setup: Env vars, config, packages; file changes.
- Phase 2 – Database (if any): Schema, migrations, indexes.
- Phase 3 – API: Per endpoint checkboxes (e.g. Add GET /api/..., Validate input, Return 404 when not found).
- Phase 4 – Security (if any): Auth, permissions.

### Frontend tasks
- Phase 1 – Components: Per component (name, responsibility, props); file path.
- Phase 2 – Pages / views: Routes, layout, data loading.
- Phase 3 – Integration: API client (TanStack Query, axios), error handling, endpoints called.
- Phase 4 – Polish: Loading states, a11y, validation UX.

### File changes, Dependencies / env, Risks, Next steps
- Explicit file list; packages and env vars; 2–5 risks with mitigations; "Run project-manager with this plan."

## Agent definitions (planning perspective only)

**Apply the agent-selection skill** (`.claude/skills/agent-selection/SKILL.md`): identify relevant agents for **planning** (not implementation), read their definitions from `.claude/agents/`, and apply their perspective to the plan.

**Relevant agents for this command (planning only):** tech-stack-researcher, backend-architect, frontend-architect. Use them to inform scope, AC, and task blocks; do not spawn them for Code or Review.

## Output

1. **Write the plan** to `docs/plans/<feature-slug>.md` using **all** required sections and the **detailed output format** above. The plan must be detailed enough that backend-architect and frontend-architect can implement without guessing scope, APIs, or file locations.
2. **Confirm** the plan path and remind the user: "Run **project-manager** with this plan to execute Code → Review/Test (e.g. `/project-manager docs/plans/<feature-slug>.md`). This command wrote the plan only; no implementation was performed."

Do not implement or modify application code.
