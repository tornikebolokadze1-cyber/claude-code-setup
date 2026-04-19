"""Health check schema."""

from datetime import datetime, timezone

from pydantic import BaseModel, Field


class HealthResponse(BaseModel):
    status: str = "healthy"
    timestamp: str = Field(default_factory=lambda: datetime.now(timezone.utc).isoformat())
    version: str = "0.1.0"
    uptime: float = 0.0
