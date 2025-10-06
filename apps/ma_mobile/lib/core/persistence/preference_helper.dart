import 'package:shared_preferences/shared_preferences.dart';

class PreferenceHelper {
  static Future<int> getLaunchCount() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    return preferences.getInt("launch_count") ?? 0;
  }

  static Future<int> incrementLaunchCount() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    int launchCount = (preferences.getInt("launch_count") ?? 0) + 1;
    preferences.setInt("launch_count", launchCount);
    return launchCount;
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
