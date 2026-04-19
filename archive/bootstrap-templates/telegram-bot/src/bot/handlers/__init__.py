"""Handler registration."""

from __future__ import annotations

from telegram.ext import Application, CommandHandler, MessageHandler, filters

from bot.handlers.echo import echo_handler
from bot.handlers.help import help_handler
from bot.handlers.start import start_handler


def register_handlers(app: Application) -> None:  # type: ignore[type-arg]
    """Add all handlers to the application."""
    app.add_handler(CommandHandler("start", start_handler))
    app.add_handler(CommandHandler("help", help_handler))
    # Echo must be last — it catches all non-command text messages.
    app.add_handler(MessageHandler(filters.TEXT & ~filters.COMMAND, echo_handler))
