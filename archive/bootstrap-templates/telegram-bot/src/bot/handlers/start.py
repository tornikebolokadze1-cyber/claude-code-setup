"""Handler for the /start command."""

from __future__ import annotations

import logging

from telegram import Update
from telegram.ext import ContextTypes

logger = logging.getLogger(__name__)


async def start_handler(update: Update, context: ContextTypes.DEFAULT_TYPE) -> None:
    """Greet the user when they send /start."""
    user = update.effective_user
    name = user.first_name if user else "there"
    logger.info("User %s triggered /start", name)
    await update.message.reply_text(  # type: ignore[union-attr]
        f"Hello, {name}! I'm your bot. Send /help to see what I can do."
    )
