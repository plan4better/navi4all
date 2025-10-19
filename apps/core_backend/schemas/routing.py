from pydantic import BaseModel, field_validator, model_validator
from datetime import datetime
from enum import Enum
from uuid import UUID
from schemas.coordinates import Coordinates


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


class RelativeDirection(Enum):
    depart = "DEPART"
    hard_left = "HARD_LEFT"
    left = "LEFT"
    slightly_left = "SLIGHTLY_LEFT"
    continue_ = "CONTINUE"
    slightly_right = "SLIGHTLY_RIGHT"
    right = "RIGHT"
    hard_right = "HARD_RIGHT"
    circle_clockwise = "CIRCLE_CLOCKWISE"
    circle_counterclockwise = "CIRCLE_COUNTERCLOCKWISE"
    elevator = "ELEVATOR"
    uturn_left = "UTURN_LEFT"
    uturn_right = "UTURN_RIGHT"
    enter_station = "ENTER_STATION"
    exit_station = "EXIT_STATION"
    follow_signs = "FOLLOW_SIGNS"

class AbsoluteDirection(Enum):
    north = "NORTH"
    northeast = "NORTHEAST"
    east = "EAST"
    southeast = "SOUTHEAST"
    south = "SOUTH"
    southwest = "SOUTHWEST"
    west = "WEST"
    northwest = "NORTHWEST"


class Step(BaseModel):
    distance: float
    lon: float
    lat: float
    relative_direction: RelativeDirection
    absolute_direction: AbsoluteDirection
    street_name: str
    bogus_name: bool


class LegSummary(BaseModel):
    mode: Mode
    duration: int
    distance: int
    ratio: float | None = None
    geometry: str


class LegDetailed(LegSummary):
    steps: list[Step]


class ItineraryBase(BaseModel):
    itinerary_id: UUID
    duration: int
    start_time: datetime
    end_time: datetime
    origin: Coordinates
    destination: Coordinates


class ItinerarySummary(ItineraryBase):
    legs: list[LegSummary]
    
    @model_validator(mode="before")
    def compute_leg_ratios(cls, itinerary: dict[str, any]) -> dict[str, any]:
        total_duration = itinerary["duration"]
        for leg in itinerary["legs"]:
            leg.ratio = (
                round(leg.duration / total_duration, 2) if total_duration > 0 else 0
            )
        return itinerary


class ItineraryDetailed(ItineraryBase):
    legs: list[LegDetailed]


"""Request and response models exposed via the API"""


class RoutingPlanRequestModel(BaseModel):
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


class RoutingPlanResponseModel(BaseModel):
    # TODO: Include additional info about the plan
    itineraries: list[ItinerarySummary]
    
class ItineraryResponseModel(ItineraryDetailed):
    pass
