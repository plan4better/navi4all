from pydantic import BaseModel, field_validator
from schemas.coordinates import Coordinates
from schemas.place import Place
from enum import Enum
from datetime import datetime
from fastapi import HTTPException


class SupportedGeocodingProviders(str, Enum):
    NONE = "none"
    PELIAS = "pelias"
    GOOGLE = "google"


"""Request and response models exposed via the API"""


class GeocodingAutocompleteRequestModel(BaseModel):
    query: str
    timestamp: datetime
    focus_point: Coordinates | None = None
    limit: int | None = 5

    @field_validator("timestamp", mode="before")
    def validate_timestamp(cls, value: str | datetime) -> datetime:
        if value is None:
            raise ValueError("Timestamp must be provided")
        elif isinstance(value, str):
            try:
                value = datetime.fromisoformat(value)
            except ValueError:
                raise ValueError("Invalid timestamp format, must be ISO 8601")
        return value
    
class GeocodingAutocompleteResponseModel(BaseModel):
    timestamp: datetime
    results: list[Place]
