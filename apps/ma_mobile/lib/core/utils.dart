import 'package:flutter/material.dart';
import 'package:smartroots/l10n/app_localizations.dart';
import 'package:smartroots/schemas/routing/itinerary.dart';

String getOccupancyText(
  BuildContext context,
  Map<String, dynamic> parkingSite,
) {
  if (parkingSite["has_realtime_data"]) {
    return '${parkingSite["occupied_disabled"] ?? AppLocalizations.of(context)!.availabilityUnknown}/${parkingSite["capacity_disabled"] ?? AppLocalizations.of(context)!.availabilityUnknown}';
  } else {
    return '${AppLocalizations.of(context)!.availabilityUnknown}/${parkingSite["capacity_disabled"] ?? AppLocalizations.of(context)!.availabilityUnknown}';
  }
}

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
