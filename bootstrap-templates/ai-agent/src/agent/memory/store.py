"""Checkpoint store for agent state persistence."""

from langgraph.checkpoint.memory import MemorySaver


def get_checkpointer() -> MemorySaver:
    """Get a checkpointer for persisting agent state.

    For production, replace MemorySaver with a persistent backend:
    - SqliteSaver: from langgraph.checkpoint.sqlite import SqliteSaver
    - PostgresSaver: from langgraph.checkpoint.postgres import PostgresSaver
    """
    return MemorySaver()
