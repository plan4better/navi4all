import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:navi4all/core/theme/profile_mode.dart';
import 'package:navi4all/schemas/routing/place.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:navi4all/core/theme/base_map_style.dart';

String keyOnboardingComplete = "kl_onboarding_complete";
String keyFavorites = "kl_favorites";
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

    preferences.setStringList(keyFavorites, favorites);
  }

  static Future<void> removeFavorite(String id) async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    List<String> favorites = _getStoredFavorites(preferences);

    favorites.removeWhere((item) {
      Place place = Place.fromJson(jsonDecode(item));
      return place.id == id;
    });

    preferences.setStringList(keyFavorites, favorites);
  }

  static Future<bool> isFavorite(String id) async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    List<String> favorites = _getStoredFavorites(preferences);

    for (var item in favorites) {
      Place place = Place.fromJson(jsonDecode(item));
      if (place.id == id) {
        return true;
      }
    }
    return false;
  }

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
