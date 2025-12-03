import 'dart:async';

import 'package:flutter/material.dart';
import 'package:smartroots/core/config.dart';
import 'package:smartroots/schemas/routing/place.dart';
import 'package:smartroots/services/poi_parking.dart';

class AvailabilityController extends ChangeNotifier {
  final POIParkingService parkingService = POIParkingService();

  Timer? _refreshTimer;
  DateTime? _lastRefresh;
  Place? _parkingLocation;
  AvailabilityControllerState _state = AvailabilityControllerState.idle;

  Place? get parkingLocation => _parkingLocation;
  AvailabilityControllerState get state => _state;

  void startMonitoring(Place parkingLocation) {
    // Ensure this place is a parking location
    if (parkingLocation.type != PlaceType.parkingSpot &&
        parkingLocation.type != PlaceType.parkingSite) {
      throw Exception('Place is not a valid parking location');
    }

    _parkingLocation = parkingLocation;

    _refreshTimer = Timer.periodic(
      Duration(seconds: Settings.dataRefreshIntervalSeconds),
      _refresh,
    );

    _state = AvailabilityControllerState.monitoring;
  }

  void stopMonitoring() {
    _reset();

    _state = AvailabilityControllerState.idle;
  }

  Future<void> _refresh(_) async {
    // Avoid refreshing too frequently
    if (_lastRefresh != null &&
        DateTime.now().difference(_lastRefresh!) <
            Duration(seconds: Settings.dataRefreshIntervalSeconds ~/ 2)) {
      return;
    }
    _lastRefresh = DateTime.now();

    try {
      if (_parkingLocation != null) {
        // Refresh latest status of parking location
        var details = await parkingService.getParkingLocationDetails(
          placeId: _parkingLocation!.id,
          placeType: _parkingLocation!.type,
        );

        // Flag error if unable to fetch details
        if (details == null) {
          throw Exception('Unable to fetch parking location details');
        }

        // Check if availability status has changed
        if (!details.attributes?['disabled_parking_available'] &&
            details.attributes?['disabled_parking_available'] !=
                _parkingLocation!.attributes?['disabled_parking_available']) {
          _parkingLocation = details;
          _state = AvailabilityControllerState.change;
          notifyListeners();
        }
      }
    } catch (e) {
      _reset();
      _state = AvailabilityControllerState.error;
      notifyListeners();
      return;
    }
  }

  void _reset() {
    _parkingLocation = null;
    _refreshTimer?.cancel();
  }
}

enum AvailabilityControllerState { idle, monitoring, change, error }
