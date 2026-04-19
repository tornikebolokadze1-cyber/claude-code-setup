"""Agent state schema for LangGraph."""

from typing import Annotated, Sequence

from langchain_core.messages import BaseMessage
from langgraph.graph.message import add_messages
from pydantic import BaseModel, Field


class AgentState(BaseModel):
    """The state that flows through the agent graph.

    Attributes:
        messages: Conversation messages (auto-appended via add_messages reducer).
        iterations: Number of tool-use iterations so far.
        final_answer: The agent's final response after reasoning.
    """

    messages: Annotated[Sequence[BaseMessage], add_messages] = Field(default_factory=list)
    iterations: int = 0
    final_answer: str = ""
