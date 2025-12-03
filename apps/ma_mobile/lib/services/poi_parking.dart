import 'package:dio/dio.dart';
import 'package:smartroots/core/config.dart' show Settings;
import 'package:maps_toolkit/maps_toolkit.dart' as maps_toolkit;
import 'package:smartroots/core/utils.dart';
import 'package:smartroots/schemas/poi/parking_type.dart';
import 'package:smartroots/schemas/routing/coordinates.dart';
import 'package:smartroots/schemas/routing/place.dart';

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

  Future<(List<Place>, Map<String, dynamic>)> getParkingLocations({
    Coordinates? focusPoint,
    int? radius,
  }) async {
    List<Place> parkingLocations = [];

    // Build request query parameters
    Map<String, dynamic> queryParameters = {
      'purpose': 'CAR',
      'source_uids': Settings.parkApiSourceUids.join(','),
    };
    if (focusPoint != null && radius != null) {
      queryParameters.addAll({
        'lat': focusPoint.lat,
        'lon': focusPoint.lon,
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
            .where(
              (site) => site.attributes?["disabled_parking_supported"] == true,
            )
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
            .where(
              (site) => site.attributes?["disabled_parking_supported"] == true,
            )
            .toList(),
      );
    } else {
      throw Exception(parkingSitesResponse.statusMessage);
    }

    // Remove parking locations outside the specified radius
    if (focusPoint != null && radius != null) {
      parkingLocations = parkingLocations.where((location) {
        num distance = maps_toolkit.SphericalUtil.computeDistanceBetween(
          maps_toolkit.LatLng(focusPoint.lat, focusPoint.lon),
          maps_toolkit.LatLng(
            location.coordinates.lat,
            location.coordinates.lon,
          ),
        );
        return distance <= radius;
      }).toList();
    }

    // Order parking locations by distance to focus point
    if (focusPoint != null) {
      parkingLocations.sort((a, b) {
        double distanceA =
            ((a.coordinates.lat - focusPoint.lat) *
                (a.coordinates.lat - focusPoint.lat)) +
            ((a.coordinates.lon - focusPoint.lon) *
                (a.coordinates.lon - focusPoint.lon));
        double distanceB =
            ((b.coordinates.lat - focusPoint.lat) *
                (b.coordinates.lat - focusPoint.lat)) +
            ((b.coordinates.lon - focusPoint.lon) *
                (b.coordinates.lon - focusPoint.lon));
        return distanceA.compareTo(distanceB);
      });
    }

    return (parkingLocations, convertToGeoJSON(parkingLocations));
  }

  Future<Place?> getParkingLocationDetails({
    required String placeId,
    required PlaceType placeType,
  }) async {
    // TODO: ONLY FOR TESTING
    for (var testLocation in _testParkingLocations) {
      if (testLocation['id'] == placeId) {
        if (placeType == PlaceType.parkingSite) {
          return _parseParkingSiteLocation(testLocation);
        } else if (placeType == PlaceType.parkingSpot) {
          return _parseParkingSpotLocation(testLocation);
        } else {
          throw Exception('Invalid parking type');
        }
      }
    }

    if (placeType == PlaceType.parkingSpot) {
      // Fetch details from parking-spots endpoint
      Response parkingSpotsResponse = await apiClient.get(
        '/parking-spots/$placeId',
      );
      if (parkingSpotsResponse.statusCode == 200) {
        return _parseParkingSpotLocation(parkingSpotsResponse.data);
      } else if (parkingSpotsResponse.statusCode != 404) {
        throw Exception(parkingSpotsResponse.statusMessage);
      }
      return null;
    } else if (placeType == PlaceType.parkingSite) {
      // Fetch details from parking-sites endpoint
      Response parkingSitesResponse = await apiClient.get(
        '/parking-sites/$placeId',
      );
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

  Place _parseParkingSpotLocation(Map<String, dynamic> item) {
    Map<String, dynamic> attributes = {
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
    attributes["disabled_parking_supported"] = (capacityDisabled ?? 0) > 0;
    attributes["disabled_parking_available"] = (freeCapacityDisabled ?? 0) > 0;

    // Final place object
    Place place = Place(
      id: item['id'].toString(),
      type: PlaceType.parkingSpot,
      name: item['name'],
      address: item['address'] ?? '',
      description: TextFormatter.extractCityFromAddress(item['address'] ?? ''),
      coordinates: Coordinates(
        lat: double.parse(item['lat']),
        lon: double.parse(item['lon']),
      ),
    ).copyWith(attributes: attributes);

    return place;
  }

  Place _parseParkingSiteLocation(Map<String, dynamic> item) {
    Map<String, dynamic> attributes = {
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
    attributes["disabled_parking_supported"] = (capacityDisabled ?? 0) > 0;
    attributes["disabled_parking_available"] = (freeCapacityDisabled ?? 0) > 0;

    // Final place object
    Place place = Place(
      id: item['id'].toString(),
      type: PlaceType.parkingSite,
      name: item['name'],
      address: item['address'] ?? '',
      description: TextFormatter.extractCityFromAddress(item['address'] ?? ''),
      coordinates: Coordinates(
        lat: double.parse(item['lat']),
        lon: double.parse(item['lon']),
      ),
    ).copyWith(attributes: attributes);

    return place;
  }

  Map<String, dynamic> convertToGeoJSON(List<Place> parkingLocations) {
    List<Map<String, dynamic>> features = parkingLocations.map((location) {
      return {
        "type": "Feature",
        "id": location.id,
        "geometry": {
          "type": "Point",
          "coordinates": [location.coordinates.lon, location.coordinates.lat],
        },
        "properties": {
          "name": location.name,
          "address": location.address,
          "parking_type": location.type.name,
          "has_realtime_data":
              location.attributes?["has_realtime_data"] == true,
          "disabled_parking_supported":
              location.attributes?["disabled_parking_supported"] == true,
          "disabled_parking_available":
              location.attributes?["disabled_parking_available"] == true,
          "description": location.description,
        },
      };
    }).toList();

    return {"type": "FeatureCollection", "features": features};
  }
}
