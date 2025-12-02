import 'package:dio/dio.dart';
import 'package:smartroots/core/config.dart' show Settings;
import 'package:maplibre_gl/maplibre_gl.dart' show LatLng;
import 'package:maps_toolkit/maps_toolkit.dart' as maps_toolkit;
import 'package:smartroots/schemas/poi/parking_type.dart';

class POIParkingService {
  // TODO: ONLY FOR TESTING
  final List<Map<String, dynamic>> _testParkingLocations = [
    {
      "id": "test1",
      "name": "München Test Parking 1",
      "address": "Schellingstraße 84, 80798 München",
      "lat": "48.152458623658056",
      "lon": "11.568498141412222",
      "has_realtime_data": true,
      "realtime_status": "AVAILABLE",
      "restrictions": [
        {"type": "DISABLED"},
      ],
      "parking_type": ParkingType.parkingSpot,
    },
  ];

  final Dio apiClient = Dio(
    BaseOptions(
      baseUrl: Settings.parkApiBaseUrl,
      connectTimeout: Duration(seconds: Settings.apiConnectTimeout),
      receiveTimeout: Duration(seconds: Settings.apiReceiveTimeout),
      validateStatus: (status) => true,
    ),
  );

  Future<(List<Map<String, dynamic>>, Map<String, dynamic>)>
  getParkingLocations({
    double? focusPointLat,
    double? focusPointLon,
    int? radius,
  }) async {
    List<Map<String, dynamic>> parkingLocations = [];

    // Build request query parameters
    Map<String, dynamic> queryParameters = {
      'purpose': 'CAR',
      'source_uids': Settings.parkApiSourceUids.join(','),
    };
    if (focusPointLat != null && focusPointLon != null && radius != null) {
      queryParameters.addAll({
        'lat': focusPointLat,
        'lon': focusPointLon,
        'radius': radius,
      });
    }

    // Fetch parking spots
    Response parkingSpotsResponse = await apiClient.get(
      '/parking-spots',
      queryParameters: queryParameters,
    );

    // Fetch parking sites
    Response parkingSitesResponse = await apiClient.get(
      '/parking-sites',
      queryParameters: queryParameters,
    );

    // TODO: ONLY FOR TESTING
    parkingLocations.addAll(
      _testParkingLocations
          .map((item) => _parseParkingSpotLocation(item))
          .toList(),
    );

    // Process parking spots
    if (parkingSpotsResponse.statusCode == 200) {
      parkingLocations.addAll(
        (parkingSpotsResponse.data['items'] as List)
            .map((item) => _parseParkingSpotLocation(item))
            .where((site) => site["disabled_parking_supported"] == true)
            .toList(),
      );
    } else {
      throw Exception(parkingSpotsResponse.statusMessage);
    }

    // Process parking sites
    if (parkingSitesResponse.statusCode == 200) {
      parkingLocations.addAll(
        (parkingSitesResponse.data['items'] as List)
            .map((item) => _parseParkingSiteLocation(item))
            .where((site) => site["disabled_parking_supported"] == true)
            .toList(),
      );
    } else {
      throw Exception(parkingSitesResponse.statusMessage);
    }

    // Remove parking locations outside the specified radius
    if (focusPointLat != null && focusPointLon != null && radius != null) {
      parkingLocations = parkingLocations.where((location) {
        num distance = maps_toolkit.SphericalUtil.computeDistanceBetween(
          maps_toolkit.LatLng(focusPointLat, focusPointLon),
          maps_toolkit.LatLng(
            location['coordinates'].latitude,
            location['coordinates'].longitude,
          ),
        );
        return distance <= radius;
      }).toList();
    }

    // Order parking locations by distance to focus point
    if (focusPointLat != null && focusPointLon != null) {
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
    }

    return (parkingLocations, convertToGeoJSON(parkingLocations));
  }

  Future<Map<String, dynamic>?> getParkingLocationDetails({
    required String id,
    required ParkingType parkingType,
  }) async {
    // TODO: ONLY FOR TESTING
    for (var testLocation in _testParkingLocations) {
      if (testLocation['id'] == id) {
        if (parkingType == ParkingType.parkingSite) {
          return _parseParkingSiteLocation(testLocation);
        } else if (parkingType == ParkingType.parkingSpot) {
          return _parseParkingSpotLocation(testLocation);
        } else {
          throw Exception('Invalid parking type');
        }
      }
    }

    if (parkingType == ParkingType.parkingSpot) {
      // Fetch details from parking-spots endpoint
      Response parkingSpotsResponse = await apiClient.get('/parking-spots/$id');
      if (parkingSpotsResponse.statusCode == 200) {
        return _parseParkingSpotLocation(parkingSpotsResponse.data);
      } else if (parkingSpotsResponse.statusCode != 404) {
        throw Exception(parkingSpotsResponse.statusMessage);
      }
      return null;
    } else if (parkingType == ParkingType.parkingSite) {
      // Fetch details from parking-sites endpoint
      Response parkingSitesResponse = await apiClient.get('/parking-sites/$id');
      if (parkingSitesResponse.statusCode == 200) {
        return _parseParkingSiteLocation(parkingSitesResponse.data);
      } else if (parkingSitesResponse.statusCode != 404) {
        throw Exception(parkingSitesResponse.statusMessage);
      }
      return null;
    } else {
      throw Exception('Invalid parking type');
    }
  }

