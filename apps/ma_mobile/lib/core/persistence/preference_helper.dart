import 'package:shared_preferences/shared_preferences.dart';

class PreferenceHelper {
  static Future<bool> isOnboardingComplete() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    return preferences.getBool("onboarding_complete") ?? false;
  }

  static Future<void> setOnboardingComplete(bool complete) async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    preferences.setBool("onboarding_complete", complete);
  }

  static Future<List<String>> getFavoriteParkingSites() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    return preferences.getStringList("favorite_parking_sites") ?? [];
  }

  static Future<void> addFavoriteParkingSite(String id) async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    List<String> favorites =
        preferences.getStringList("favorite_parking_sites") ?? [];
    if (!favorites.contains(id)) {
      favorites.add(id);
      preferences.setStringList("favorite_parking_sites", favorites);
    }
  }

  static Future<void> removeFavoriteParkingSite(String id) async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    List<String> favorites =
        preferences.getStringList("favorite_parking_sites") ?? [];
    if (favorites.contains(id)) {
      favorites.remove(id);
      preferences.setStringList("favorite_parking_sites", favorites);
    }
  }

  static Future<bool> isFavoriteParkingSite(String id) async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    List<String> favorites =
        preferences.getStringList("favorite_parking_sites") ?? [];
    return favorites.contains(id);
  }
}
