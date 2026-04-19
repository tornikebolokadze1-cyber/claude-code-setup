"""Bot entry point — build the Application and start polling."""

from __future__ import annotations

import logging

from telegram.ext import Application

from bot.config import Config
from bot.handlers import register_handlers
from bot.utils.logger import setup_logging

logger = logging.getLogger(__name__)


def main() -> None:
    """Configure and run the bot."""
    config = Config.from_env()
    setup_logging(config.log_level)

    logger.info("Starting bot...")

    app: Application = (  # type: ignore[type-arg]
        Application.builder()
        .token(config.bot_token)
        .build()
    )

    register_handlers(app)

    logger.info("Bot is polling for updates. Press Ctrl+C to stop.")
    app.run_polling()


if __name__ == "__main__":
    main()
