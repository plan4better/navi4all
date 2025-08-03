from pydantic import BaseModel, field_validator, model_validator
from datetime import datetime
from enum import Enum
from core.utils import to_snake_case

class InputCoordinates(BaseModel):
    lat: float
    lon: float
    address: str | None = None

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

class Geometry(BaseModel):
    length: int
    points: str

class RealtimeState(Enum):
    scheduled = "SCHEDULED"
    updated = "UPDATED"
    cancelled = "CANCELLED"
    added = "ADDED"
    modified = "MODIFIED"

class VertexType(Enum):
    normal = "NORMAL"
    transit = "TRANSIT"
    bike_park = "BIKEPARK"
    bike_share = "BIKESHARE"
    park_and_ride = "PARKANDRIDE"

class Stop(BaseModel):
    id: str
    name: str
    lat: float
    lon: float

class Place(BaseModel):
    name: str | None = None
    vertex_type: VertexType | None = None
    lat: float
    lon: float
    arrival_time: datetime | None = None
    departure_time: datetime | None = None
    stop: Stop | None = None
    
    @field_validator("arrival_time", "departure_time", mode="before")
    @classmethod
    def validate_times(cls, value: int | None):
        # Convert UNIX timestamp in milliseconds to datetime
        if isinstance(value, int):
            return datetime.fromtimestamp(value / 1000)
        elif value is None:
            return None
        else:
            raise ValueError("Time must be a timestamp in milliseconds since epoch.")

class Route(BaseModel):
    id: str
    short_name: str | None = None
    mode: Mode

class Trip(BaseModel):
    id: str
    route: Route
    trip_short_name: str | None = None
    trip_headsign: str | None = None

class Step(BaseModel):
    pass

class PickupDropoffType(Enum):
    scheduled = "SCHEDULED"
    none = "NONE"
    call_agency = "CALL_AGENCY"
    coordinate_with_driver = "COORDINATE_WITH_DRIVER"

class Leg(BaseModel):
    start_time: datetime
    end_time: datetime
    departure_delay: int
    arrival_delay: int
    mode: Mode
    duration: float
    leg_geometry: Geometry
    real_time: bool
    realtime_state: RealtimeState | None
    distance: float
    transit_leg: bool
    from_: Place
    to: Place
    route: Route | None = None
    trip: Trip | None = None
    intermediate_stops: list[Stop] | None = None
    # steps: list["Step"]
    headsign: str | None = None
    pickup_type: PickupDropoffType | None = None
    dropoff_type: PickupDropoffType | None = None
    accessibility_score: float | None
    
    @model_validator(mode="before")
    @classmethod
    def remap_model_fields(cls, values: dict[str, any]):
        for key in list(values.keys()):
            if key == "from":
                values["from_"] = values.pop("from")
            else:
                values[to_snake_case(key)] = values.pop(key)
        return values
    
    @field_validator("start_time", "end_time", mode="before")
    @classmethod
    def validate_timestamp(cls, value: int | datetime):
        if isinstance(value, datetime):
            return value
        if isinstance(value, int):
            return datetime.fromtimestamp(value / 1000)
        raise ValueError("Invalid value for start_time or end_time field.")

class Itinerary(BaseModel):
    start_time: datetime
    end_time: datetime
    duration: int
    legs: list[Leg]
    accessibility_score: float | None
    
    @model_validator(mode="before")
    @classmethod
    def remap_model_fields(cls, values):
        for key in list(values.keys()):
            values[to_snake_case(key)] = values.pop(key)
        return values
    
    @field_validator("start_time", "end_time", mode="before")
    @classmethod
    def validate_timestamp(cls, value: int | datetime):
        if isinstance(value, datetime):
            return value
        if isinstance(value, int):
            return datetime.fromtimestamp(value / 1000)
        raise ValueError("Invalid value for start_time or end_time field.")
    
class TransportMode(BaseModel):
    mode: Mode

class PlanRequestModel(BaseModel):
    date: str
    time: str
    from_: InputCoordinates
    to: InputCoordinates
    wheelchair: bool = False
    num_itineraries: int = 3
    arrive_by: bool = False
    transport_modes: list[TransportMode]

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
    date: datetime
    from_: Place
    to: Place
    itineraries: list[Itinerary]
    
    @field_validator("date", mode="before")
    @classmethod
    def validate_date(cls, value: int):
        # Convert UNIX timestamp in milliseconds to datetime
        if isinstance(value, int):
            return datetime.fromtimestamp(value / 1000)
        else:
            raise ValueError("Date must be a timestamp in milliseconds since epoch.")

    @model_validator(mode="before")
    @classmethod
    def remap_model_fields(cls, values: dict[str, any]):
        for key in list(values.keys()):
            if key == "from":
                values["from_"] = values.pop("from")
            else:
                values[to_snake_case(key)] = values.pop(key)
        return values
