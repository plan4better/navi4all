from pydantic_settings import BaseSettings


class Settings(BaseSettings):
    # API settings
    API_VERSION: str = "/v1"

    # Directory and path settings
    TEMPLATES_DIR: str = "/app/apps/core_backend/templates"

    # Adaptor settings
    OPEN_TRIP_PLANNER_URL: str
    OPEN_TRIP_PLANNER_PLAN_TEMPLATE: str = "plan.graphql"

    # Redis settings
    REDIS_HOST: str = "navi4all-redis"
    REDIS_PORT: int = 6379


settings = Settings()
