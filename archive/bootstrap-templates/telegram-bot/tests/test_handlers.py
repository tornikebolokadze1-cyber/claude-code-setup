"""Tests for bot handlers."""

from __future__ import annotations

from unittest.mock import AsyncMock, MagicMock, patch

import pytest
from telegram import Chat, Message, Update, User

from bot.handlers.echo import echo_handler
from bot.handlers.help import help_handler
from bot.handlers.start import start_handler


def _make_update(text: str = "hello", first_name: str = "Alice") -> Update:
    """Build a minimal Update object with mocked reply_text."""
    user = User(id=1, is_bot=False, first_name=first_name)
    chat = Chat(id=1, type=Chat.PRIVATE)
    message = MagicMock(spec=Message)
    message.text = text
    message.chat = chat
    message.from_user = user
    message.reply_text = AsyncMock()

    update = MagicMock(spec=Update)
    update.message = message
    update.effective_user = user
    return update


@pytest.fixture
def context() -> MagicMock:
    return MagicMock()


@pytest.mark.asyncio
async def test_start_handler_greets_user(context: MagicMock) -> None:
    update = _make_update(first_name="Bob")

    await start_handler(update, context)

    update.message.reply_text.assert_awaited_once()
    reply_text: str = update.message.reply_text.call_args[0][0]
    assert "Bob" in reply_text


@pytest.mark.asyncio
async def test_help_handler_lists_commands(context: MagicMock) -> None:
    update = _make_update()

    await help_handler(update, context)

    update.message.reply_text.assert_awaited_once()
    reply_text: str = update.message.reply_text.call_args[0][0]
    assert "/start" in reply_text
    assert "/help" in reply_text


@pytest.mark.asyncio
async def test_echo_handler_repeats_message(context: MagicMock) -> None:
    update = _make_update(text="ping")

    await echo_handler(update, context)

    update.message.reply_text.assert_awaited_once_with("ping")
