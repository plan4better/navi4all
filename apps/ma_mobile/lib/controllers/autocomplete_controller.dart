import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:smartroots/core/persistence/preference_helper.dart';
import 'package:smartroots/schemas/routing/coordinates.dart';
import 'package:smartroots/schemas/routing/place.dart';
import 'package:smartroots/services/geocoding.dart';
import 'package:smartroots/core/config.dart';

class AutocompleteController extends ChangeNotifier {
  final GeocodingService _geocodingService = GeocodingService();

  SearchControllerState _state = SearchControllerState.idle;
  Coordinates _focalPoint = Settings.defaultFocalPoint;
  String _searchQuery = '';
  DateTime? _searchTimestamp;
  final List<Place> _searchResults = [];
  final List<Place> _recentSearches = [];

  AutocompleteController(BuildContext context) {
    _refreshRecentSearches();
    _initializeFocalPoint(context);
  }

  SearchControllerState get state => _state;
  UnmodifiableListView<Place> get searchResults =>
      UnmodifiableListView(_searchResults);
  UnmodifiableListView<Place> get recentSearches =>
      UnmodifiableListView(_recentSearches);
  String get searchQuery => _searchQuery;

  void updateSearchQuery(String query) {
    _searchQuery = query;
    _refresh();
  }

  Future<void> addRecentSearch(Place place) async {
    // Add place to recent searches
    await PreferenceHelper.addRecentSearch(place);

    // Update local recent searches list
    await _refreshRecentSearches();
  }

  void reset() {
    _searchQuery = '';
    _searchTimestamp = null;
    _searchResults.clear();
    notifyListeners();
  }

  Future<void> _initializeFocalPoint(BuildContext context) async {
    // Attempt to get current position (lazy)
    Position? currentPosition = await _getUserLocation(context);

    if (currentPosition != null) {
      _focalPoint = Coordinates(
        lat: currentPosition.latitude,
        lon: currentPosition.longitude,
      );
    }
  }

  Future<void> _refreshRecentSearches() async {
    _recentSearches.clear();
    _recentSearches.addAll(await PreferenceHelper.getRecentSearches());
    notifyListeners();
  }

  Future<void> _refresh() async {
    _state = SearchControllerState.refreshing;

    try {
      // Use timestamp to discard outdated results
      _searchTimestamp = DateTime.now();
      _searchResults.clear();

      if (_searchQuery.isNotEmpty) {
        // Fetch autocomplete results
        var (timestamp, places) = await _geocodingService.autocomplete(
          timestamp: _searchTimestamp!.toIso8601String(),
          query: _searchQuery,
          focusPointLat: _focalPoint.lat,
          focusPointLon: _focalPoint.lon,
          limit: 4,
        );

        // Ensure results are fresh
        if (_searchTimestamp != null && timestamp.isBefore(_searchTimestamp!)) {
          return;
        }

        _searchResults.addAll(places);
      }
    } catch (e) {
      _state = SearchControllerState.error;
      notifyListeners();
      return;
    }

    _state = SearchControllerState.idle;
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
      return null;
    }

    // Fetch user location
    return await Geolocator.getLastKnownPosition();
  }
}

enum SearchControllerState { idle, refreshing, error }
