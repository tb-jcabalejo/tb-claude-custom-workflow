---
name: api-design-patterns
description: Apply RESTful and FastAPI design best practices for endpoints, error handling, validation, and DI. Use when designing APIs, creating new endpoints, or reviewing API structure with backend-architect.
---

# API Design Patterns (FastAPI)

## Quick Reference

### REST Conventions
- **Nouns, not verbs**: `/users` not `/get_users`
- **Plural resources**: `/products` not `/product`
- **Nested for relationships**: `/users/123/orders` for user's orders
- **HTTP methods**: GET (read), POST (create), PUT/PATCH (update), DELETE (remove)

### Status Codes
Use `starlette.status` (e.g. `status.HTTP_200_OK`). Return via `HTTPException` or response class.

| Code | Use |
|------|-----|
| 200 | Success (GET, PUT, PATCH) |
| 201 | Created (POST) |
| 204 | No content (DELETE) |
| 400 | Bad request (validation failed) |
| 401 | Unauthorized (not authenticated) |
| 403 | Forbidden (authenticated but not allowed) |
| 404 | Not found |
| 409 | Conflict (duplicate, state conflict) |
| 422 | Unprocessable (FastAPI default for Pydantic validation errors) |
| 500 | Server error |

### Error Response Shape
Keep consistent; e.g. use FastAPI exception handlers to return:
```json
{
  "error": {
    "code": "VALIDATION_ERROR",
    "message": "Human-readable message",
    "details": [{ "field": "email", "reason": "Invalid format" }]
  }
}
```
Use `HTTPException(status_code=..., detail=...)`; never expose stack traces to client.

### Validation
- Validate at boundary with Pydantic v2 request models (body, query, path)
- FastAPI returns 422 with field-level details for validation errors
- Use Pydantic validators and model_dump for response shape

### Structure
- **Routers**: Group routes by resource; use `APIRouter(prefix="/users", tags=["users"])`
- **Dependencies**: Use `Depends()` for DB session, current user, auth; keep handlers thin
- **Async**: Use async route handlers and async service functions for I/O

### Security
- Never expose stack traces in production
- Log errors server-side (structlog); return generic messages to client
- Rate limit public or auth endpoints where applicable
- Validate content-type and body size; use Pydantic for request body limits
