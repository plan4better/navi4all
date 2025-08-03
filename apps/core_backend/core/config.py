from pydantic import BaseModel
from pydantic_settings import BaseSettings

class Settings(BaseSettings):
    API_VERSION: str = "/v1"
    
    # Constants for the routing endpoints
    ROUTING_ENGINE_URL: str

settings = Settings()