  Map<String, dynamic> _parseParkingSpotLocation(Map<String, dynamic> item) {
    Map<String, dynamic> parkingSpot = {
      "id": item['id'].toString(),
      "parking_type": ParkingType.parkingSpot,
      "name": item['name'],
      "address": item['address'] ?? '',
      "coordinates": LatLng(
        double.parse(item['lat']),
        double.parse(item['lon']),
      ),
      "has_realtime_data": item['has_realtime_data'],
    };

    // Parse availability information
    int? capacityDisabled;
    int? freeCapacityDisabled;
    if (item.containsKey('restrictions')) {
      for (var restriction in item['restrictions'] as List) {
        if (restriction.containsKey('type') &&
            restriction['type'] == 'DISABLED') {
          capacityDisabled = 1;
          break;
        }
      }
    }
    if (item["has_realtime_data"] == true &&
        item.containsKey("realtime_status")) {
      String status = item["realtime_status"];
      if (status == "AVAILABLE") {
        freeCapacityDisabled = 1;
      } else if (status == "TAKEN") {
        freeCapacityDisabled = 0;
      } else {
        freeCapacityDisabled = null;
      }
    }

    // Compute availability of disabled parking
    parkingSpot["disabled_parking_supported"] = (capacityDisabled ?? 0) > 0;
    parkingSpot["disabled_parking_available"] = (freeCapacityDisabled ?? 0) > 0;

    // Extract city name from parking location address
    // Currently designed for the German address format
    List<String> addressParts = parkingSpot['address'].split(',');
    if (addressParts.length >= 2) {
      String cityPart = addressParts[1].trim();
      List<String> cityParts = cityPart.split(' ');
      if (cityParts.length >= 2) {
        parkingSpot['city'] = cityParts.sublist(1).join(' ');
      }
    }

    return parkingSpot;
  }

  Map<String, dynamic> _parseParkingSiteLocation(Map<String, dynamic> item) {
    Map<String, dynamic> parkingSite = {
      "id": item['id'].toString(),
      "parking_type": ParkingType.parkingSite,
      "name": item['name'],
      "address": item['address'] ?? '',
      "coordinates": LatLng(
        double.parse(item['lat']),
        double.parse(item['lon']),
      ),
      "has_realtime_data": item['has_realtime_data'],
    };

    // Parse availability information
    int? capacityDisabled;
    int? freeCapacityDisabled;
    if (item["has_realtime_data"] == true) {
      if (item.containsKey('realtime_capacity_disabled')) {
        capacityDisabled = item['realtime_capacity_disabled'];
      }
      if (item.containsKey('realtime_free_capacity_disabled')) {
        freeCapacityDisabled = item['realtime_free_capacity_disabled'];
      }
    } else {
      if (item.containsKey('capacity_disabled')) {
        capacityDisabled = item['capacity_disabled'];
      }
    }

    // Compute availability of disabled parking
    parkingSite["disabled_parking_supported"] = (capacityDisabled ?? 0) > 0;
    parkingSite["disabled_parking_available"] = (freeCapacityDisabled ?? 0) > 0;

    // Extract city name from parking location address
    // Currently designed for the German address format
    List<String> addressParts = parkingSite['address'].split(',');
    if (addressParts.length >= 2) {
      String cityPart = addressParts[1].trim();
      List<String> cityParts = cityPart.split(' ');
      if (cityParts.length >= 2) {
        parkingSite['city'] = cityParts.sublist(1).join(' ');
      }
    }

    return parkingSite;
  }

  Map<String, dynamic> convertToGeoJSON(
    List<Map<String, dynamic>> parkingLocations,
  ) {
    List<Map<String, dynamic>> features = parkingLocations.map((location) {
      // Ensure coordinates are properly typed as numbers
      final coordinates = location['coordinates'] as LatLng;

      return {
        "type": "Feature",
        "id": location['id']?.toString() ?? '', // Move id to feature level
        "geometry": {
          "type": "Point",
          "coordinates": [coordinates.longitude, coordinates.latitude],
        },
        "properties": {
          "parking_id":
              location['id']?.toString() ?? '', // Keep copy in properties too
          "name": location['name']?.toString() ?? '',
          "address": location['address']?.toString() ?? '',
          "parking_type": (location['parking_type'] as ParkingType).name,
          "has_realtime_data": location['has_realtime_data'] == true,
          "disabled_parking_supported":
              location['disabled_parking_supported'] == true,
          "disabled_parking_available":
              location['disabled_parking_available'] == true,
          if (location.containsKey('city') && location['city'] != null)
            "city": location['city'].toString(),
        },
      };
    }).toList();

    return {"type": "FeatureCollection", "features": features};
  }
}
