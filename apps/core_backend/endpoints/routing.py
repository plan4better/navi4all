import httpx
from fastapi import APIRouter
from schemas.routing import RoutingPlanRequestModel, RoutingPlanResponseModel
from services.adaptors.open_trip_planner import OpenTripPlannerAdaptor

router = APIRouter(prefix="/routing")
adaptor = OpenTripPlannerAdaptor()


@router.post("/plan", response_model=RoutingPlanResponseModel)
async def plan(request: RoutingPlanRequestModel):
    async with httpx.AsyncClient() as client:
        response = await adaptor.make_plan_request(client, request)
    return response
