import 'dart:async';

import 'package:flutter/material.dart';
import 'package:smartroots/core/config.dart';
import 'package:smartroots/services/poi_parking.dart';

class AvailabilityController extends ChangeNotifier {
  final POIParkingService parkingService = POIParkingService();

  Timer? _refreshTimer;
  DateTime? _lastRefresh;
  Map<String, dynamic>? _parkingLocation;
  AvailabilityControllerState _state = AvailabilityControllerState.idle;

  Map<String, dynamic>? get parkingLocation => _parkingLocation;
  AvailabilityControllerState get state => _state;

  void startMonitoring(Map<String, dynamic> parkingLocation) {
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
          id: _parkingLocation!["id"],
          parkingType: _parkingLocation!["parking_type"],
        );

        // Flag error if unable to fetch details
        if (details == null) {
          throw Exception('Unable to fetch parking location details');
        }

        // Check if availability status has changed
        if (!details['disabled_parking_available'] &&
            details['disabled_parking_available'] !=
                _parkingLocation!['disabled_parking_available']) {
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
