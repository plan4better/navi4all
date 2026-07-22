import 'package:smartroots/schemas/routing/audio_stage.dart';
import 'package:smartroots/schemas/routing/coordinates.dart';

import 'theme/base_map_style.dart';

class Settings {
  static String _requiredString(String key, String value) {
    if (value.isEmpty) {
      throw StateError('Missing required environment value: $key');
    }
    return value;
  }

  static int _requiredInt(String key, int value) {
    if (value == 0) {
      throw StateError('Missing required environment value: $key');
    }
    return value;
  }

  static double _requiredDouble(String key, String value) {
    final parsed = double.tryParse(value);
    if (parsed == null) {
      throw StateError('Invalid double environment value for $key: $value');
    }
    return parsed;
  }

  static List<String> _requiredStringList(String key, String value) {
    _requiredString(key, value);
    final parsed = value
        .split(',')
        .map((entry) => entry.trim())
        .where((entry) => entry.isNotEmpty)
        .toList();
    if (parsed.isEmpty) {
      throw StateError('Invalid list environment value for $key: $value');
    }
    return parsed;
  }

  // Matomo analytics settings
  static const String matomoUrl = String.fromEnvironment('MATOMO_URL');
  static const String matomoSiteId = String.fromEnvironment('MATOMO_SITE_ID');

  // API service settings
  static final String apiBaseUrl = _requiredString(
    'API_BASE_URL',
    const String.fromEnvironment('API_BASE_URL'),
  );
  static const String apiAuthorizationUsername = String.fromEnvironment(
    'API_AUTH_USERNAME',
  );
  static const String apiAuthorizationPassword = String.fromEnvironment(
    'API_AUTH_PASSWORD',
  );
  static final int apiConnectTimeout = _requiredInt(
    'API_CONNECT_TIMEOUT',
    const int.fromEnvironment('API_CONNECT_TIMEOUT'),
  );
  static final int apiReceiveTimeout = _requiredInt(
    'API_RECEIVE_TIMEOUT',
    const int.fromEnvironment('API_RECEIVE_TIMEOUT'),
  );
  static final String apiRoutingEngine = _requiredString(
    'API_ROUTING_ENGINE',
    const String.fromEnvironment('API_ROUTING_ENGINE'),
  );
  static final int dataRefreshIntervalSeconds = _requiredInt(
    'DATA_REFRESH_INTERVAL_SECONDS',
    const int.fromEnvironment('DATA_REFRESH_INTERVAL_SECONDS'),
  );

  // Fallback coordinates if user location is unavailable
  static final Coordinates defaultFocalPoint = Coordinates(
    lat: _requiredDouble(
      'DEFAULT_FOCAL_LAT',
      const String.fromEnvironment('DEFAULT_FOCAL_LAT'),
    ),
    lon: _requiredDouble(
      'DEFAULT_FOCAL_LON',
      const String.fromEnvironment('DEFAULT_FOCAL_LON'),
    ),
  );

  // Base map settings
  static final Map<BaseMapStyle, String> baseMapStyleUrls = {
    BaseMapStyle.light: _requiredString(
      'BASE_MAP_STYLE_URL_LIGHT',
      const String.fromEnvironment('BASE_MAP_STYLE_URL_LIGHT'),
    ),
    BaseMapStyle.dark: _requiredString(
      'BASE_MAP_STYLE_URL_DARK',
      const String.fromEnvironment('BASE_MAP_STYLE_URL_DARK'),
    ),
    BaseMapStyle.satellite: _requiredString(
      'BASE_MAP_STYLE_URL_SATELLITE',
      const String.fromEnvironment('BASE_MAP_STYLE_URL_SATELLITE'),
    ),
  };

  // Support and feedback
  static final String supportEmail = _requiredString(
    'SUPPORT_EMAIL',
    const String.fromEnvironment('SUPPORT_EMAIL'),
  );
  static final String supportEmailSubject = _requiredString(
    'SUPPORT_EMAIL_SUBJECT',
    const String.fromEnvironment('SUPPORT_EMAIL_SUBJECT'),
  );

  static final String feedbackEmail = _requiredString(
    'FEEDBACK_EMAIL',
    const String.fromEnvironment('FEEDBACK_EMAIL'),
  );
  static final String feedbackTypeAppFunctionalityCCEmail =
      const String.fromEnvironment('FEEDBACK_TYPE_APP_FUNCTIONALITY_CC_EMAIL');
  static final String feedbackEmailSubject = _requiredString(
    'FEEDBACK_EMAIL_SUBJECT',
    const String.fromEnvironment('FEEDBACK_EMAIL_SUBJECT'),
  );

  // User engagement
  static const int userEngagementMinLaunchCount = 3;

  // Navigation audio thresholds
  static const Map<AudioStage, double> navigationAudioStages = {
    AudioStage.far: 1000,
    AudioStage.medium: 250,
    AudioStage.near: 50,
  };

  // Default search radius in meters
  static const int searchRadiusMin = 100;
  static const int searchRadiusMax = 800;
  static const int searchRadiusDefault = 500;

  // Caching
  static const int numRecentSearchesRetained = 5;

  // Park API settings
  static final String parkApiBaseUrl = _requiredString(
    'PARK_API_BASE_URL',
    const String.fromEnvironment('PARK_API_BASE_URL'),
  );
  static final String parkApiHeaderUserAgent = _requiredString(
    'PARK_API_HEADER_USER_AGENT',
    const String.fromEnvironment('PARK_API_HEADER_USER_AGENT'),
  );
  static final List<String> parkApiSourceUids = _requiredStringList(
    'PARK_API_SOURCE_UIDS',
    const String.fromEnvironment('PARK_API_SOURCE_UIDS'),
  );
  static final String parkApiLatMin = const String.fromEnvironment(
    'PARK_API_LAT_MIN',
  );
  static final String parkApiLonMin = const String.fromEnvironment(
    'PARK_API_LON_MIN',
  );
  static final String parkApiLatMax = const String.fromEnvironment(
    'PARK_API_LAT_MAX',
  );
  static final String parkApiLonMax = const String.fromEnvironment(
    'PARK_API_LON_MAX',
  );

  // Legal and privacy
  static final String legalAndPrivacyUrl = _requiredString(
    'LEGAL_AND_PRIVACY_URL',
    const String.fromEnvironment('LEGAL_AND_PRIVACY_URL'),
  );
}
