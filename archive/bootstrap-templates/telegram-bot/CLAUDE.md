# Telegram Bot — Python + python-telegram-bot

Async Telegram bot using python-telegram-bot v20+ with handler-per-command structure, webhook mode for production, and environment-based configuration.

## Tech stack

- Python 3.12
- python-telegram-bot v20+ (async, Application builder pattern)
- httpx (async HTTP client for external calls)
- Pydantic v2 + pydantic-settings (config validation)
- pytest + pytest-asyncio (testing)
- ruff (linting)

## Build & test

| Command | Purpose |
|---------|---------|
| `pip install -r requirements.txt` | Install pinned dependencies |
| `python -m bot.main` | Run the bot (from `src/`, polling mode) |
| `pytest` | Run full test suite |
| `ruff check src/` | Lint source files |

## Code conventions

- One handler per command file under `src/bot/handlers/`; all handlers registered via `register_handlers(app)` in `handlers/__init__.py`
- Gate admin-only commands with a `@restricted` decorator that checks `update.effective_user.id` against `ADMIN_CHAT_IDS`
- Use webhook mode in production (faster, no polling overhead); long-poll only for local development
- Escape user-facing text with `telegram.helpers.escape_markdown` before any `parse_mode=ParseMode.MARKDOWN_V2` reply
- All configuration (token, webhook URL, admin IDs) loaded via `config.py` using pydantic-settings — nothing hardcoded

## Security

- Verify the `X-Telegram-Bot-Api-Secret-Token` header on every inbound webhook request; reject with 403 if missing or mismatched
- Never log full message text — log `update.update_id` and `user.id` only
- Store `TELEGRAM_BOT_TOKEN` and `TELEGRAM_WEBHOOK_SECRET` in `.env`; rotate the secret by updating both Telegram's webhook registration and your env var simultaneously
- Validate and sanitize any user-provided input before passing it to external services or databases
- Set webhook with `drop_pending_updates=True` on restart to avoid replaying stale messages

## Deployment

- Railway (webhook mode, always-on) or any VPS with a public HTTPS endpoint
- Required env vars: `TELEGRAM_BOT_TOKEN`, `TELEGRAM_WEBHOOK_URL` (production only), `TELEGRAM_WEBHOOK_SECRET`
- Register the webhook at startup: `await app.bot.set_webhook(url=config.webhook_url, secret_token=config.webhook_secret)`
- No cold-start concerns for polling; webhook mode benefits from a persistent process (not serverless)

## When working with Claude in this project

- Always add webhook signature verification before processing any payload from Telegram
- Prefer `await update.message.reply_text(...)` over `await context.bot.send_message(...)` — it handles `chat_id` automatically
- Do NOT commit `.env` — use `.env.example` as the tracked template
