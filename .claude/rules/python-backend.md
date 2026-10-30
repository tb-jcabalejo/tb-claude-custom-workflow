---
paths:
  - "**/*.py"
---

# Python Backend (Ticketboat)

**Stack:** Python 3.12+, FastAPI, Pydantic v2, asyncpg, SQLAlchemy 2, httpx, tenacity. Tooling: ruff (lint), black (format), mypy (strict), pytest + pytest-asyncio.

*Also applies:* `token-policy.md` (answer shape, diffs, tools). This file is stack-only; both apply.

## Async-First
- Use async route handlers and async service functions where I/O is involved.
- Pass `context.Context`-equivalent (e.g. request context) for cancellation and timeouts where applicable.
- Use httpx for HTTP client calls; tenacity for retries with jittered backoff.

## Types and Validation
- Use Pydantic v2 for request/response models, config, and DTOs.
- Prefer built-in generics (`list[...]`, `dict[str, T]`). Type-hint all public function parameters and return types.
- Run mypy in strict mode; avoid `Any` unless necessary, then narrow.

## Error Handling
- Define small domain exceptions; avoid catching `Exception` broadly.
- Log errors with context (operation name, input summary); use structlog or logging with JSON formatter; include request/correlation IDs.
- Re-raise with `raise ... from err` where appropriate.

## Structure
- Keep route handlers thin; delegate to service/use-case layer. Use FastAPI `Depends()` for DI (DB session, auth).
- One business action per transaction; keep transactions short.
- Prefer pure functions when possible; isolate side effects at boundaries.

## Database
- Use parameterized queries only; never build SQL with string concatenation. Prefer SQLAlchemy async sessions and ORM/ Core with bind parameters.
- Timestamps: `created_at` / `updated_at` timestamptz, default now(); UTC.
- Primary keys: UUID (app-generated) or consistent project convention.

## Logging and Observability
- Logging via structlog or logging with JSON formatter; no secrets/PII in logs.
- Include request/correlation IDs for traceability.

## Packaging and Runtime
- Pin versions in requirements.txt; use wheels; avoid heavyweight system deps in Lambda/ECS.
- Lambda: prefer AWS Lambda Powertools (Python) for logging/metrics/tracing; keep handlers thin.
