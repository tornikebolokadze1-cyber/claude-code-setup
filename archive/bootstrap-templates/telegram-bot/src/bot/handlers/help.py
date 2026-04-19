"""Handler for the /help command."""

from __future__ import annotations

import logging

from telegram import Update
from telegram.ext import ContextTypes

logger = logging.getLogger(__name__)

HELP_TEXT = (
    "Available commands:\n"
    "/start - Start the bot\n"
    "/help  - Show this help message\n"
    "\n"
    "Send me any text and I'll echo it back!"
)


async def help_handler(update: Update, context: ContextTypes.DEFAULT_TYPE) -> None:
    """Reply with the list of available commands."""
    logger.info("User requested /help")
    await update.message.reply_text(HELP_TEXT)  # type: ignore[union-attr]
