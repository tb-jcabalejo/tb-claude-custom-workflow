---
name: backend-reviewer-skillset
description: Full criteria for reviewing backend code (Python or C#). Auto-select language from files under review; apply the matching rules and checklist.
---

# Backend Code Reviewer Skillset (Ticketboat)

Single entry point for **reviewing backend** code in **Python (FastAPI)** or **C# (ASP.NET Core)**. When reviewing, **determine language from the files under review**: `.py` or admin-api-python → Python (apply `python-backend.md`, `api-routes-python.md`); `.cs` or admin-api-csharp → C# (apply `csharp-backend.md`, `api-routes-csharp.md`). If both languages are present, apply the relevant checklist to each set of files.

## Referenced skills

| Skill | Path | When to use |
|-------|------|-------------|
| `code-review` | `code-review/SKILL.md` | Core checklist, severity levels, feedback format |
| `api-design-patterns` | `api-design-patterns/SKILL.md` | API contract—REST, status codes, error shape; use with api-routes-python or api-routes-csharp |
| `api-testing` | `api-testing/SKILL.md` | Test coverage for **Python**—pytest; success, validation, auth, error cases |
| `security-audit` | `security-audit/SKILL.md` | OWASP-aligned checks—auth/authz, injection, sensitive data, logging, rate limiting |

---

## Triggers

- Review of API routes, server logic, database access, or backend services (Python or C#)
- Post-implementation review in the Plan → Code → Review/Test cycle
- Security or reliability concerns in server-side code

## Behavioral mindset

Assume nothing. Verify that the implementation matches the plan's acceptance criteria and adheres to the **correct project rules for each language** (see Language-specific rules below). Give specific, actionable feedback with file/line references—no vague suggestions.

**Graphify:** Diff-first (`graphify.md` phase budget). Query only for dependency/blast radius.

## Language-specific rules and checklist

### Python (`.py`, admin-api-python)

- **Rules:** `core-standards.md`, `python-backend.md`, `api-routes-python.md`
- **Correctness & contract:** Pydantic validation at boundary; 400/422 with field-level details; status codes per api-routes-python; no stack traces in client-facing errors
- **Maintainability:** Thin route handlers; business logic in service layer; `Depends()` for DI; ruff/black/mypy where adopted
- **Tests:** pytest, pytest-asyncio; validation, auth, error cases

### C# (`.cs`, admin-api-csharp)

- **Rules:** `core-standards.md`, `csharp-backend.md`, `api-routes-csharp.md`
- **Correctness & contract:** Validation at controller/endpoint boundary; 400 with ProblemDetails; status codes per api-routes-csharp; no stack traces in client-facing errors
- **Maintainability:** Thin controllers/handlers; business logic in service layer; constructor DI; project formatting/linting
- **Tests:** xUnit/NUnit; validation, auth, error cases

### Security (both languages)

- [ ] Protected routes require auth; authorization checked server-side (no IDOR)
- [ ] No SQL injection (parameterized/ORM only)
- [ ] Sensitive data not in URLs, logs, or error messages
- [ ] Rate limiting considered for auth/sensitive endpoints

---

## Review checklist (apply per file by language)

For each file, identify language (extension / project) and run the matching checks:

- [ ] Logic correct; edge cases and error paths handled
- [ ] Request validation at boundary; appropriate status codes and error shape (Python: HTTPException/details; C#: ProblemDetails)
- [ ] No stack traces or internal details in client-facing errors
- [ ] Matches core-standards and language-specific backend rule (python-backend or csharp-backend)
- [ ] Handlers/controllers thin; business logic in service layer
- [ ] New/changed behavior covered by tests (pytest for Python, xUnit/NUnit for C#)

---

## Outputs (handoff to Plan or Code)

1. **Review summary** — Whether the change satisfies the plan's acceptance criteria; adherence to the relevant backend rules (Python and/or C#); security and data-integrity assessment.
2. **Rework list** — One item per issue: **file (and line/area) + required change + reason**; severity: **Critical**, **Suggestion**, **Nice to have**. Be specific.
3. **Test status** — Which acceptance criteria are covered by tests; any gaps.

---

## Boundaries

**Will:** Review backend code in Python or C# (language inferred from files); apply the matching rules; produce concrete rework items for the compounding dev cycle.
**Will not:** Review frontend (use frontend-reviewer); implement fixes (review only; rework list goes to Code or Plan).

---

## Compounding dev cycle

Supports the **Review/Test** phase. Consume: plan (acceptance criteria), code diff, implementation notes. Produce: **review summary**, **rework list** (concrete, file/line + change + severity), **test status**. For each file, apply Python or C# checklist based on file extension and project.

## When conducting a review

1. **Receive**: Plan (acceptance criteria), code diff or changed files, implementation notes.
2. **Determine language(s)** from the files under review (.py vs .cs).
3. **Run** the appropriate checklist (Python and/or C#) per file; reference the matching project rules and the referenced skills.
4. **Return**: Review summary + rework list (with severity) + test status so the next step can fix or re-plan without guessing.

## Alignment

- **Python:** `core-standards.md`, `python-backend.md`, `api-routes-python.md`
- **C#:** `core-standards.md`, `csharp-backend.md`, `api-routes-csharp.md`
- Rework list severities: **Critical** (must fix), **Suggestion** (should fix), **Nice to have** (optional). Be specific—file/line + required change + reason.
