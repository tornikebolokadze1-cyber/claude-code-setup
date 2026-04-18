# FastAPI Backend — Python + FastAPI + SQLAlchemy + Pydantic

Async Python REST API with FastAPI, SQLAlchemy ORM, Alembic migrations, Pydantic v2 schemas, and JWT authentication.

## Tech stack

- Python 3.12
- FastAPI (async HTTP framework)
- SQLAlchemy 2.x (ORM, async sessions)
- Alembic (database migrations)
- Pydantic v2 + pydantic-settings (schemas and config)
- python-jose + passlib (JWT and password hashing)
- pytest + httpx (testing with async client)
- ruff + mypy (linting and type checking)

## Build & test

| Command | Purpose |
|---------|---------|
| `pip install -e ".[dev]"` | Install package with dev extras |
| `uvicorn app.main:app --reload` | Run dev server with hot reload (from `src/`) |
| `alembic upgrade head` | Apply all pending migrations |
| `alembic revision --autogenerate -m "description"` | Generate a new migration |
| `pytest` | Run full test suite |
| `pytest -m unit` | Run unit tests only |
| `ruff check src/` | Lint source tree |
| `mypy src/` | Type-check source tree |

## Code conventions

- Every request and response has a dedicated Pydantic schema in `src/app/schemas/`; never expose ORM models directly to API consumers
- Business logic lives in `src/app/services/`; routers are thin — they validate input, call a service, and return a schema
- Use the repository pattern for all DB access (`session.execute(select(...))`) — no raw SQL strings
- Only use `async def` for route handlers that actually `await` I/O; sync endpoints that call no I/O are fine as `def`
- Inject the DB session via `Depends(get_db)` — never create sessions inside service functions

## Security

- Use SQLAlchemy ORM or parameterized `text()` queries only — never string-concatenate user input into SQL
- CORS is configured in `src/app/middleware/cors.py`; restrict allowed origins to explicit domains in production
- Auth endpoints (`/auth/login`, `/auth/register`) are rate-limited at 5 req/min per IP
- Hash passwords with `passlib[bcrypt]` (cost factor 12+); never store plaintext
- Rotate JWT secret key via `SECRET_KEY` env var; set short `ACCESS_TOKEN_EXPIRE_MINUTES` (default 30)

## Deployment

- Railway, Fly.io, or Docker; Python 3.12 base image
- Run migrations at startup: `alembic upgrade head && uvicorn app.main:app --host 0.0.0.0 --port $PORT`
- Required env vars: `DATABASE_URL`, `SECRET_KEY`, `CORS_ORIGINS`
- Gunicorn + uvicorn workers for production: `gunicorn app.main:app -k uvicorn.workers.UvicornWorker`

## When working with Claude in this project

- Always create the Pydantic schema before writing the route handler — the schema is the contract
- Run `alembic upgrade head` after any model change; never edit migration files after they have been applied
- Do NOT commit `.env` — use `.env.example` as the tracked template
