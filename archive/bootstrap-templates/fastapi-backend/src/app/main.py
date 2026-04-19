"""FastAPI application entry point."""

from contextlib import asynccontextmanager

from fastapi import FastAPI

from app.config import settings
from app.middleware.cors import setup_cors
from app.routers import auth, health, items


@asynccontextmanager
async def lifespan(app: FastAPI):
    """Startup and shutdown events."""
    # Startup
    print(f"Starting {settings.app_name} in {settings.app_env} mode")
    yield
    # Shutdown
    print("Shutting down...")


def create_app() -> FastAPI:
    """Application factory."""
    app = FastAPI(
        title=settings.app_name,
        version="0.1.0",
        docs_url="/docs" if settings.debug else None,
        redoc_url="/redoc" if settings.debug else None,
        lifespan=lifespan,
    )

    # Middleware
    setup_cors(app)

    # Routers
    app.include_router(health.router)
    app.include_router(items.router, prefix=settings.api_prefix)
    app.include_router(auth.router, prefix=settings.api_prefix)

    return app


app = create_app()

if __name__ == "__main__":
    import uvicorn

    uvicorn.run("app.main:app", host=settings.host, port=settings.port, reload=settings.debug)
