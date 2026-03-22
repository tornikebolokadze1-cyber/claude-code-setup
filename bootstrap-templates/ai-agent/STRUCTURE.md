# AI Agent — Python + LangChain/LangGraph

## Directory Tree

```
project-name/
├── .env                        # Local environment variables (git-ignored)
├── .env.example                # Template for env vars
├── .gitignore                  # Git ignore rules
├── .python-version             # Python version pinning
├── pyproject.toml              # Project config and dependencies
├── README.md                   # (only if user requests)
├── src/
│   └── agent/
│       ├── __init__.py
│       ├── main.py             # Entry point — run the agent
│       ├── graph.py            # LangGraph state graph definition
│       ├── state.py            # Agent state schema
│       ├── config.py           # Configuration and settings
│       ├── nodes/              # Graph nodes (each is a function)
│       │   ├── __init__.py
│       │   ├── planner.py      # Planning node
│       │   ├── executor.py     # Tool execution node
│       │   └── reviewer.py     # Output review node
│       ├── tools/              # Agent tools
│       │   ├── __init__.py
│       │   ├── search.py       # Web search tool
│       │   ├── calculator.py   # Calculator tool
│       │   └── base.py         # Base tool utilities
│       ├── prompts/            # System prompts and templates
│       │   ├── __init__.py
│       │   ├── system.py       # System prompt
│       │   └── templates.py    # Prompt templates
│       ├── memory/             # Memory and state persistence
│       │   ├── __init__.py
│       │   └── store.py        # Checkpoint store
│       └── utils/
│           ├── __init__.py
│           └── logging.py      # Logging setup
├── tests/
│   ├── __init__.py
│   ├── conftest.py             # Test fixtures
│   ├── test_agent.py           # Agent integration test
│   └── test_tools.py           # Tool unit tests
└── scripts/
    └── run.py                  # Quick run script
```
