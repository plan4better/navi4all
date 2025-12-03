import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smartroots/core/config.dart';
import 'package:smartroots/core/theme/base_map_style.dart';
import 'package:smartroots/schemas/routing/place.dart';

String keyOnboardingComplete = "ma_onboarding_complete";
String keyFavorites = "ma_favorites";
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

  static List<String> _getStoredFavorites(SharedPreferences preferences) =>
      preferences.getStringList(keyFavorites) ?? [];

  static Future<List<Place>> getFavorites() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    List<Place> favorites = [];

    for (var item in _getStoredFavorites(preferences)) {
      favorites.add(Place.fromJson(jsonDecode(item)));
    }
    return favorites;
  }

  static Future<void> addFavorite(Place place) async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    List<String> favorites = _getStoredFavorites(preferences);

    favorites.add(jsonEncode(place.toJson()));

    await preferences.setStringList(keyFavorites, favorites);
  }

  static Future<void> removeFavorite(Place place) async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    List<String> favorites = _getStoredFavorites(preferences);

    favorites.removeWhere((item) {
      Place storedPlace = Place.fromJson(jsonDecode(item));
      return storedPlace.id == place.id && storedPlace.type == place.type;
    });

    await preferences.setStringList(keyFavorites, favorites);
  }

  static Future<bool> isFavorite(Place place) async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    List<String> favorites = _getStoredFavorites(preferences);

    for (var item in favorites) {
      Place storedPlace = Place.fromJson(jsonDecode(item));
      if (storedPlace.id == place.id && storedPlace.type == place.type) {
        return true;
      }
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
