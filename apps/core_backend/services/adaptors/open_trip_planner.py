from core.config import settings
from pathlib import Path
from httpx import AsyncClient
import os
from core.utils import to_camel_case
from redis import Redis
from schemas.routing import (
    RoutingPlanRequestModel,
    RoutingPlanResponseModel,
    ItinerarySummary,
    LegSummary,
    LegDetailed,
    Step,
    Coordinates,
    ItineraryResponseModel,
    ItineraryDetailed,
)
from services.schemas.open_trip_planner import (
    OTPInputCoordinates,
    OTPPlanRequestModel,
    OTPPlanResponseModel,
    OTPTransportMode,
)
from uuid import uuid4
from datetime import datetime, timedelta
import json


class OpenTripPlannerAdaptor:
    def __init__(self):
        """Initalize adaptor settings and setup persistent itinerary cache."""

        # Ensure a valid URL is configured
        self.routing_engine_url = settings.OPEN_TRIP_PLANNER_URL
        if not self.routing_engine_url:
            raise ValueError(
                "A valid OpenTripPlanner URL must be configured to use this adaptor."
            )

        # Setup Redis client to cache itineraries
        self.redis_client = Redis(host=settings.REDIS_HOST, port=settings.REDIS_PORT)

    def _load_graphql_template(self, template_name: str):
        """Load a GraphQL query template to perform a request."""

        path = Path(os.path.join(settings.TEMPLATES_DIR, template_name))
        if not path.exists():
            raise FileNotFoundError(f"GraphQL query template not found at {path}")
        return path.read_text()

    async def make_plan_request(
        self, async_client: AsyncClient, request: RoutingPlanRequestModel
    ) -> RoutingPlanResponseModel:
        """Make a plan request to the OpenTripPlanner routing engine."""

        # Load GraphQL query template from file
        request_template = self._load_graphql_template(
            settings.OPEN_TRIP_PLANNER_PLAN_TEMPLATE
        )

        # Reformat request payload
        # Temporarily add 2 hrs to the request to work with UTC
        request_dict = OTPPlanRequestModel(
            date=request.date,
            time=(datetime.strptime(request.time, "%H:%M:%S") + timedelta(hours=2)).strftime("%H:%M:%S"),
            from_=OTPInputCoordinates(lat=request.origin.lat, lon=request.origin.lon),
            to=OTPInputCoordinates(
                lat=request.destination.lat, lon=request.destination.lon
            ),
            wheelchair=request.accessible,
            num_itineraries=request.num_itineraries,
            arrive_by=request.time_is_arrival,
            transport_modes=[
                OTPTransportMode(mode=mode) for mode in request.transport_modes
            ],
        ).model_dump()
        request_dict = {to_camel_case(k): v for k, v in request_dict.items()}

        # Make the request to the routing engine
        router_response = await async_client.post(
            settings.OPEN_TRIP_PLANNER_URL,
            json={"query": request_template, "variables": request_dict},
        )

        # Process routing engine response
        router_response = OTPPlanResponseModel.model_validate(
            router_response.json()["data"]["plan"]
        )

        # Build response
        response = RoutingPlanResponseModel(itineraries=[])

        # Write itineraries to cache
        for itinerary in router_response.itineraries:
            # Produce a unique ID for this itinerary and the journey it represents
            itinerary_id = str(uuid4())

            # Produce ItineraryDetailed model for full itinerary response
            itinerary_detailed = ItineraryDetailed(
                itinerary_id=itinerary_id,
                duration=itinerary.duration,
                start_time=itinerary.start_time,
                end_time=itinerary.end_time,
                origin=Coordinates(
                    lat=router_response.from_.lat, lon=router_response.from_.lon
                ),
                destination=Coordinates(
                    lat=router_response.to.lat, lon=router_response.to.lon
                ),
                legs=[
                    LegDetailed(
                        mode=leg.mode,
                        duration=int(leg.duration),
                        distance=round(leg.distance),
                        geometry=leg.leg_geometry.points,
                        steps=[
                            Step(
                                distance=step.distance,
                                lon=step.lon,
                                lat=step.lat,
                                relative_direction=step.relative_direction.value,
                                absolute_direction=step.absolute_direction.value,
                                street_name=step.street_name,
                                bogus_name=step.bogus_name,
                            )
                            for step in leg.steps
                        ],
                    )
                    for leg in itinerary.legs
                ],
            )

            # Write the full journey to cache
            serialized_mapping = {
                k: json.dumps(v) if isinstance(v, (list, dict)) else v
                for k, v in itinerary_detailed.model_dump(
                    mode="json", exclude_none=True
                ).items()
            }
            self.redis_client.hset(name=itinerary_id, mapping=serialized_mapping)

            # Consider the itinerary to be invalid past its start time
            current_time = datetime.now()
            if current_time < itinerary.end_time:
                self.redis_client.expire(
                    itinerary_id, (itinerary.end_time - current_time).seconds
                )
            else:
                # TODO: Throw an exception & return an appropriate error response
                print("Invalid itinerary start time.")

            # Write an itinerary summary to the response
            response.itineraries.append(
                ItinerarySummary(
                    itinerary_id=itinerary_detailed.itinerary_id,
                    duration=itinerary_detailed.duration,
                    start_time=itinerary_detailed.start_time,
                    end_time=itinerary_detailed.end_time,
                    origin=itinerary_detailed.origin,
                    destination=itinerary_detailed.destination,
                    legs=[
                        LegSummary(
                            mode=leg.mode,
                            duration=int(leg.duration),
                            distance=leg.distance,
                            geometry=leg.geometry,
                        )
                        for leg in itinerary_detailed.legs
                    ],
                )
            )

        return response

    async def get_itinerary(self, itinerary_id: str) -> ItineraryResponseModel:
        """Retrieve a full itinerary from the cache by its journey ID."""

        # Fetch itinerary from cache
        data = self.redis_client.hgetall(itinerary_id)

        # Decode
        decoded_data = {k.decode(): v.decode() for k, v in data.items()}

        # Deserialize
        deserialized_data = {
            k: json.loads(v) if v.startswith("[") or v.startswith("{") else v
            for k, v in decoded_data.items()
        }

        # Validate and return the full itinerary
        return ItineraryResponseModel.model_validate(deserialized_data)
