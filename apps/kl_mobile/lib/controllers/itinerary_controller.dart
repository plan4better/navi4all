import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:navi4all/controllers/profile_controller.dart';
import 'package:navi4all/core/theme/values.dart';
import 'package:navi4all/l10n/app_localizations.dart';
import 'package:navi4all/schemas/routing/coordinates.dart';
import 'package:navi4all/schemas/routing/itinerary.dart';
import 'package:navi4all/schemas/routing/mode.dart';
import 'package:navi4all/schemas/routing/place.dart';
import 'package:navi4all/schemas/routing/request_config.dart';
import 'package:navi4all/services/routing.dart';
import 'package:provider/provider.dart';

class ItineraryController extends ChangeNotifier {
  final RoutingService _routingService = RoutingService();

  Place? _originPlace;
  Place? _destinationPlace;

  DateTime? _time;
  bool? _isArrivalTime;
  Mode? _primaryMode;
  RoutingRequestConfig? _routingRequestConfig;

  Place? get originPlace => _originPlace;
  Place? get destinationPlace => _destinationPlace;
  DateTime? get time => _time;
  bool? get isArrivalTime => _isArrivalTime;
  Mode? get primaryMode => _primaryMode;
  RoutingRequestConfig? get routingRequestConfig => _routingRequestConfig;

  final List<ItinerarySummary> _itineraries = [];
  ItineraryControllerState _state = ItineraryControllerState.idle;

  UnmodifiableListView<ItinerarySummary> get itineraries =>
      UnmodifiableListView(_itineraries);
  ItineraryControllerState get state => _state;

  bool get hasParametersSet =>
      _originPlace != null &&
      _destinationPlace != null &&
      _primaryMode != null &&
      _routingRequestConfig != null &&
      _time != null &&
      _isArrivalTime != null;

  void setParameters({
    required BuildContext context,
    required Place originPlace,
    required Place destinationPlace,
    required DateTime time,
    required Mode primaryMode,
    bool isArrivalTime = false,
  }) {
    _originPlace = originPlace;
    _destinationPlace = destinationPlace;
    _time = time;
    _primaryMode = primaryMode;
    _routingRequestConfig = Provider.of<ProfileController>(
      context,
      listen: false,
    ).routingRequestConfig;
    _isArrivalTime = isArrivalTime;

    _refresh(context);
  }

  void reset(BuildContext context) {
    _originPlace = null;
    _destinationPlace = null;
    _routingRequestConfig = null;
    _time = null;
    _isArrivalTime = null;

    _refresh(context);
  }

  Future<void> _refresh(BuildContext context) async {
    _state = ItineraryControllerState.refreshing;
    _itineraries.clear();
    notifyListeners();

    // Ensure request parameters are set
    if (!hasParametersSet) {
      _state = ItineraryControllerState.idle;
      notifyListeners();
      return;
    }

    // Refresh user location if required
    if (_originPlace!.id == Navi4AllValues.userLocation) {
      Position? userLocation = await _getUserLocation(context);
      if (userLocation != null) {
        _originPlace = Place(
          id: Navi4AllValues.userLocation,
          name: AppLocalizations.of(context)!.origDestCurrentLocation,
          type: PlaceType.address,
          address: '',
          description: '',
          coordinates: Coordinates(
            lat: userLocation.latitude,
            lon: userLocation.longitude,
          ),
        );
      } else {
        reset(context);
        return;
      }
    }

    if (_destinationPlace!.id == Navi4AllValues.userLocation) {
      Position? userLocation = await _getUserLocation(context);
      if (userLocation != null) {
        _destinationPlace = Place(
          id: Navi4AllValues.userLocation,
          name: AppLocalizations.of(context)!.origDestCurrentLocation,
          type: PlaceType.address,
          address: '',
          description: '',
          coordinates: Coordinates(
            lat: userLocation.latitude,
            lon: userLocation.longitude,
          ),
        );
      } else {
        reset(context);
        return;
      }
    }

    try {
      // Fetch data
      List<ItinerarySummary> results = await _routingService.getItineraries(
        originLat: _originPlace!.coordinates.lat,
        originLon: _originPlace!.coordinates.lon,
        destinationLat: _destinationPlace!.coordinates.lat,
        destinationLon: _destinationPlace!.coordinates.lon,
        time: _time!,
        transportModes: _primaryMode! == Mode.TRANSIT
            ? _routingRequestConfig!.transitModes.map((e) => e.name).toList()
            : [_primaryMode!.name],
        timeIsArrival: _isArrivalTime!,
        walkingSpeed: _routingRequestConfig!.walkingSpeed,
        walkingAvoid: _routingRequestConfig!.walkingAvoid,
        bicycleSpeed: _routingRequestConfig!.bicycleSpeed,
        accessible: _routingRequestConfig!.accessible,
      );

      // Update results
      _itineraries.addAll(results);

      await Future.delayed(const Duration(milliseconds: 200));
    } catch (e) {
      _state = ItineraryControllerState.error;
      notifyListeners();
      return;
    }

    _state = ItineraryControllerState.idle;
    notifyListeners();
  }

  Future<Position?> _getUserLocation(BuildContext context) async {
    // Check location permission status
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      await Geolocator.requestPermission();
    }

    permission = await Geolocator.checkPermission();
    if (permission != LocationPermission.whileInUse &&
        permission != LocationPermission.always) {
      // User will need to enable permissions from app settings
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            AppLocalizations.of(context)!.userLocationDeniedSnackbarText,
          ),
        ),
      );
      return null;
    }

    // Fetch user location
    return await Geolocator.getCurrentPosition();
  }
}

enum ItineraryControllerState { idle, refreshing, error }
