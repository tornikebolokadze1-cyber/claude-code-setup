"""Configuration loaded from environment variables."""

from __future__ import annotations

import os
from dataclasses import dataclass

from dotenv import load_dotenv


@dataclass(frozen=True)
class Config:
    """Application configuration."""

    bot_token: str
    log_level: str = "INFO"

    @classmethod
    def from_env(cls) -> Config:
        """Build config from the current environment.

        Loads a ``.env`` file if one exists, then reads required variables.

        Raises:
            SystemExit: If ``TELEGRAM_BOT_TOKEN`` is missing.
        """
        load_dotenv()

        token = os.getenv("TELEGRAM_BOT_TOKEN")
        if not token:
            raise SystemExit(
                "TELEGRAM_BOT_TOKEN is not set. "
                "Copy .env.example to .env and add your token."
            )

        return cls(
            bot_token=token,
            log_level=os.getenv("LOG_LEVEL", "INFO").upper(),
        )
