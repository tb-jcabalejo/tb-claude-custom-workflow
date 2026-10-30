---
description: Analyze task complexity and create actionable implementation plan
argument-hint: [task]
disable-model-invocation: true
---

**Scope:** This command produces a **task breakdown and implementation plan** only. It does **not** write to `docs/plans/` and does **not** run the full Plan → Code → Review cycle. For the full compounding cycle, use **feature-plan** to create a plan at `docs/plans/<feature-slug>.md`, then run **project-manager** with that plan path.

Analyze the following task and create a clear, actionable implementation plan.

**Graphify:** Follow `.claude/rules/graphify.md` phase budget (PLAN/orient = required `query --budget 1500` before explore; write concrete file paths). Do not load the full `/graphify` skill for routine query.

## Task

$ARGUMENTS

## Agent Definitions

**Apply the agent-selection skill** (`.claude/skills/agent-selection/SKILL.md`): identify relevant agents from `.claude/agents/` and apply their perspective to the analysis and implementation plan.

**Relevant agents for this command (task breakdown):** backend-architect, frontend-architect, tech-stack-researcher, technical-writer. Use the subset that matches the task. **Ticketboat stack:** Backend = FastAPI, Python 3.12+, Pydantic v2, asyncpg, SQLAlchemy; Frontend = React 18, Vite, Ant Design, Jotai, TanStack Query.

## Analysis framework

### 1. Task breakdown
- Understand requirements
- Identify dependencies
- List affected files/components
- Estimate complexity (Small / Medium / Large)

### 2. Time estimation
- **Small**: 1–2 hours (simple bug fix, minor feature)
- **Medium**: Half day to 1 day (new component, API endpoint)
- **Large**: 2–5 days (complex feature, multiple integrations)
- **Very Large**: 1+ week (major refactor, new subsystem)

### 3. Risk assessment
- Unknown dependencies, API limitations, data migration needs, breaking changes, third-party service issues

### 4. Implementation steps
- Sequential steps: Setup → Backend (if any) → Frontend (if any) → Testing → Documentation
- For backend: FastAPI router, Pydantic models, service layer, tests (pytest)
- For frontend: Components, pages, API integration (React Query), tests (Vitest)

### 5. Success criteria
- Feature works as specified; tests pass; no regressions; code reviewed; documented

## Output format

- **Task analysis**: Type, Complexity, Estimated time, Priority
- **Implementation plan**: Phased steps with checkboxes
- **Files to modify/create**
- **Dependencies**: Packages, env vars
- **Testing strategy**
- **Potential issues and mitigations**
- **Next steps**: e.g. run feature-plan then project-manager for full cycle

Provide a clear, actionable plan. For full Plan → Code → Review/Test cycle, direct the user to feature-plan and project-manager.
