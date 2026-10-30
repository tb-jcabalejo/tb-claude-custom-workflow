---
description: Generate API tests for FastAPI endpoints using pytest and httpx
argument-hint: [endpoint]
disable-model-invocation: true
---

Generate comprehensive API tests for the specified FastAPI endpoint. Follow the compounding dev cycle and project rules: `.claude/rules/compounding-dev-cycle.md`, `.claude/rules/api-routes-python.md`. Use the api-testing skill for structure and coverage.

## Target

$ARGUMENTS

## Compounding dev cycle

This command supports both **Code** and **Review/Test** phases. When tests are added as part of implementation (Code), they are part of the handoff to Review/Test—backend-reviewer uses **test status** (which acceptance criteria are covered, failing/missing tests) to verify gates. When generating tests for an existing endpoint, produce tests that map to the plan's acceptance criteria where possible, plus success, validation, auth, and error cases per api-routes-python and api-testing skill. Produce a short **implementation notes** (scenarios covered, deferred, setup required) so backend-reviewer has full context.

## Agent Definitions

**Apply the agent-selection skill** (`.claude/skills/agent-selection/SKILL.md`): before generating tests, identify relevant agents, read their definitions from `.claude/agents/`, and apply their perspective.

**Relevant agents for this command:** backend-reviewer (primary for handoff), backend-architect. Cover success, validation, auth, and error cases per api-testing skill. Document scenarios covered and setup in implementation notes so backend-reviewer can verify gates.

## Test strategy (pytest + FastAPI)

### 1. Tools
- **pytest** – Test runner
- **pytest-asyncio** – Async test support
- **httpx** – `AsyncClient` with `ASGITransport(app=app)` for FastAPI, or FastAPI `TestClient` for sync
- **conftest.py** – Fixtures for app, client, DB session override, auth override

### 2. Test coverage

**Happy paths**
- Valid inputs return expected results
- Proper status codes (200, 201, 204)
- Correct response shape (Pydantic or dict assertions)

**Error paths**
- Invalid input → 422 (or 400) with validation details
- Unauthenticated → 401; unauthorized → 403
- Not found → 404; Conflict → 409
- Server errors → 500 (mock/log; no sensitive detail in response)

**Edge cases**
- Empty body, missing required fields, type mismatches
- SQL injection attempts (parameterized only), XSS (sanitization)

### 3. Test structure

```
tests/
  conftest.py          # app, async_client, db override, auth override
  unit/api/            # optional unit tests for services
  integration/api/
    test_<resource>.py # describe per endpoint, it per scenario
```

Use `@pytest.mark.asyncio` for async tests; group with `class` or `describe`-style comments.

### 4. Fixtures (conftest.py)
- Override `get_db` with test DB or mock
- Override auth dependency for protected routes
- `AsyncClient` with `ASGITransport(app=app)`, base_url `http://test`

## Output (handoff for Review/Test)

Deliver:

1. **Test file(s) and conftest updates** – Complete test suite, fixtures, and run command (e.g. `pytest tests/integration/api/ -v`).
2. **Test status / coverage summary** – Which scenarios are covered (success, validation, auth, errors); which acceptance criteria (if any) the tests map to.
3. **Implementation notes** – Scenarios covered, deferred, setup required (mocks, env, DB), and assumptions.

Generate production-ready tests that are handoff-ready for the compounding dev cycle and runnable with pytest.
