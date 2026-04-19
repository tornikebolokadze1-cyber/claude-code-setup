"""Application settings."""

from pydantic_settings import BaseSettings


class Settings(BaseSettings):
    app_name: str = "{{PROJECT_NAME}}"
    app_env: str = "development"
    debug: bool = True
    api_prefix: str = "/api/v1"

    host: str = "0.0.0.0"
    port: int = 8000

    database_url: str = "sqlite:///./app.db"

    jwt_secret: str = "change-this-in-production"
    jwt_algorithm: str = "HS256"
    jwt_expiration_minutes: int = 30

    cors_origins: str = "http://localhost:3000,http://localhost:5173"
    rate_limit_per_minute: int = 60

    model_config = {"env_file": ".env", "env_file_encoding": "utf-8"}

    @property
    def cors_origin_list(self) -> list[str]:
        return [o.strip() for o in self.cors_origins.split(",")]


settings = Settings()
