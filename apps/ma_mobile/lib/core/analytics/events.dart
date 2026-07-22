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
  routingScreenAvailabilityChangeOccurred,
  routingScreenAvailabilityChangeAlternativeSearchConfirmed,
  routingScreenAvailabilityChangeAlternativeSearchCancelled,
}

Map<EventAction, String> eventActionLabels = {
  EventAction.homeMapScreenParkingLocationMarkerClicked:
      'Startbildschirm Karte - Parkplatzmarkierung angeklickt',
  EventAction.homeMapScreenSearchClicked:
      'Startbildschirm Karte - Suche angeklickt',
  EventAction.homeMapScreenBaseMapChanged:
      'Startbildschirm Karte - Basiskarte geändert',
  EventAction.placeScreenSearchRadiusChanged:
      'Ortsbildschirm - Suchradius geändert',
  EventAction.parkingLocationScreenFavouriteAdded:
      'Parkplatzbildschirm - Favorit hinzugefügt',
  EventAction.parkingLocationScreenRouteInternalClicked:
      'Parkplatzbildschirm - Interne Route angeklickt',
  EventAction.parkingLocationScreenRouteExternalClicked:
      'Parkplatzbildschirm - Externe Route angeklickt',
  EventAction.routingScreenAvailabilityChangeOccurred:
      'Routenbildschirm - Verfügbarkeitsänderung erfolgt',
  EventAction.routingScreenAvailabilityChangeAlternativeSearchConfirmed:
      'Routenbildschirm - Alternative Suche bestätigt',
  EventAction.routingScreenAvailabilityChangeAlternativeSearchCancelled:
      'Routenbildschirm - Alternative Suche abgebrochen',
};
