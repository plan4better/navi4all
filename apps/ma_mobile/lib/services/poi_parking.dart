import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:smartroots/core/config.dart' show Settings;
import 'package:maps_toolkit/maps_toolkit.dart' as maps_toolkit;
import 'package:smartroots/core/utils.dart';
import 'package:smartroots/schemas/routing/coordinates.dart';
import 'package:smartroots/schemas/routing/place.dart';
import 'package:path_provider/path_provider.dart';

class POIParkingService {
  final String _staticParkingLocationsCacheFileName =
      'ma_parking_locations_static.geojson';

  final Dio apiClient = Dio(
    BaseOptions(
      baseUrl: Settings.parkApiBaseUrl,
      connectTimeout: Duration(seconds: Settings.apiConnectTimeout),
      receiveTimeout: Duration(seconds: Settings.apiReceiveTimeout),
      queryParameters: {
        'purpose': 'CAR',
        'lat_min': Settings.parkApiLatMin,
        'lon_min': Settings.parkApiLonMin,
        'lat_max': Settings.parkApiLatMax,
        'lon_max': Settings.parkApiLonMax,
        'calculate_has_realtime_data': 'false',
      },
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

    // Process parking spots
    if (parkingSpotsResponse.statusCode == 200) {
      parkingLocations.addAll(
        (parkingSpotsResponse.data['items'] as List)
            .map((item) => _parseParkingSpotLocation(item))
            .where(
              (site) =>
                  site.attributes?["disabled_parking_supported"] == true &&
                  site.attributes?["has_realtime_data"] == true,
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
              (site) =>
                  site.attributes?["disabled_parking_supported"] == true &&
                  site.attributes?["has_realtime_data"] == true,
            )
            .toList(),
      );
    } else {
      throw Exception(parkingSitesResponse.statusMessage);
    }

    // Fetch static parking locations from cache
    parkingLocations.addAll(
      await _getStaticParkingLocationsFromCache(
        focusPoint: focusPoint,
        radius: radius,
      ),
    );

    // Divide parking locations into availability groups
    List<Place> availableDisabledParking = parkingLocations
        .where(
          (location) =>
              location.attributes?["disabled_parking_available"] == true,
        )
        .toList();
    List<Place> unavailableDisabledParking = parkingLocations
        .where(
          (location) =>
              location.attributes?["disabled_parking_available"] == false,
        )
        .toList();
    List<Place> unknownAvailabilityDisabledParking = parkingLocations
        .where(
          (location) =>
              location.attributes?["disabled_parking_available"] == null,
        )
        .toList();

    // Order parking locations by distance to focus point within same availability group
    if (focusPoint != null) {
      maps_toolkit.LatLng focusLatLng = maps_toolkit.LatLng(
        focusPoint.lat,
        focusPoint.lon,
      );
      availableDisabledParking.sort((a, b) {
        num distanceA = maps_toolkit.SphericalUtil.computeDistanceBetween(
          focusLatLng,
          maps_toolkit.LatLng(a.coordinates.lat, a.coordinates.lon),
        );
        num distanceB = maps_toolkit.SphericalUtil.computeDistanceBetween(
          focusLatLng,
          maps_toolkit.LatLng(b.coordinates.lat, b.coordinates.lon),
        );
        return distanceA.compareTo(distanceB);
      });
      unavailableDisabledParking.sort((a, b) {
        num distanceA = maps_toolkit.SphericalUtil.computeDistanceBetween(
          focusLatLng,
          maps_toolkit.LatLng(a.coordinates.lat, a.coordinates.lon),
        );
        num distanceB = maps_toolkit.SphericalUtil.computeDistanceBetween(
          focusLatLng,
          maps_toolkit.LatLng(b.coordinates.lat, b.coordinates.lon),
        );
        return distanceA.compareTo(distanceB);
      });
      unknownAvailabilityDisabledParking.sort((a, b) {
        num distanceA = maps_toolkit.SphericalUtil.computeDistanceBetween(
          focusLatLng,
          maps_toolkit.LatLng(a.coordinates.lat, a.coordinates.lon),
        );
        num distanceB = maps_toolkit.SphericalUtil.computeDistanceBetween(
          focusLatLng,
          maps_toolkit.LatLng(b.coordinates.lat, b.coordinates.lon),
        );
        return distanceA.compareTo(distanceB);
      });
    }

    // Rebuild final parking locations list
    parkingLocations = [
      ...availableDisabledParking,
      ...unavailableDisabledParking,
      ...unknownAvailabilityDisabledParking,
    ];

    return (parkingLocations, convertToGeoJSON(parkingLocations));
  }

  Future<void> updateStaticParkingLocationsCache() async {
    List<Place> parkingLocations = [];

    // Fetch parking spots
    Response parkingSpotsResponse = await apiClient.get('/parking-spots');

    // Fetch parking sites
    Response parkingSitesResponse = await apiClient.get('/parking-sites');

    // Process parking spots
    if (parkingSpotsResponse.statusCode == 200) {
      parkingLocations.addAll(
        (parkingSpotsResponse.data['items'] as List)
            .map((item) => _parseParkingSpotLocation(item))
            .where(
              (site) =>
                  site.attributes?["disabled_parking_supported"] == true &&
                  site.attributes?["has_realtime_data"] == false,
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
              (site) =>
                  site.attributes?["disabled_parking_supported"] == true &&
                  site.attributes?["has_realtime_data"] == false,
            )
            .toList(),
      );
    } else {
      throw Exception(parkingSitesResponse.statusMessage);
    }

    // Write static parking locations to cache as GeoJSON
    try {
      final file = File(
        '${(await getApplicationDocumentsDirectory()).path}/$_staticParkingLocationsCacheFileName',
      );

      await file.writeAsString(
        const JsonEncoder.withIndent(
          '  ',
        ).convert(convertToGeoJSON(parkingLocations)),
      );
    } catch (error) {
      return;
    }
  }

  Future<List<Place>> _getStaticParkingLocationsFromCache({
    Coordinates? focusPoint,
    int? radius,
  }) async {
    List<Place> parkingLocations = [];

    // Fetch static parking locations from cache and parse GeoJSON
    try {
      final file = File(
        '${(await getApplicationDocumentsDirectory()).path}/$_staticParkingLocationsCacheFileName',
      );
      if (await file.exists()) {
        String content = await file.readAsString();
        Map<String, dynamic> geoJson = jsonDecode(content);
        for (var feature in geoJson['features'] as List) {
          Map<String, dynamic> properties = feature['properties'];
          parkingLocations.add(
            Place(
              id: feature['id'],
              type: PlaceType.values.byName(properties['parking_type']),
              name: properties['name'],
              address: properties['address'],
              description: properties['description'],
              coordinates: Coordinates(
                lat: feature['geometry']['coordinates'][1],
                lon: feature['geometry']['coordinates'][0],
              ),
              attributes: {
                "has_realtime_data": properties['has_realtime_data'],
                "disabled_parking_supported":
                    properties['disabled_parking_supported'],
                "disabled_parking_available":
                    properties['disabled_parking_available'],
              },
            ),
          );
        }
      }
    } catch (error) {
      return parkingLocations;
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

    return parkingLocations;
  }

  Future<Place?> getParkingLocationDetails({
    required String placeId,
    required PlaceType placeType,
  }) async {
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
    Map<String, dynamic> attributes = {};

    // Parse restrictions and derive disabled parking info
    final restrictions = item['restrictions'] as List? ?? const [];
    final supportsDisabledParking = restrictions.any((restriction) {
      if (restriction is! Map<String, dynamic>) {
        return false;
      }
      return restriction['type'] == 'DISABLED';
    });

    final hasRealtimeData = item['has_realtime_data'] == true;
    final realtimeStatus = item['realtime_status'] as String?;

    // Real-time data status is only relevant if supported for disabled parking
    final hasDisabledRealtimeData =
        supportsDisabledParking &&
        hasRealtimeData &&
        (realtimeStatus == 'AVAILABLE' || realtimeStatus == 'TAKEN');

    bool? disabledParkingAvailable;
    if (hasDisabledRealtimeData) {
      disabledParkingAvailable = realtimeStatus == 'AVAILABLE';
    }

    attributes["has_realtime_data"] = hasDisabledRealtimeData;
    attributes["disabled_parking_supported"] = supportsDisabledParking;
    attributes["disabled_parking_available"] = disabledParkingAvailable;

    // Final place object
    Place place = Place(
      id: item['id'].toString(),
      type: PlaceType.parkingSpot,
      name: item['name'] ?? 'Parkplatz',
      address: item['address'] ?? '',
      description: TextFormatter.extractCityFromAddress(item['address'] ?? ''),
      coordinates: Coordinates(
        lat: item['lat'].runtimeType == double
            ? item['lat']
            : double.parse(item['lat']),
        lon: item['lon'].runtimeType == double
            ? item['lon']
            : double.parse(item['lon']),
      ),
    ).copyWith(attributes: attributes);
    return place;
  }

  Place _parseParkingSiteLocation(Map<String, dynamic> item) {
    Map<String, dynamic> attributes = {};

    // Parse restrictions and derive disabled parking info
    final restrictions = item['restrictions'] as List? ?? const [];
    final disabledRestrictions = restrictions
        .where((restriction) {
          if (restriction is! Map<String, dynamic>) {
            return false;
          }
          return restriction['type'] == 'DISABLED';
        })
        .cast<Map<String, dynamic>>()
        .toList();

    final hasRealtimeData = item['has_realtime_data'] == true;
    final supportsDisabledParking = disabledRestrictions.isNotEmpty;

    final realtimeFreeCapacities = disabledRestrictions
        .map(
          (restriction) => int.tryParse(
            restriction['realtime_free_capacity']?.toString() ?? '',
          ),
        )
        .whereType<int>()
        .toList();

    // Real-time data status is only relevant if supported for disabled parking
    final hasDisabledRealtimeData =
        supportsDisabledParking &&
        hasRealtimeData &&
        realtimeFreeCapacities.isNotEmpty;

    bool? disabledParkingAvailable;
    if (hasDisabledRealtimeData) {
      if (realtimeFreeCapacities.any((capacity) => capacity > 0)) {
        disabledParkingAvailable = true;
      } else {
        disabledParkingAvailable = false;
      }
    }

    attributes["has_realtime_data"] = hasDisabledRealtimeData;
    attributes["disabled_parking_supported"] = supportsDisabledParking;
    attributes["disabled_parking_available"] = disabledParkingAvailable;

    // Final place object
    Place place = Place(
      id: item['id'].toString(),
      type: PlaceType.parkingSite,
      name: item['name'],
      address: item['address'] ?? '',
      description: TextFormatter.extractCityFromAddress(item['address'] ?? ''),
      coordinates: Coordinates(
        lat: item['lat'].runtimeType == double
            ? item['lat']
            : double.parse(item['lat']),
        lon: item['lon'].runtimeType == double
            ? item['lon']
            : double.parse(item['lon']),
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
