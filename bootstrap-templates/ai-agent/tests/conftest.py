"""Test fixtures for the agent."""

import sys
from pathlib import Path

import pytest

# Add src to path so imports work
sys.path.insert(0, str(Path(__file__).parent.parent / "src"))


@pytest.fixture
def sample_query() -> str:
    return "What is 2 + 2?"
