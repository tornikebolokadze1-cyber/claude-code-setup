"""Entry point — run the agent interactively."""

import uuid

from dotenv import load_dotenv

from agent.graph import create_agent_graph
from agent.utils.logging import setup_logging

load_dotenv()
logger = setup_logging()


def run_agent(query: str, thread_id: str | None = None) -> str:
    """Run the agent with a single query.

    Args:
        query: The user's question or instruction.
        thread_id: Optional thread ID for conversation continuity.

    Returns:
        The agent's final response text.
    """
    graph = create_agent_graph()
    config = {"configurable": {"thread_id": thread_id or str(uuid.uuid4())}}

    result = graph.invoke(
        {"messages": [{"role": "user", "content": query}]},
        config=config,
    )

    # Extract the last AI message
    final_message = result["messages"][-1]
    return final_message.content


def main() -> None:
    """Interactive REPL for the agent."""
    logger.info("Agent started. Type 'quit' to exit.")
    thread_id = str(uuid.uuid4())

    while True:
        try:
            user_input = input("\nYou: ").strip()
        except (EOFError, KeyboardInterrupt):
            print("\nGoodbye!")
            break

        if not user_input:
            continue
        if user_input.lower() in ("quit", "exit", "q"):
            print("Goodbye!")
            break

        logger.info(f"Processing: {user_input[:80]}...")
        response = run_agent(user_input, thread_id=thread_id)
        print(f"\nAgent: {response}")


if __name__ == "__main__":
    main()
