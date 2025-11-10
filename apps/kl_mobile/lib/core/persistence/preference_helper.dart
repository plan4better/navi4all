import 'package:flutter/material.dart';
import 'package:navi4all/core/theme/profile_mode.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:navi4all/core/theme/base_map_style.dart';
// import 'package:navi4all/schemas/poi/parking_type.dart';

String keyOnboardingComplete = "kl_onboarding_complete";
// String keyFavoriteParkingSpots = "kl_favorite_parking_spots";
// String keyFavoriteParkingSites = "kl_favorite_parking_sites";
String keyProfileMode = "kl_profile_mode";
String keyThemeMode = "kl_theme_mode";
String keyBaseMapStyle = "kl_base_map_style";

class PreferenceHelper {
  static Future<bool> isOnboardingComplete() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    return preferences.getBool(keyOnboardingComplete) ?? false;
  }

  static Future<void> setOnboardingComplete(bool complete) async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    preferences.setBool(keyOnboardingComplete, complete);
  }

  /* static List<String> _getStoredFavoriteParkingLocations(
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
  } */

  static Future<ProfileMode> getProfileMode() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    return ProfileMode.values.byName(
      preferences.getString(keyProfileMode) ?? ProfileMode.general.name,
    );
  }

  static Future<void> setProfileMode(ProfileMode mode) async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    preferences.setString(keyProfileMode, mode.name);
  }

  static Future<ThemeMode> getThemeMode() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    return ThemeMode.values.byName(
      preferences.getString(keyThemeMode) ?? ThemeMode.light.name,
    );
  }

  static Future<void> setThemeMode(ThemeMode mode) async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    preferences.setString(keyThemeMode, mode.name);
  }

  static Future<BaseMapStyle> getBaseMapStyle() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    return BaseMapStyle.values.byName(
      preferences.getString(keyBaseMapStyle) ?? BaseMapStyle.light.name,
    );
  }

  static Future<void> setBaseMapStyle(BaseMapStyle style) async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    preferences.setString(keyBaseMapStyle, style.name);
  }
}
