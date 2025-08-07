from pydantic_settings import BaseSettings
from pydantic import model_validator
from schemas.geocoding import SupportedGeocodingProviders


class Settings(BaseSettings):
    # API settings
    API_VERSION: str = "/v1"

    # Directory and path settings
    TEMPLATES_DIR: str = "/app/apps/core_backend/templates"

    # Redis settings
    REDIS_HOST: str = "navi4all-redis"
    REDIS_PORT: int = 6379

    # Adaptor settings
    OPEN_TRIP_PLANNER_URL: str
    OPEN_TRIP_PLANNER_PLAN_TEMPLATE: str = "plan.graphql"

    GEOCODING_PROVIDER: SupportedGeocodingProviders
    GEOCODING_PROVIDER_API_URL: str | None = None
    GEOCODING_PROVIDER_API_KEY: str | None = None

    @model_validator(mode="after")
    def validate_geocoding_provider(cls, values: "Settings") -> dict[str, any]:
        if values.GEOCODING_PROVIDER != SupportedGeocodingProviders.NONE:
            if values.GEOCODING_PROVIDER_API_URL is None:
                raise ValueError("GEOCODING_PROVIDER_API_URL must be set")
            if values.GEOCODING_PROVIDER_API_KEY is None:
                raise ValueError("GEOCODING_PROVIDER_API_KEY must be set")
        return values


settings = Settings()
