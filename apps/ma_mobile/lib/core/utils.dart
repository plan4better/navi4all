import 'package:flutter/material.dart';
import 'package:smartroots/l10n/app_localizations.dart';
import 'package:smartroots/schemas/routing/itinerary.dart';

String getOccupancyText(
  BuildContext context,
  Map<String, dynamic> parkingSite,
) {
  int? capacityDisabled = parkingSite["capacity_disabled"];
  int? occupiedDisabled = parkingSite["occupied_disabled"];
  if (parkingSite["has_realtime_data"] == false ||
      capacityDisabled == null ||
      occupiedDisabled == null) {
    return AppLocalizations.of(context)!.availabilityUnknown;
  }

  if (capacityDisabled > 1) {
    return '$occupiedDisabled/$capacityDisabled';
  } else {
    if (occupiedDisabled >= capacityDisabled) {
      return AppLocalizations.of(context)!.availabilityOccupied;
    } else {
      return AppLocalizations.of(context)!.availabilityAvailable;
    }
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
