import httpx
from fastapi import APIRouter, Depends
from schemas.place import Place
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
async def autocomplete(request: GeocodingAutocompleteRequestModel = Depends()):
    async with httpx.AsyncClient() as client:
        response = await adaptor.autocomplete(client, request)
    return response
