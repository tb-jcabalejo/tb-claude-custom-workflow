---
paths:
  - "**/Controllers/**/*.cs"
---

# API Routes (ASP.NET Core)

*Also applies:* `token-policy.md` (agent answers, diffs, tools). This file is HTTP contract only; both apply.

## Validation
- Validate all input at the controller/endpoint boundary (model binding, DataAnnotations or FluentValidation).
- Return 400 Bad Request for validation errors with problem details or field-level details.
- Use `ApiController` attribute for automatic 400 on invalid model state when applicable.

## Response Shape
- Success: return the resource or DTO; use 200 (GET/PUT/PATCH), 201 (POST with location when appropriate), 204 (DELETE).
- Errors: use consistent shape (e.g. `ProblemDetails` or project-standard error DTO). Never expose stack traces or internal paths in production.

## Status Codes
| Code | Use case |
|------|----------|
| 200 | Success (GET, PUT, PATCH) |
| 201 | Created (POST) |
| 204 | No content (DELETE) |
| 400 | Bad request, validation failed |
| 401 | Unauthorized, not authenticated |
| 403 | Forbidden, authenticated but not allowed |
| 404 | Resource not found |
| 409 | Conflict (e.g., duplicate) |
| 500 | Server error (log details, return generic message) |

Use `IActionResult` or `ActionResult<T>` and status helpers (e.g. `Ok()`, `CreatedAtAction()`, `NotFound()`, `BadRequest()`).

## Security
- Authenticate and authorize before processing; return 401/403 early. Use `[Authorize]` and policies.
- Validate content-type and body size; reject unexpected payloads.
- Use parameterized queries/EF Core only; never concatenate user input into SQL.
- Rate limit sensitive endpoints (auth, password reset) where applicable.

## Structure
- Keep action methods thin; delegate to application/service layer.
- Use dependency injection for DbContext, repositories, and shared services.
- Document endpoints via XML comments or OpenAPI/Swagger where adopted.
