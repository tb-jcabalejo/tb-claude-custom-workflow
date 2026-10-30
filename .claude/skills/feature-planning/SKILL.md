---
name: feature-planning
description: Break features into implementation tasks for backend and frontend. Use when planning features, creating implementation plans, or running feature-plan command. Writes the plan only; no implementation.
---

# Feature Planning (Ticketboat)

## Claude Code: plan file only

When this skill is used (including by **/feature-plan**), write only `docs/plans/<feature-slug>.md`. No application code and no other files. Do not spawn Code or Review subagents. If asked to implement, decline and point to `/project-manager` with the plan. PLAN behavior: `.claude/rules/claude-code.md`.

## Rules to follow

- **Graph-first (PLAN phase):** Before exploring product repos for technical design or file mapping, apply `.claude/rules/graphify.md` phase budget and `.claude/skills/graphify-navigation/SKILL.md` (`query --budget 1500` / path / explain). Write concrete **File changes**.
- **Compounding cycle:** Follow the **Plan** phase in `.claude/rules/compounding-dev-cycle.md`: goal = unambiguous scope, acceptance criteria, technical approach; artifact = single plan doc; handoff rule = plan complete when another agent can implement without guessing.
- **Project-manager handoff:** Align with `.claude/commands/project-manager.md`: PLAN writes the plan only. `/project-manager` then runs Code (implementing subagents) and Review (read-only subagents). See `.claude/rules/claude-code.md`.

## Required sections (for project-manager)

Plans produced by **feature-plan** must include these sections so **project-manager** can load and delegate reliably:

- **Scope / Metadata** (optional): `Security: critical`, `Performance: critical` when applicable
- **Feature Overview**: Problem, audience, key functionality
- **Acceptance criteria**: Testable conditions, numbered (AC-1, AC-2, …) for traceability
- **Technical Design**: Components, endpoints, schema, data flow
- **Backend Tasks**: For backend-architect (FastAPI, Pydantic, SQLAlchemy/asyncpg; Setup → Database → API → Security)
- **C# Backend Tasks** (when feature touches C# API): For backend-architect (auto-selects C#; ASP.NET Core, EF Core/Dapper; Setup → Database → API → Security)
- **Frontend Tasks**: For frontend-architect (React, Ant Design, Jotai, TanStack Query; Components → Pages → Integration → Polish)
- **Integration & Testing**: Unit/integration and critical path coverage
- **File Changes**: New and modified files
- **Dependencies / env**: Packages, env vars, config changes

## Task Blocks for Hand-off

- **Backend Tasks**: Setup → Database → API → Security (Pydantic models, SQLAlchemy/asyncpg, FastAPI routers, auth)
- **C# Backend Tasks**: Setup → Database → API → Security (EF Core/Dapper, ASP.NET Core controllers, auth)
- **Frontend Tasks**: Components → Pages → Integration → Polish (Ant Design, Jotai, React Query, axios)
- **Integration & Testing**: Unit/integration and critical path coverage

## Per-Block Checklist

- [ ] Dependencies and env vars listed
- [ ] File changes (new/modified) specified
- [ ] API contract or schema described
- [ ] Success criteria clear

## Detail level (for project-manager handoff)

Plans must be **detailed** so implementers do not guess. Include:

- **Task analysis**: Type, complexity, estimated effort, priority
- **Acceptance criteria**: Numbered (AC-1, AC-2, …), testable (Given/When/Then or pass/fail)
- **Technical design**: Named components, per-endpoint (method, path, request/response shape), data model, data flow
- **Backend / Frontend tasks**: Phased steps with checkboxes; concrete file paths (create/modify) per phase; API contract summary for frontend
- **Integration & testing**: Critical paths; unit/integration areas
- **File changes**: Explicit list (path + create or modify)
- **Dependencies / env**: Package names and purpose; env var name, purpose, example, required vs optional
- **Risks / potential issues** (recommended): 2–5 bullets with mitigations or TBD
- **Next steps**: Run project-manager with plan path

See `.claude/commands/feature-plan.md` section "Detailed output format (mandatory)" for the full template.

## Hand-off Order

1. backend-architect (implements Backend tasks and/or C# Backend tasks; auto-selects Python or C# from plan)
2. frontend-architect (depends on API)

## Hand-off (via project-manager)

- **feature-plan** produces the plan file only; it does not spawn subagents. It only writes the plan file.
- `/project-manager` consumes the plan and runs Code (implementing subagents) then Review (read-only subagents), per `.claude/commands/project-manager.md`.

## Plan-mode checklist (before considering the plan done)

- [ ] All required sections above are present (Scope/Metadata, Feature Overview, Acceptance criteria, Technical design, Backend tasks and/or C# Backend tasks as applicable, Frontend tasks, Integration & Testing, File changes, Dependencies/env).
- [ ] Acceptance criteria are testable and numbered (AC-1, AC-2, …) for traceability.
- [ ] No application code or implementation was written; only the plan document was produced.
- [ ] Plan path is `docs/plans/<feature-slug>.md`. User is directed to run project-manager with that path for the next step.

## Context to Pass

- Feature overview
- Technical design (components, endpoints, schema)
- File changes
- Dependencies
- API contract (for frontend)
- User flows (for acceptance criteria)
