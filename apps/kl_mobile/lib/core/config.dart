class Settings {
  // API service settings
  // TODO: Load this dynamically from an env file or during compile-time
  static const String apiBaseUrl = 'http://localhost:8000/v1/';
  static const int apiConnectTimeout = 30;
  static const int apiReceiveTimeout = 30;
}
