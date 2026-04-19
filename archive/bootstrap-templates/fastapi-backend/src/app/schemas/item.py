"""Item request/response schemas."""

from datetime import datetime

from pydantic import BaseModel, Field


class ItemBase(BaseModel):
    title: str = Field(..., min_length=1, max_length=255)
    description: str | None = None
    is_active: bool = True


class ItemCreate(ItemBase):
    pass


class ItemUpdate(BaseModel):
    title: str | None = Field(None, min_length=1, max_length=255)
    description: str | None = None
    is_active: bool | None = None


class ItemResponse(ItemBase):
    id: int
    created_at: datetime
    updated_at: datetime

    model_config = {"from_attributes": True}
