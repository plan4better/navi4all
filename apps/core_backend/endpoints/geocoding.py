import httpx
from fastapi import APIRouter
from schemas.place import Place
from schemas.coordinates import Coordinates
from schemas.geocoding import GeocodingAutocompleteRequestModel
from services.adaptors.geocoding import GeocodingAdaptor
from core.config import settings

router = APIRouter(prefix="/geocoding")
adaptor = GeocodingAdaptor(
    provider=settings.GEOCODING_PROVIDER,
    api_url=settings.GEOCODING_PROVIDER_API_URL,
    api_key=settings.GEOCODING_PROVIDER_API_KEY,
)


@router.get("/autocomplete", response_model=list[Place])
async def autocomplete(
    query: str,
    focus_point_lat: float | None = None,
    focus_point_lon: float | None = None,
    limit: int | None = 5,
):
    async with httpx.AsyncClient() as client:
        response = await adaptor.autocomplete(
            client,
            GeocodingAutocompleteRequestModel(
                query=query,
                focus_point=Coordinates(lat=focus_point_lat, lon=focus_point_lon)
                if focus_point_lat is not None and focus_point_lon is not None
                else None,
                limit=limit,
            ),
        )
    return response
