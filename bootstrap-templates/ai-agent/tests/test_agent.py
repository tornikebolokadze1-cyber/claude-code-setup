"""Integration tests for the agent graph."""

import sys
from pathlib import Path

import pytest

sys.path.insert(0, str(Path(__file__).parent.parent / "src"))

from agent.state import AgentState


class TestAgentState:
    def test_default_state(self):
        state = AgentState()
        assert state.messages == []
        assert state.iterations == 0
        assert state.final_answer == ""

    def test_state_with_iterations(self):
        state = AgentState(iterations=5)
        assert state.iterations == 5


# Note: Full agent integration tests require an API key.
# Use pytest marks to skip in CI:
#
# @pytest.mark.skipif(not os.getenv("OPENAI_API_KEY"), reason="No API key")
# def test_agent_full_run():
#     from agent.main import run_agent
#     result = run_agent("What is 2 + 2?")
#     assert "4" in result
