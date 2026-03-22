"""Health check endpoint."""

import time

from fastapi import APIRouter

from app.schemas.health import HealthResponse

router = APIRouter(tags=["health"])

_start_time = time.time()


@router.get("/health", response_model=HealthResponse)
async def health_check() -> HealthResponse:
    """Return application health status."""
    return HealthResponse(
        status="healthy",
        version="0.1.0",
        uptime=round(time.time() - _start_time, 2),
    )
