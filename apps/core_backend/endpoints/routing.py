import httpx
from fastapi import APIRouter
from schemas.plan import PlanRequestModel, PlanResponseModel
from services.adaptors.open_trip_planner import OpenTripPlannerAdaptor

router = APIRouter(prefix="/routing")
adaptor = OpenTripPlannerAdaptor()


@router.post("/plan", response_model=PlanResponseModel)
async def plan(request: PlanRequestModel):
    async with httpx.AsyncClient() as client:
        response = await adaptor.make_plan_request(client, request)
    return response
