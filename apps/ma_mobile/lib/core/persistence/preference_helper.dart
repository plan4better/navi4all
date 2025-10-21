import 'package:shared_preferences/shared_preferences.dart';
import 'package:smartroots/schemas/poi/parking_type.dart';

String keyFavoriteParkingSpots = "ma_favorite_parking_spots";
String keyFavoriteParkingSites = "ma_favorite_parking_sites";

class PreferenceHelper {
  static Future<bool> isOnboardingComplete() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    return preferences.getBool("onboarding_complete") ?? false;
  }

  static Future<void> setOnboardingComplete(bool complete) async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    preferences.setBool("onboarding_complete", complete);
  }

  static List<String> _getStoredFavoriteParkingLocations(
    ParkingType parkingType,
    SharedPreferences preferences,
  ) {
    if (parkingType == ParkingType.parkingSpot) {
      return preferences.getStringList(keyFavoriteParkingSpots) ?? [];
    } else if (parkingType == ParkingType.parkingSite) {
      return preferences.getStringList(keyFavoriteParkingSites) ?? [];
    } else {
      throw Exception('Invalid parking type');
    }
  }

  static Future<List<Map<String, dynamic>>>
  getFavoriteParkingLocations() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    List<Map<String, dynamic>> favoriteParkingLocations = [];

    for (var item in _getStoredFavoriteParkingLocations(
      ParkingType.parkingSpot,
      preferences,
    )) {
      favoriteParkingLocations.add({
        "id": item,
        "parking_type": ParkingType.parkingSpot,
      });
    }
    for (var item in _getStoredFavoriteParkingLocations(
      ParkingType.parkingSite,
      preferences,
    )) {
      favoriteParkingLocations.add({
        "id": item,
        "parking_type": ParkingType.parkingSite,
      });
    }
    return favoriteParkingLocations;
  }

  static Future<void> addFavoriteParkingLocation(
    String id,
    ParkingType parkingType,
  ) async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    List<String> favoriteParkingLocations = _getStoredFavoriteParkingLocations(
      parkingType,
      preferences,
    );

    if (parkingType == ParkingType.parkingSpot) {
      if (!favoriteParkingLocations.contains(id)) {
        favoriteParkingLocations.add(id);
        preferences.setStringList(
          keyFavoriteParkingSpots,
          favoriteParkingLocations,
        );
      }
      return;
    } else if (parkingType == ParkingType.parkingSite) {
      if (!favoriteParkingLocations.contains(id)) {
        favoriteParkingLocations.add(id);
        preferences.setStringList(
          keyFavoriteParkingSites,
          favoriteParkingLocations,
        );
      }
      return;
    } else {
      throw Exception('Invalid parking type');
    }
  }

  static Future<void> removeFavoriteParkingLocation(
    String id,
    ParkingType parkingType,
  ) async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    List<String> favoriteParkingLocations = _getStoredFavoriteParkingLocations(
      parkingType,
      preferences,
    );

    if (parkingType == ParkingType.parkingSpot) {
      if (favoriteParkingLocations.contains(id)) {
        favoriteParkingLocations.remove(id);
        preferences.setStringList(
          keyFavoriteParkingSpots,
          favoriteParkingLocations,
        );
      }
      return;
    } else if (parkingType == ParkingType.parkingSite) {
      if (favoriteParkingLocations.contains(id)) {
        favoriteParkingLocations.remove(id);
        preferences.setStringList(
          keyFavoriteParkingSites,
          favoriteParkingLocations,
        );
      }
      return;
    } else {
      throw Exception('Invalid parking type');
    }
  }

  static Future<bool> isFavoriteParkingLocation(
    String id,
    ParkingType parkingType,
  ) async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    List<String> favoriteParkingLocations = _getStoredFavoriteParkingLocations(
      parkingType,
      preferences,
    );
    if (favoriteParkingLocations.contains(id)) {
      return true;
    }
    return false;
  }
}
