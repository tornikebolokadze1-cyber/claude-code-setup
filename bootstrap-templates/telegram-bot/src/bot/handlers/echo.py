"""Handler that echoes user text messages."""

from __future__ import annotations

import logging

from telegram import Update
from telegram.ext import ContextTypes

logger = logging.getLogger(__name__)


async def echo_handler(update: Update, context: ContextTypes.DEFAULT_TYPE) -> None:
    """Repeat the user's message back to them."""
    text = update.message.text if update.message else ""  # type: ignore[union-attr]
    logger.debug("Echoing message: %s", text)
    await update.message.reply_text(text)  # type: ignore[union-attr]
