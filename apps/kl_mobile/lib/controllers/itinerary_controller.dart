import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:navi4all/schemas/routing/itinerary.dart';
import 'package:navi4all/schemas/routing/mode.dart';
import 'package:navi4all/schemas/routing/place.dart';
import 'package:navi4all/services/routing.dart';

class ItineraryController extends ChangeNotifier {
  final RoutingService _routingService = RoutingService();

  Place? _originPlace;
  Place? _destinationPlace;
  List<Mode>? _modes;
  DateTime? _time;
  bool? _isArrivalTime;

  Place? get originPlace => _originPlace;
  Place? get destinationPlace => _destinationPlace;
  List<Mode>? get modes => _modes;
  DateTime? get time => _time;
  bool? get isArrivalTime => _isArrivalTime;

  final List<ItinerarySummary> _itineraries = [];
  ItineraryControllerState _state = ItineraryControllerState.idle;

  UnmodifiableListView<ItinerarySummary> get itineraries =>
      UnmodifiableListView(_itineraries);
  ItineraryControllerState get state => _state;

  bool get hasParametersSet =>
      _originPlace != null &&
      _destinationPlace != null &&
      _modes != null &&
      _time != null &&
      _isArrivalTime != null;

  void setParameters({
    required Place originPlace,
    required Place destinationPlace,
    required List<Mode> modes,
    required DateTime time,
    bool isArrivalTime = false,
  }) {
    _originPlace = originPlace;
    _destinationPlace = destinationPlace;
    _modes = modes;
    _time = time;
    _isArrivalTime = isArrivalTime;

    _refresh();
  }

  void reset() {
    _originPlace = null;
    _destinationPlace = null;
    _modes = null;
    _time = null;
    _isArrivalTime = null;

    _refresh();
  }

  Future<void> _refresh() async {
    _state = ItineraryControllerState.refreshing;
    _itineraries.clear();
    notifyListeners();

    // Ensure request parameters are set
    if (!hasParametersSet) {
      _state = ItineraryControllerState.idle;
      notifyListeners();
      return;
    }

    try {
      // Fetch data
      List<ItinerarySummary> results = await _routingService.getItineraries(
        originLat: _originPlace!.coordinates.lat,
        originLon: _originPlace!.coordinates.lon,
        destinationLat: _destinationPlace!.coordinates.lat,
        destinationLon: _destinationPlace!.coordinates.lon,
        time: _time!,
        transportModes: _modes!.map((mode) => mode.name).toList(),
        timeIsArrival: _isArrivalTime!,
      );

      // Update results
      _itineraries.addAll(results);

      // Post-process results
      /* _itineraries.sort((a, b) {
        int durationCompare = a.duration.compareTo(b.duration);
        if (durationCompare != 0) return durationCompare;
        return a.legs.length.compareTo(b.legs.length);
      }); */

      await Future.delayed(const Duration(milliseconds: 200));
    } catch (e) {
      _state = ItineraryControllerState.error;
      notifyListeners();
      return;
    }

    _state = ItineraryControllerState.idle;
    notifyListeners();
  }
}

enum ItineraryControllerState { idle, refreshing, error }
