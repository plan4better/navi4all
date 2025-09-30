import 'package:dio/dio.dart';
import 'package:smartroots/core/config.dart' show Settings;

class POIParkingService {
  final Dio apiClient = Dio(
    BaseOptions(
      baseUrl: Settings.parkApiBaseUrl,
      connectTimeout: Duration(seconds: Settings.apiConnectTimeout),
      receiveTimeout: Duration(seconds: Settings.apiReceiveTimeout),
    ),
  );

  Future<Response> parkingSites({
    required double focusPointLat,
    required double focusPointLon,
    required int radius,
  }) async => apiClient.get(
    '/parking-sites',
    queryParameters: {
      'lat': focusPointLat,
      'lon': focusPointLon,
      'radius': radius,
      'purpose': 'CAR',
    },
  );
}
