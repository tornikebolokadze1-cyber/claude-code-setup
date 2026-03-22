# Python Production Standards

## Type Safety
- Type annotations on ALL function signatures: params and return types
- Use `@dataclass(frozen=True)` for immutable data objects
- Use `typing.Protocol` for duck-typed interfaces (structural subtyping)
- Use `typing.NamedTuple` for lightweight immutables
- Validate input with Pydantic models at API boundaries

## Style
- PEP 8 compliance — enforced by black + isort + ruff
- Docstrings: Google style for public APIs only
- Max line length: 88 (black default)
- Import order: stdlib → third-party → local (isort handles this)

## Error Handling
- Custom exception classes per domain: `class UserNotFoundError(Exception): ...`
- Never bare `except:` — always catch specific exceptions
- Use `contextlib.suppress()` for expected exceptions
- Logging: `logging.getLogger(__name__)` — never `print()` in production

## Patterns
- Context managers (`with`) for resource management (files, DB, locks)
- Generators for memory-efficient lazy iteration
- `@dataclass` for DTOs; Pydantic `BaseModel` for validation
- Repository pattern: abstract base with `find_all`, `find_by_id`, `create`, `update`, `delete`
- Dependency injection via constructor parameters

## Async
- `async def` for I/O-bound operations
- `asyncio.gather()` for concurrent operations
- Never mix sync and async in the same call chain without `run_in_executor`

## Testing
- Framework: pytest
- Coverage: `pytest --cov=src --cov-report=term-missing`
- Markers: `@pytest.mark.unit`, `@pytest.mark.integration`
- Fixtures for setup/teardown; conftest.py for shared fixtures
- Use `unittest.mock.patch` for external dependencies
- Coverage target: 80%+

## Project Structure
```
src/
  __init__.py
  models/        # Data models
  services/      # Business logic
  repositories/  # Data access
  api/           # Routes/endpoints
tests/
  unit/
  integration/
pyproject.toml   # Single config file
```
