import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:smartroots/schemas/routing/coordinates.dart';
import 'package:smartroots/schemas/routing/place.dart';
import 'package:smartroots/services/geocoding.dart';
import 'package:smartroots/core/config.dart';

class AutocompleteController extends ChangeNotifier {
  final GeocodingService _geocodingService = GeocodingService();

  SearchControllerState _state = SearchControllerState.idle;
  final Coordinates _focalPoint = Settings.defaultFocalPoint;
  String _searchQuery = '';
  DateTime? _searchTimestamp;
  final List<Place> _searchResults = [];

  SearchControllerState get state => _state;
  UnmodifiableListView<Place> get searchResults =>
      UnmodifiableListView(_searchResults);
  String get searchQuery => _searchQuery;

  void updateSearchQuery(String query) {
    _searchQuery = query;
    _refresh();
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
}

enum SearchControllerState { idle, refreshing, error }
