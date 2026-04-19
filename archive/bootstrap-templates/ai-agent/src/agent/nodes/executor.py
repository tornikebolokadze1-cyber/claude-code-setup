"""Executor node — runs tools selected by the LLM."""

from langgraph.prebuilt import ToolNode

from agent.tools import ALL_TOOLS

# The ToolNode automatically executes tools based on the LLM's tool calls
executor_node = ToolNode(ALL_TOOLS)
