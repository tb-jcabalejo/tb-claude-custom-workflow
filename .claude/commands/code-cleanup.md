---
description: Refactor and clean up code following best practices (Python and TypeScript)
argument-hint: [file]
disable-model-invocation: true
---

Clean up and refactor the following code to improve readability, maintainability, and follow best practices.

## Agent Definitions

**Apply the agent-selection skill** (`.claude/skills/agent-selection/SKILL.md`): identify relevant agents from `.claude/agents/` and apply their perspective.

**Relevant agents for this command:** backend-architect (backend/Python cleanup; align with `api-routes-python.md`, `python-backend.md`), frontend-architect (frontend/React cleanup; align with `react-frontend.md`, `typescript.md`), backend-reviewer, frontend-reviewer (use their checklists to self-check before done). When cleanup follows a rework list from Review/Test, treat it as Code phase: implement only the rework items and produce implementation notes for handoff.

## Code to Clean

$ARGUMENTS

## Cleanup checklist

### Backend (Python)
- Run **ruff** (fix auto-fixable), **black** (format), **mypy** (type check) where adopted
- Single responsibility per function; keep handlers thin; use Depends() for DI
- Pydantic for request/response; no raw SQL concatenation
- Align with `core-standards.md`, `python-backend.md`, `api-routes-python.md`

### Frontend (TypeScript/React)
- Run **ESLint --fix**, **Prettier** where adopted
- Descriptive names; consistent naming (camelCase, PascalCase); booleans is/has/can
- Single responsibility; keep components under ~100 lines; extract hooks
- Align with `core-standards.md`, `react-frontend.md`, `typescript.md`

### General
- DRY: extract repeated code to utilities/shared modules
- Early returns and guard clauses; reduce nesting
- No magic numbers/strings; named constants
- When part of Plan → Code → Review/Test: do not expand scope beyond rework list; produce implementation notes

## Output

1. **Issues found** (or rework items addressed)
2. **Cleaned code**
3. **Explanations** (what changed and why)
4. **Implementation notes** (when part of cycle): what was done, deferred, assumptions

Focus on practical improvements; balance clean code with pragmatism.
