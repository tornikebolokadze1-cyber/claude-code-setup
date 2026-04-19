"""LangGraph agent graph definition."""

from langchain_openai import ChatOpenAI
from langgraph.graph import END, StateGraph
from langgraph.prebuilt import ToolNode

from agent.config import settings
from agent.memory import get_checkpointer
from agent.prompts import SYSTEM_PROMPT
from agent.state import AgentState
from agent.tools import ALL_TOOLS


def _should_continue(state: AgentState) -> str:
    """Route: if the last message has tool calls, go to tools. Otherwise end."""
    last_message = state.messages[-1]
    if hasattr(last_message, "tool_calls") and last_message.tool_calls:
        return "tools"
    return END


def create_agent_graph():
    """Build and compile the agent graph.

    Graph flow:
        [START] -> agent -> (tool_calls?) -> tools -> agent -> ... -> [END]
    """
    # Initialize the LLM with tool binding
    llm = ChatOpenAI(
        model=settings.agent_model,
        temperature=settings.agent_temperature,
        api_key=settings.openai_api_key,
    ).bind_tools(ALL_TOOLS)

    # Define the agent node
    def agent_node(state: AgentState) -> dict:
        """Call the LLM with the current messages."""
        messages = [{"role": "system", "content": SYSTEM_PROMPT}] + list(state.messages)
        response = llm.invoke(messages)
        return {"messages": [response], "iterations": state.iterations + 1}

    # Build the graph
    graph = StateGraph(AgentState)

    # Add nodes
    graph.add_node("agent", agent_node)
    graph.add_node("tools", ToolNode(ALL_TOOLS))

    # Set entry point
    graph.set_entry_point("agent")

    # Add edges
    graph.add_conditional_edges("agent", _should_continue, {"tools": "tools", END: END})
    graph.add_edge("tools", "agent")

    # Compile with checkpointer for memory
    checkpointer = get_checkpointer()
    return graph.compile(checkpointer=checkpointer)
