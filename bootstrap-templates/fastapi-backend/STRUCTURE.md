# API Backend — FastAPI + Python

## Directory Tree

```
project-name/
├── .env                        # Local env vars (git-ignored)
├── .env.example                # Env template
├── .gitignore
├── .python-version
├── pyproject.toml              # Project config + dependencies
├── alembic.ini                 # DB migration config
├── src/
│   └── app/
│       ├── __init__.py
│       ├── main.py             # FastAPI app entry point
│       ├── config.py           # Settings (pydantic-settings)
│       ├── dependencies.py     # Shared FastAPI dependencies
│       ├── routers/            # API route handlers
│       │   ├── __init__.py
│       │   ├── health.py       # GET /health
│       │   ├── auth.py         # Auth endpoints
│       │   └── items.py        # Example CRUD endpoints
│       ├── models/             # Database models (SQLAlchemy)
│       │   ├── __init__.py
│       │   ├── base.py         # Base model class
│       │   └── item.py         # Example model
│       ├── schemas/            # Pydantic request/response schemas
│       │   ├── __init__.py
│       │   ├── health.py       # Health response schema
│       │   └── item.py         # Item schemas
│       ├── services/           # Business logic layer
│       │   ├── __init__.py
│       │   └── item_service.py # Item CRUD service
│       ├── middleware/          # Custom middleware
│       │   ├── __init__.py
│       │   ├── auth.py         # Auth middleware
│       │   ├── cors.py         # CORS configuration
│       │   └── rate_limit.py   # Rate limiting
│       └── db/                 # Database setup
│           ├── __init__.py
│           ├── session.py      # Session factory
│           └── migrations/     # Alembic migrations
│               ├── env.py
│               └── versions/
│                   └── .gitkeep
├── tests/
│   ├── __init__.py
│   ├── conftest.py             # Test fixtures + test client
│   ├── test_health.py          # Health endpoint test
│   └── test_items.py           # Items endpoint test
└── scripts/
    └── seed.py                 # DB seed script
```
