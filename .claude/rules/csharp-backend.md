---
paths:
  - "**/*.cs"
---

# C# Backend (Ticketboat)

**Stack:** .NET 8+, ASP.NET Core, C# 12, Entity Framework Core (or Dapper), dependency injection. Tooling: dotnet format, StyleCop/Analyzers or similar; xUnit or NUnit for tests.

*Also applies:* `token-policy.md` (answer shape, diffs, tools). This file is stack-only; both apply.

## Async and I/O
- Use async/await for all I/O (database, HTTP, file). Prefer `Task`/`ValueTask`; avoid `.Result` or `.Wait()` in async contexts.
- Pass `CancellationToken` through async APIs; honor cancellation in long-running or external calls.

## Types and Validation
- Use strong typing; avoid `dynamic` and unnecessary `object`. Prefer records or DTOs for request/response.
- Validate at the boundary (controller/minimal API) with `[FromBody]` models and DataAnnotations or FluentValidation.
- Use nullable reference types; enable in project for safer null handling.

## Error Handling
- Use small domain exceptions; avoid catching `Exception` broadly. Log with context (operation, input summary).
- Use problem details (e.g. `ProblemDetails`) for API errors; never expose stack traces to clients.
- Re-throw with `throw;` or wrap with inner exception where appropriate.

## Structure
- Keep controllers/minimal API handlers thin; delegate to application/services layer.
- Use constructor injection for dependencies (DbContext, repositories, HTTP clients).
- One business action per unit of work; keep transactions short.

## Database
- Use parameterized queries only; never build SQL with string concatenation. Prefer EF Core or Dapper with parameters.
- Timestamps: `CreatedAt`/`UpdatedAt` with UTC; set in app or DB default.
- Primary keys: GUID (app-generated) or consistent project convention.

## Logging and Observability
- Use `ILogger<T>`; structured logging (e.g. Serilog) with no secrets/PII.
- Include correlation/request IDs for traceability; integrate with NewRelic or project APM where used.

## Security
- Authenticate and authorize (e.g. `[Authorize]`, policy-based); validate and authorize at controller/endpoint.
- No secrets in code; use configuration (e.g. Azure Key Vault, AWS Secrets Manager) or env for dev.
