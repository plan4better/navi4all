from schemas.geocoding import (
    SupportedGeocodingProviders,
    GeocodingAutocompleteRequestModel,
    GeocodingAutocompleteResponseModel,
)
from httpx import AsyncClient, Response
from urllib.parse import urljoin
from fastapi import HTTPException
from schemas.place import Place
from schemas.coordinates import Coordinates


class GeocodingAdaptor:
    def __init__(
        self, provider: SupportedGeocodingProviders, api_url: str, api_key: str
    ):
        self.provider = provider
        self.api_url = api_url
        self.api_key = api_key

    def _build_request_pelias_autocomplete(
        self, request: GeocodingAutocompleteRequestModel
    ) -> tuple[str, dict]:
        """Build the request URL and params for a Pelias autocomplete request."""

        request_url = urljoin(self.api_url, "v1/autocomplete")
        request_params = {
            "api_key": self.api_key,
            "text": request.query,
            # TODO: Make layer exclution dynamic
            "layers": "-continent,-empire,-country,-dependency,-disputed,-region,-county,-localadmin,-locality,-borough,-neighbourhood",
        }
        if request.focus_point:
            request_params["focus.point.lat"] = request.focus_point.lat
            request_params["focus.point.lon"] = request.focus_point.lon
        return request_url, request_params

    def _build_request_google_autocomplete(
        self, request: GeocodingAutocompleteRequestModel
    ) -> tuple[str, dict]:
        """Build the request URL and params for a Google autocomplete request."""

        # TODO: Implement
        pass

    def _process_response_pelias(self, response: Response) -> list[Place]:
        """Process the response from a Pelias request."""

        places = []
        for feature in response.json()["features"]:
            places.append(
                Place(
                    id=feature["properties"]["id"],
                    name=feature["properties"]["name"],
                    address=feature["properties"]["label"],
                    type=feature["properties"]["layer"],
                    street=feature["properties"].get("street", None),
                    locality=feature["properties"].get("locality", None),
                    postcode=feature["properties"].get("postalcode", None),
                    coordinates=Coordinates(
                        lat=feature["geometry"]["coordinates"][1],
                        lon=feature["geometry"]["coordinates"][0],
                    ),
                )
            )

        return places

    def _process_response_google(self, response: Response) -> list[Place]:
        """Process the response from a Google request."""

        # TODO: Implement
        pass

    async def autocomplete(
        self, async_client: AsyncClient, request: GeocodingAutocompleteRequestModel
    ) -> list[Place]:
        """Make an autocomplete geocoding request."""

        # Build request URL and params
        if self.provider == SupportedGeocodingProviders.PELIAS:
            request_url, request_params = self._build_request_pelias_autocomplete(
                request
            )
        elif self.provider == SupportedGeocodingProviders.GOOGLE:
            request_url, request_params = self._build_request_google_autocomplete(
                request
            )
        else:
            raise HTTPException(
                status_code=400, detail="Unsupported geocoding provider."
            )

        # Make request to selected geocoding provider
        response = await async_client.get(
            url=request_url,
            params=request_params,
        )

        if response.status_code != 200:
            raise HTTPException(
                status_code=response.status_code, detail="Geocoding request failed."
            )

        # Process response
        places: list[Place] = []
        if self.provider == SupportedGeocodingProviders.PELIAS:
            places = self._process_response_pelias(response)
        elif self.provider == SupportedGeocodingProviders.GOOGLE:
            places = self._process_response_google(response)

        # Clip length of response if limit is set
        if request.limit and len(places) > request.limit:
            places = places[: request.limit]

        return GeocodingAutocompleteResponseModel(
            timestamp=request.timestamp,
            results=places,
        )
