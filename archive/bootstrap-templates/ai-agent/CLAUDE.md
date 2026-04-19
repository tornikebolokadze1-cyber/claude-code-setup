# AI Agent — Python + LangChain/LangGraph

Python-based autonomous agent using LangChain and LangGraph with a planner → executor → reviewer node pipeline.

## Tech stack

- Python 3.12
- LangChain + LangGraph (agent graph orchestration)
- LangChain-Community (tool integrations)
- Pydantic v2 (state schemas and config)
- pytest + pytest-asyncio (testing)
- mypy + ruff (type checking and linting)

## Build & test

| Command | Purpose |
|---------|---------|
| `pip install -e ".[dev]"` | Install package in editable mode with dev extras |
| `python -m agent.main` | Run the agent (from `src/`) |
| `pytest` | Run full test suite |
| `pytest tests/test_tools.py` | Run tool unit tests only |
| `mypy src/` | Type-check the source tree |
| `ruff check src/` | Lint source files |

## Code conventions

- One LangGraph node per file under `src/agent/nodes/`; each node is a pure function `(state: AgentState) -> dict`
- Use `PromptTemplate` from LangChain — never f-strings — to build prompts; this keeps injection surface auditable
- Avoid hidden side-effects inside nodes; all state mutations must be returned in the output dict
- Every tool in `src/agent/tools/` must implement the `BaseTool` interface with explicit `name`, `description`, and `args_schema`
- Cap LLM call token budgets per node; set `max_tokens` explicitly to prevent runaway costs

## Security

- `langchain-community` has historically contained PromptInjection chains; sanitize all text retrieved from external tools before passing back to the LLM
- Never pass raw user input directly into a `PromptTemplate` without stripping control characters first
- Store `OPENAI_API_KEY`, `ANTHROPIC_API_KEY`, and any other secrets in `.env` — never in source code
- Validate tool outputs with Pydantic before incorporating them into agent state
- Limit tool permissions to least-privilege (e.g., read-only file access, scoped API keys)

## Deployment

- Deploy as a container (Docker) or as a background worker on Railway / Fly.io
- Required env vars: `OPENAI_API_KEY` (or model provider key), `LANGCHAIN_TRACING_V2` (optional), `LANGCHAIN_API_KEY` (optional, for LangSmith)
- No web server needed for batch agents; add FastAPI wrapper only when exposing an HTTP trigger

## When working with Claude in this project

- Always define the full `AgentState` TypedDict in `state.py` before adding new nodes — shared state is the contract between nodes
- Prefer deterministic tool interfaces with typed `args_schema`; avoid free-form string parsing inside tools
- Do NOT commit `.env` — use `.env.example` as the tracked template
