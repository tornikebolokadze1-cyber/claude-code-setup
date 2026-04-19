"""Planner node — decides whether to use tools or respond directly."""

from langchain_core.messages import AIMessage

from agent.config import settings
from agent.state import AgentState


def planner_node(state: AgentState) -> dict:
    """Route to tools or final answer based on the LLM's response.

    This node is handled implicitly by the LLM with tool binding.
    The LLM decides whether to call tools or produce a final answer.
    """
    # Increment iteration counter
    return {"iterations": state.iterations + 1}
