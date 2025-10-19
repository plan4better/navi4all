import 'package:dio/dio.dart';
import 'package:navi4all/services/api.dart';

class GeocodingService extends APIService {
  Future<Response> autocomplete({
    required String timestamp,
    required String query,
    double? focusPointLat,
    double? focusPointLon,
    int limit = 5,
  }) async => apiClient.get(
    '/geocoding/autocomplete',
    queryParameters: {
      'timestamp': timestamp,
      'query': query,
      if (focusPointLat != null) 'focus_point_lat': focusPointLat,
      if (focusPointLon != null) 'focus_point_lon': focusPointLon,
      'limit': limit,
    },
  );
}
