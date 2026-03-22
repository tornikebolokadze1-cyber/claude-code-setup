"""Reviewer node — checks if the agent should continue or stop."""

from agent.config import settings
from agent.state import AgentState


def reviewer_node(state: AgentState) -> dict:
    """Check iteration limits and decide whether to continue."""
    if state.iterations >= settings.agent_max_iterations:
        return {"final_answer": "Maximum iterations reached. Returning best available answer."}
    return {}
