import 'package:navi4all/schemas/routing/itinerary.dart';

String getItineraryDistanceText(ItinerarySummary itinerary) {
  final distanceInMeters = itinerary.legs.fold(
    0,
    (sum, leg) => sum + leg.distance,
  );
  if (distanceInMeters < 1000) {
    return '${distanceInMeters.round()} m';
  }
  final distanceInKm = distanceInMeters / 1000;
  return '${distanceInKm.toStringAsFixed(1)} km';
}
