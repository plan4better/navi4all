import 'package:dio/dio.dart';
import 'package:navi4all/schemas/routing/place.dart';
import 'package:navi4all/services/api.dart';

class GeocodingService extends APIService {
  Future<(DateTime, List<Place>)> autocomplete({
    required String timestamp,
    required String query,
    double? focusPointLat,
    double? focusPointLon,
    int limit = 5,
  }) async {
    Response response = await apiClient.get(
      '/geocoding/autocomplete',
      queryParameters: {
        'timestamp': timestamp,
        'query': query,
        if (focusPointLat != null) 'focus_point_lat': focusPointLat,
        if (focusPointLon != null) 'focus_point_lon': focusPointLon,
        'limit': limit,
      },
    );

    if (response.statusCode != 200) {
      throw Exception(response.statusMessage);
    }
    return (
      DateTime.parse(response.data['timestamp']),
      (response.data['results'] as List)
          .map((item) => Place.fromJson(item))
          .toList(),
    );
  }
}
