from pydantic import BaseModel, field_validator, model_validator
from datetime import datetime
from enum import Enum
from uuid import UUID

class Coordinates(BaseModel):
    lat: float
    lon: float

class Mode(str, Enum):
    airplane = "AIRPLANE"
    bicycle = "BICYCLE"
    bus = "BUS"
    cable_car = "CABLE_CAR"
    car = "CAR"
    coach = "COACH"
    ferry = "FERRY"
    flex = "FLEX"
    funicular = "FUNICULAR"
    gondola = "GONDOLA"
    rail = "RAIL"
    scooter = "SCOOTER"
    subway = "SUBWAY"
    tram = "TRAM"
    carpool = "CARPOOL"
    taxi = "TAXI"
    transit = "TRANSIT"
    walk = "WALK"
    trolleybus = "TROLLEYBUS"
    monorail = "MONORAIL"

class LegSummary(BaseModel):
    mode: Mode
    duration: int
    ratio: float | None = None

class Itinerary(BaseModel):
    journey_id: UUID
    duration: int
    start_time: datetime
    end_time: datetime
    origin: Coordinates
    destination: Coordinates
    legs: list[LegSummary]
    
    @model_validator(mode="before")
    def compute_leg_ratios(cls, itinerary: dict[str, any]) -> dict[str, any]:
        total_duration = itinerary["duration"]
        for leg in itinerary["legs"]:
            leg.ratio = round(leg.duration / total_duration, 2) if total_duration > 0 else 0
        return itinerary


"""Request and response models exposed via the API"""

class PlanRequestModel(BaseModel):
    origin: Coordinates
    destination: Coordinates
    date: str
    time: str
    time_is_arrival: bool = False
    transport_modes: list[Mode]
    accessible: bool = False
    num_itineraries: int = 3

    @field_validator("date", mode="before")
    @classmethod
    def validate_date(cls, value: str):
        try:
            datetime.strptime(value, "%Y-%m-%d")
            return value
        except ValueError:
            raise ValueError("Date must be in the format 'YYYY-MM-DD'.")

    @field_validator("time", mode="before")
    @classmethod
    def validate_time(cls, value: str):
        try:
            datetime.strptime(value, "%H:%M:%S")
            return value
        except ValueError:
            raise ValueError("Time must be in the format 'HH:MM:SS'.")

class PlanResponseModel(BaseModel):
    itineraries: list[Itinerary]
