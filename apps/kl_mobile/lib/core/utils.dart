import 'package:navi4all/schemas/routing/itinerary.dart';

class TextFormatter {
  static String formatDistanceText(ItinerarySummary itinerary) {
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
