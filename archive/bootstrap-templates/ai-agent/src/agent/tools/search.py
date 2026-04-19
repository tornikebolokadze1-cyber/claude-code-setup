"""Web search tool (mock implementation — replace with real search API)."""

from langchain_core.tools import tool


@tool
def search_tool(query: str) -> str:
    """Search the web for information.

    This is a placeholder implementation. Replace with a real search API:
    - Tavily: from langchain_community.tools.tavily_search import TavilySearchResults
    - SerpAPI: from langchain_community.tools import SerpAPIWrapper
    - DuckDuckGo: from langchain_community.tools import DuckDuckGoSearchRun

    Args:
        query: The search query.

    Returns:
        Search results as a string.
    """
    # TODO: Replace with a real search API
    return (
        f"[Mock search results for '{query}']\n"
        "1. This is a placeholder result. Replace search_tool with a real search API.\n"
        "2. See the docstring for recommended search tool options."
    )
