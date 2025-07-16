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
}
