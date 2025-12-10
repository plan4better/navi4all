import 'package:flutter/material.dart';
import 'package:smartroots/l10n/app_localizations.dart';
import 'package:smartroots/schemas/routing/itinerary.dart';
import 'package:smartroots/schemas/routing/place.dart';

class TextFormatter {
  static String getOccupancyText(BuildContext context, Place place) {
    // Ensure place is a parking location
    if (place.type != PlaceType.parkingSpot &&
        place.type != PlaceType.parkingSite) {
      throw Exception(
        'Place must be a parking location to get occupancy text.',
      );
    }

    if (!place.attributes!["has_realtime_data"]) {
      return AppLocalizations.of(context)!.availabilityUnknown;
    }
    if (place.attributes!["disabled_parking_available"]) {
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

  static String formatDistanceValueText(double distance) {
    // Format distance based on its length, replace point with comma for locales that use comma
    if (distance >= 1000) {
      final distanceInKm = formatKilometersDistanceFromMeters(distance);
      return '${distanceInKm.toString().replaceAll('.', ',')} km';
    }
    return '${formatMetersDistanceFromMeters(distance)} m';
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

  static String extractCityFromAddress(String fullAddress) {
    // Currently designed for the German address format
    List<String> addressParts = fullAddress.split(',');
    if (addressParts.length >= 2) {
      String cityPart = addressParts[1].trim();
      List<String> cityParts = cityPart.split(' ');
      if (cityParts.length >= 2) {
        return cityParts.sublist(1).join(' ');
      }
    }
    return '';
  }
}
