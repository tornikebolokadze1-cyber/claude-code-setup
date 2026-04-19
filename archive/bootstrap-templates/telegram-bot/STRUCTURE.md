# Telegram Bot Project Structure

```
telegram-bot/
├── .env.example          # Environment variable template
├── pyproject.toml        # Project metadata, dependencies, tool config
├── requirements.txt      # Pinned dependency versions
├── src/
│   └── bot/
│       ├── __init__.py       # Package marker with version
│       ├── main.py           # Entry point — builds and runs the Application
│       ├── config.py         # Loads settings from environment variables
│       ├── handlers/
│       │   ├── __init__.py   # Re-exports handler registration function
│       │   ├── start.py      # /start command
│       │   ├── help.py       # /help command
│       │   └── echo.py       # Echoes any non-command text message
│       └── utils/
│           └── logger.py     # Configures stdlib logging
└── tests/
    ├── __init__.py
    └── test_handlers.py      # Unit tests for all handlers
```

## Quick Start

1. Copy `.env.example` to `.env` and fill in your bot token.
2. Install dependencies: `pip install -r requirements.txt`
3. Run the bot: `python -m bot.main` (from the `src/` directory)

## Key Design Decisions

- **python-telegram-bot v20+** — fully async, using `Application` builder pattern.
- **Config via environment** — single `config.py` reads all settings; nothing is hard-coded.
- **Handler registration** — `handlers/__init__.py` exposes `register_handlers(app)` so `main.py` stays clean.
- **Logging** — centralized in `utils/logger.py`; call `setup_logging()` once at startup.
