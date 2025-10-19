import 'package:dio/dio.dart';
import 'package:smartroots/core/config.dart' show Settings;
import 'package:maplibre_gl/maplibre_gl.dart' show LatLng;

class POIParkingService {
  final Dio apiClient = Dio(
    BaseOptions(
      baseUrl: Settings.parkApiBaseUrl,
      connectTimeout: Duration(seconds: Settings.apiConnectTimeout),
      receiveTimeout: Duration(seconds: Settings.apiReceiveTimeout),
      validateStatus: (status) => true,
    ),
  );

  Future<List<Map<String, dynamic>>> getParkingLocations({
    required double focusPointLat,
    required double focusPointLon,
    required int radius,
  }) async {
    List<Map<String, dynamic>> parkingLocations = [];

    // Fetch parking spots
    Response parkingSpotsResponse = await apiClient.get(
      '/parking-spots',
      queryParameters: {
        'lat': focusPointLat,
        'lon': focusPointLon,
        'radius': radius,
        'purpose': 'CAR',
      },
    );

    // Fetch parking sites
    Response parkingSitesResponse = await apiClient.get(
      '/parking-sites',
      queryParameters: {
        'lat': focusPointLat,
        'lon': focusPointLon,
        'radius': radius,
        'purpose': 'CAR',
      },
    );

    // Process parking spots
    if (parkingSpotsResponse.statusCode == 200) {
      parkingLocations.addAll(
        (parkingSpotsResponse.data['items'] as List)
            .map((item) => _parseParkingSpotLocation(item))
            .where((site) => (site["capacity_disabled"] ?? 0) > 0)
            .toList(),
      );
    } else {
      throw Exception(parkingSpotsResponse.statusMessage);
    }

    // TODO: ONLY FOR TESTING
    parkingLocations.add({
      "id": "test1",
      "name": "München Test Parking 1",
      "address": "Schellingstraße 84, 80798 München",
      "coordinates": LatLng(48.152458623658056, 11.568498141412222),
      "has_realtime_data": true,
      "capacity_disabled": 1,
      "free_capacity_disabled": 1,
      "occupied_disabled": 0,
    });

    // Process parking sites
    if (parkingSitesResponse.statusCode == 200) {
      parkingLocations.addAll(
        (parkingSitesResponse.data['items'] as List)
            .map((item) => _parseParkingSiteLocation(item))
            .where((site) => (site["capacity_disabled"] ?? 0) > 0)
            .toList(),
      );
    } else {
      throw Exception(parkingSitesResponse.statusMessage);
    }

    // Order parking locations by distance to focus point
    parkingLocations.sort((a, b) {
      double distanceA =
          ((a['coordinates'].latitude - focusPointLat) *
              (a['coordinates'].latitude - focusPointLat)) +
          ((a['coordinates'].longitude - focusPointLon) *
              (a['coordinates'].longitude - focusPointLon));
      double distanceB =
          ((b['coordinates'].latitude - focusPointLat) *
              (b['coordinates'].latitude - focusPointLat)) +
          ((b['coordinates'].longitude - focusPointLon) *
              (b['coordinates'].longitude - focusPointLon));
      return distanceA.compareTo(distanceB);
    });

    return parkingLocations;
  }

  Future<Map<String, dynamic>?> getParkingLocationDetails({
    required String parkingId,
  }) async {
    // Attempt to fetch details from parking-spots endpoint first
    Response parkingSpotsResponse = await apiClient.get(
      '/parking-spots/$parkingId',
    );

    if (parkingSpotsResponse.statusCode == 200) {
      var item = parkingSpotsResponse.data;
      return _parseParkingSpotLocation(item);
    } else if (parkingSpotsResponse.statusCode != 404) {
      throw Exception(parkingSpotsResponse.statusMessage);
    }

    // Attempt to fetch details from parking-sites endpoint if not found in parking-spots
    Response parkingSitesResponse = await apiClient.get(
      '/parking-sites/$parkingId',
    );
    if (parkingSitesResponse.statusCode == 200) {
      var item = parkingSitesResponse.data;
      return _parseParkingSiteLocation(item);
    } else if (parkingSitesResponse.statusCode == 404) {
      return null;
    } else {
      throw Exception(parkingSitesResponse.statusMessage);
    }
  }

  Map<String, dynamic> _parseParkingSpotLocation(Map<String, dynamic> item) {
    Map<String, dynamic> parkingSpot = {
      "id": item['id'].toString(),
      "name": item['name'],
      "address": item['address'],
      "coordinates": LatLng(
        double.parse(item['lat']),
        double.parse(item['lon']),
      ),
      "has_realtime_data": item['has_realtime_data'],
      "capacity_disabled":
          (item['restricted_to'] as List).any(
            (restriction) => restriction['type'] == 'DISABLED',
          )
          ? 1
          : 0,
      "free_capacity_disabled": item['has_realtime_data']
          ? item['realtime_status'] == 'AVAILABLE'
                ? 1
                : item['realtime_status'] == 'TAKEN'
                ? 0
                : null
          : null,
    };

    // Compute occupied space count
    parkingSpot["occupied_disabled"] =
        (parkingSpot['capacity_disabled'] ?? 0) -
        (parkingSpot['free_capacity_disabled'] ?? 0);

    return parkingSpot;
  }

  Map<String, dynamic> _parseParkingSiteLocation(Map<String, dynamic> item) {
    Map<String, dynamic> parkingSite = {
      "id": item['id'].toString(),
      "name": item['name'],
      "address": item['address'],
      "coordinates": LatLng(
        double.parse(item['lat']),
        double.parse(item['lon']),
      ),
      "has_realtime_data": item['has_realtime_data'],
      "capacity_disabled": item['has_realtime_data']
          ? item['realtime_capacity_disabled']
          : item['capacity_disabled'],
      "free_capacity_disabled": item['has_realtime_data']
          ? item['realtime_free_capacity_disabled']
          : null,
    };

    // Compute occupied space count
    parkingSite["occupied_disabled"] =
        (parkingSite['capacity_disabled'] ?? 0) -
        (parkingSite['free_capacity_disabled'] ?? 0);

    return parkingSite;
  }
}
