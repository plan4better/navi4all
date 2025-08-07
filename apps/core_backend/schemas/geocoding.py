from pydantic import BaseModel
from schemas.coordinates import Coordinates
from enum import Enum


class SupportedGeocodingProviders(str, Enum):
    NONE = "none"
    PELIAS = "pelias"
    GOOGLE = "google"


"""Request and response models exposed via the API"""


class GeocodingAutocompleteRequestModel(BaseModel):
    query: str
    focus_point: Coordinates | None = None
    limit: int | None = 5
