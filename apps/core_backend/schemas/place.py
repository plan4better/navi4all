from pydantic import BaseModel, computed_field
from schemas.coordinates import Coordinates
from enum import Enum


class Place(BaseModel):
    id: str
    name: str
    type: "PlaceType"
    address: str
    street: str | None = None
    locality: str | None = None
    postcode: str | None = None
    coordinates: Coordinates

    @computed_field
    def description(self) -> str:
        """Produces a simplified subtext from the address."""
        parts = [self.street, self.locality, self.postcode]
        return (
            ", ".join(part for part in parts if part)
            if self.street or self.locality and self.name != self.locality
            else self.address
        )

class PlaceType(Enum):
    ADDRESS = "address"
    PARKING_SPOT = "parkingSpot"
    PARKING_SITE = "parkingSite"
