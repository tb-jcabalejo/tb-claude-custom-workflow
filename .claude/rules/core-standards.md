# Core Standards

**Context:** Ticketboat uses a dual stack—Python (FastAPI) backend and TypeScript (React/Vite) frontend. All timestamps and APIs use UTC. Config via environment; no hard-coded secrets (AWS Secrets Manager/SSM or local .env for dev). 12-factor style: stateless services, disposable processes.

## Type Safety
- **TypeScript:** Prefer explicit types over `any`; use `unknown` when type is truly unknown, then narrow. Avoid type assertions (`as`) unless necessary; prefer type guards or better typing.
- **Python:** Use type hints for function parameters and return types; prefer built-in generics (`list`, `dict`). Use Pydantic v2 for DTOs and config. Run mypy (strict) in CI.

## Error Handling
- Handle errors explicitly; never swallow with empty `catch` blocks or bare `except`.
- Log errors before rethrowing; include context (e.g., operation name, input summary). No secrets/PII in logs; redact tokens/keys.
- Use custom error classes for domain-specific failures when helpful. In Python: small domain exceptions; avoid catching `Exception` broadly.

## Function Design
- Keep functions focused on one concern; extract when they exceed ~30 lines.
- Prefer pure functions when possible; isolate side effects at boundaries.
- Use early returns and guard clauses to reduce nesting.

## Naming
- Use meaningful names; avoid abbreviations except common ones (`id`, `url`, `err`, `req`, `res`).
- Booleans: `isLoading`, `hasError`, `canEdit`.
- Functions: verb-first (`fetchUser`, `validateInput`, `formatDate`).
- Python: snake_case for functions/variables; PascalCase for classes.

## General
- **TypeScript:** Prefer `const` over `let`; avoid `var`.
- **Python:** Prefer `const`-style (immutable where possible); avoid magic numbers and strings—extract to named constants.
- Comment *why*, not *what*; code should be self-explanatory.
- Validate all inputs at the boundary; sanitize outputs that re-render. Parameterized queries only; never interpolate SQL.

## Session communication and context
- **Answer shape, handoff brevity, code citations vs pastes, and batched tool use** are defined in **`token-policy.md`**; follow that rule in every session. It also covers **refine → hand off** before commands/agents/skills, and **internal XML task blueprints** for complex work.
- **Codebase orientation** for product repos: **`graphify.md`** phase budget (PLAN required; Code plan-first; Review diff-first) is additive with token-policy.
- Domain rules in this folder (e.g. `typescript`, `api-routes-*`, `react-frontend`) are **additive** for stack and file patterns. If something conflicts about how much to say or what to put in a diff, **`token-policy.md` wins** for the agent’s own communication.
