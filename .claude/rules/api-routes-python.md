---
paths:
  - "**/api/**/*.py"
---

# API Routes (FastAPI)

*Also applies:* `token-policy.md` (agent answers, diffs, tools). This file is HTTP contract only; both apply.

## Validation
- Validate all input at the route boundary using Pydantic v2 request models (body, query, path).
- Return 422 for validation errors (FastAPI default); use 400 for bad request when appropriate.
- Expose field-level error details in response body (FastAPI does this via `RequestValidationError`).

## Response Shape
- Success: return the resource or Pydantic response model; use 200 (GET/PUT/PATCH), 201 (POST), 204 (DELETE).
- Errors: use consistent shape, e.g. `{"error": {"code": str, "message": str, "details": list | None}}`.
- Never expose stack traces, internal paths, or sensitive data in production. Use `HTTPException` with generic message; log details server-side.

## Status Codes
| Code | Use case |
|------|----------|
| 200 | Success (GET, PUT, PATCH) |
| 201 | Created (POST) |
| 204 | No content (DELETE) |
| 400 | Bad request, validation failed (or custom business validation) |
| 401 | Unauthorized, not authenticated |
| 403 | Forbidden, authenticated but not allowed |
| 404 | Resource not found |
| 409 | Conflict (e.g., duplicate) |
| 500 | Server error (log details, return generic message) |

Use `status.HTTP_*` from `starlette.status` and `HTTPException` from `fastapi` for consistency.

## Security
- Authenticate and authorize before processing; return 401/403 early. Use `Depends()` for auth dependency.
- Validate content-type and body size; reject unexpected payloads.
- Use parameterized queries / ORM only; never concatenate user input into SQL.
- Rate limit sensitive endpoints (auth, password reset) where applicable.

## Structure
- Keep route handlers thin; delegate to service/use-case layer.
- Use dependency injection (`Depends()`) for DB session, current user, and shared services.
- Document endpoints via OpenAPI (FastAPI auto-generates); add description and response_model where helpful.
