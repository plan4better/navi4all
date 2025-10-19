import httpx
from fastapi import APIRouter
from schemas.routing import RoutingPlanRequestModel, RoutingPlanResponseModel, ItineraryResponseModel
from services.adaptors.open_trip_planner import OpenTripPlannerAdaptor

router = APIRouter(prefix="/routing")
adaptor = OpenTripPlannerAdaptor()


@router.post("/plan", response_model=RoutingPlanResponseModel)
async def plan(request: RoutingPlanRequestModel):
    async with httpx.AsyncClient() as client:
        response = await adaptor.make_plan_request(client, request)
    return response


@router.get("/itinerary/{itinerary_id}", response_model=ItineraryResponseModel)
async def get_itinerary(itinerary_id: str):
    response = await adaptor.get_itinerary(itinerary_id)
    return response
