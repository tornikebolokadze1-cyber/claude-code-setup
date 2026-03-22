"""Agent configuration using pydantic-settings."""

from pydantic_settings import BaseSettings


class Settings(BaseSettings):
    """Agent settings loaded from environment variables."""

    # LLM
    openai_api_key: str = ""
    agent_model: str = "gpt-4o-mini"
    agent_temperature: float = 0.0
    agent_max_iterations: int = 10
    agent_verbose: bool = True

    # LangSmith (optional)
    langchain_tracing_v2: bool = False
    langchain_api_key: str = ""
    langchain_project: str = "default"

    model_config = {"env_file": ".env", "env_file_encoding": "utf-8"}


settings = Settings()
