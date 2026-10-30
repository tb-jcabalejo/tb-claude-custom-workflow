---
name: api-testing
description: Structure and write API tests for FastAPI endpoints using pytest and httpx. Use when testing APIs, creating api-test scenarios, or validating backend endpoints with backend-architect.
---

# API Testing (pytest + FastAPI)

## Test Structure

### What to Test
1. **Happy path**: Valid request → expected response
2. **Validation**: Invalid input → 400/422 with error details (Pydantic validation)
3. **Auth**: Unauthenticated → 401; unauthorized → 403
4. **Not found**: Invalid ID → 404
5. **Edge cases**: Empty body, missing required fields, type mismatches

### Request/Response Assertions
- Status code matches expectation
- Response body shape (keys present, types correct); use Pydantic or dict assertions
- Error messages are present and meaningful
- No sensitive data in responses (tokens, internal IDs if applicable)

### Test Organization
```
tests/
├── unit/
│   └── api/
├── integration/
│   └── api/
│       ├── test_auth.py
│       ├── test_users.py
│       └── test_products.py
conftest.py   # fixtures: app, client, db session, auth
```
Group by resource or feature. Use `pytest` marks if needed (`@pytest.mark.integration`).

### Setup/Teardown
- Use test database or mocks; never hit production
- Use `conftest.py` for fixtures: `async_client` (httpx.AsyncClient with FastAPI app), DB session override, auth override
- Clean up created resources in fixtures or use transactions

### Example Pattern (pytest + httpx)
```python
import pytest
from httpx import ASGITransport, AsyncClient
from app.main import app

@pytest.fixture
def anyio_backend():
    return "asyncio"

@pytest.mark.asyncio
async def test_returns_422_when_email_invalid():
    async with AsyncClient(
        transport=ASGITransport(app=app),
        base_url="http://test"
    ) as client:
        response = await client.post(
            "/api/users",
            json={"email": "invalid", "name": "Test"}
        )
    assert response.status_code == 422
    body = response.json()
    assert "detail" in body  # FastAPI validation detail
```

### Fixtures (conftest.py)
- Override `get_db` or auth dependency with test doubles
- Use `pytest-asyncio` for async tests; set `asyncio_mode = auto` or mark tests with `@pytest.mark.asyncio`
