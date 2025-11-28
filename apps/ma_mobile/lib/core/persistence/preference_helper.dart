import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smartroots/core/config.dart';
import 'package:smartroots/core/theme/base_map_style.dart';
import 'package:smartroots/schemas/poi/parking_type.dart';
import 'package:smartroots/schemas/routing/place.dart';

String keyOnboardingComplete = "ma_onboarding_complete";
String keyFavoriteParkingSpots = "ma_favorite_parking_spots";
String keyFavoriteParkingSites = "ma_favorite_parking_sites";
String keyThemeMode = "ma_theme_mode";
String keyBaseMapStyle = "ma_base_map_style";
String keyRecentSearches = "ma_recent_searches";

class PreferenceHelper {
  static Future<bool> isOnboardingComplete() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    return preferences.getBool(keyOnboardingComplete) ?? false;
  }

  static Future<void> setOnboardingComplete(bool complete) async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    preferences.setBool(keyOnboardingComplete, complete);
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

  static Future<void> addRecentSearch(Place place) async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    List<String> recentSearches =
        preferences.getStringList(keyRecentSearches) ?? [];

    // Remove existing entry if it exists
    recentSearches.removeWhere((item) {
      Place existingPlace = Place.fromJson(jsonDecode(item));
      return existingPlace.id == place.id;
    });

    // Add to the beginning of the list
    recentSearches.insert(0, jsonEncode(place.toJson()));

    // Retain a limited number of recent searches
    if (recentSearches.length > Settings.numRecentSearchesRetained) {
      recentSearches = recentSearches.sublist(
        0,
        Settings.numRecentSearchesRetained,
      );
    }

    await preferences.setStringList(keyRecentSearches, recentSearches);
  }

  static Future<List<Place>> getRecentSearches() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    List<String> recentSearches =
        preferences.getStringList(keyRecentSearches) ?? [];

    return recentSearches
        .map((item) => Place.fromJson(jsonDecode(item)))
        .toList();
  }
}
