enum EventCategory {
  homeMapScreen,
  placeScreen,
  parkingLocationScreen,
  routingScreen,
}

enum EventAction {
  homeMapScreenParkingLocationMarkerClicked,
  homeMapScreenSearchClicked,
  homeMapScreenBaseMapChanged,
  placeScreenSearchRadiusChanged,
  parkingLocationScreenFavouriteAdded,
  parkingLocationScreenRouteInternalClicked,
  parkingLocationScreenRouteExternalClicked,
  routingScreenDisclaimerAccepted,
  routingScreenDisclaimerRejected,
  routingScreenAvailabilityChangeOccurred,
  routingScreenAvailabilityChangeAlternativeSearchConfirmed,
  routingScreenAvailabilityChangeAlternativeSearchCancelled,
}
