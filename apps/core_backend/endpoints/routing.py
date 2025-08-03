import httpx
from fastapi import APIRouter
from schemas.plan import PlanRequestModel, PlanResponseModel
from pathlib import Path
from core.config import settings
from core.utils import to_camel_case

router = APIRouter(prefix="/routing")


@router.post("/plan", response_model=PlanResponseModel)
async def plan(request: PlanRequestModel):
    # Load GraphQL query template from file
    path = Path("/app/apps/core_backend/schemas/plan.graphql")
    query_template = path.read_text()

    # Reformat request payload
    request_dict = request.model_dump()
    request_dict = {to_camel_case(k): v for k, v in request_dict.items()}

    # Make the request to the routing engine
    client = httpx.AsyncClient()
    try:
        response = await client.post(
            settings.ROUTING_ENGINE_URL,
            json={"query": query_template, "variables": request_dict},
        )
    except httpx.HTTPError as e:
        raise e
    finally:
        await client.aclose()

    return PlanResponseModel.model_validate(response.json()["data"]["plan"])


@router.get("/itinerary/{itinerary_id}", response_model=PlanResponseModel)
async def itinerary(itinerary_id: str):
    pass
