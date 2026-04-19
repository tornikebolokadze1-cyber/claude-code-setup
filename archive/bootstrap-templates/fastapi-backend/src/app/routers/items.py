"""Example CRUD endpoints for items."""

from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session

from app.dependencies import get_db
from app.schemas.item import ItemCreate, ItemResponse, ItemUpdate
from app.services.item_service import ItemService

router = APIRouter(prefix="/items", tags=["items"])


@router.get("/", response_model=list[ItemResponse])
async def list_items(skip: int = 0, limit: int = 20, db: Session = Depends(get_db)):
    """List all items with pagination."""
    service = ItemService(db)
    return service.get_all(skip=skip, limit=limit)


@router.get("/{item_id}", response_model=ItemResponse)
async def get_item(item_id: int, db: Session = Depends(get_db)):
    """Get a single item by ID."""
    service = ItemService(db)
    item = service.get_by_id(item_id)
    if not item:
        raise HTTPException(status_code=404, detail="Item not found")
    return item


@router.post("/", response_model=ItemResponse, status_code=201)
async def create_item(data: ItemCreate, db: Session = Depends(get_db)):
    """Create a new item."""
    service = ItemService(db)
    return service.create(data)


@router.put("/{item_id}", response_model=ItemResponse)
async def update_item(item_id: int, data: ItemUpdate, db: Session = Depends(get_db)):
    """Update an existing item."""
    service = ItemService(db)
    item = service.update(item_id, data)
    if not item:
        raise HTTPException(status_code=404, detail="Item not found")
    return item


@router.delete("/{item_id}", status_code=204)
async def delete_item(item_id: int, db: Session = Depends(get_db)):
    """Delete an item."""
    service = ItemService(db)
    if not service.delete(item_id):
        raise HTTPException(status_code=404, detail="Item not found")
