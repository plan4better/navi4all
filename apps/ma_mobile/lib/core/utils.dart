import 'package:flutter/material.dart';
import 'package:smartroots/l10n/app_localizations.dart';
import 'package:smartroots/schemas/routing/itinerary.dart';

class TextFormatter {
  static String getOccupancyText(
    BuildContext context,
    Map<String, dynamic> parkingSite,
  ) {
    if (!parkingSite["has_realtime_data"]) {
      return AppLocalizations.of(context)!.availabilityUnknown;
    }
    if (parkingSite["disabled_parking_available"]) {
      return AppLocalizations.of(context)!.availabilityAvailable;
    } else {
      return AppLocalizations.of(context)!.availabilityOccupied;
    }
  }

  static String formatDistanceText(ItinerarySummary itinerary) {
    final double distanceInMeters = itinerary.legs.fold(
      0,
      (sum, leg) => sum + leg.distance,
    );

    // Format distance based on its length, replace point with comma for locales that use comma
    if (distanceInMeters >= 1000) {
      final distanceInKm = formatKilometersDistanceFromMeters(distanceInMeters);
      return '${distanceInKm.toString().replaceAll('.', ',')} km';
    }
    return '${formatMetersDistanceFromMeters(distanceInMeters)} m';
  }

  static int formatMetersDistanceFromMeters(double distance) {
    // Above 100m, round to the nearest 50m, below round to the nearest 10m
    if (distance > 100) {
      final roundedDistance = (distance / 50).round() * 50;
      return roundedDistance.round();
    } else {
      final roundedDistance = (distance / 10).round() * 10;
      return roundedDistance.round();
    }
  }

  static double formatKilometersDistanceFromMeters(double distance) {
    // Convert to km with one decimal place
    final distanceInKm = distance / 1000;
    return (distanceInKm * 10).round() / 10;
  }

  static String formatDurationText(int duration) {
    final durationInMinutes = (duration / 60).round();
    if (durationInMinutes < 60) {
      return '$durationInMinutes min';
    }
    final hours = durationInMinutes ~/ 60;
    final minutes = durationInMinutes % 60;
    return '${hours}h ${minutes}m';
  }

  static String formatSpeedText(double speed) {
    if (speed % 1 == 0) {
      return '${speed.toInt()} km/h';
    } else {
      return '${speed.toStringAsFixed(1)} km/h';
    }
  }
}
