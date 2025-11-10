import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:navi4all/core/persistence/preference_helper.dart';
import 'package:navi4all/schemas/routing/place.dart';

class FavoritesController extends ChangeNotifier {
  final List<Place> _favorites = [];
  FavoritesControllerState _state = FavoritesControllerState.idle;

  FavoritesController(BuildContext context) {
    _refresh();
  }

  UnmodifiableListView<Place> get favorites => UnmodifiableListView(_favorites);
  FavoritesControllerState get state => _state;

  Future<void> addFavorite(Place place) async {
    await PreferenceHelper.addFavorite(place);
    _refresh();
  }

  Future<void> removeFavorite(String id) async {
    await PreferenceHelper.removeFavorite(id);
    _refresh();
  }

  Future<bool> checkIsFavorite(String id) async {
    return await PreferenceHelper.isFavorite(id);
  }

  Future<void> _refresh() async {
    _state = FavoritesControllerState.refreshing;

    try {
      _favorites.clear();

      // Fetch favorites from persistent storage
      List<Place> favoritesMetadata = await PreferenceHelper.getFavorites();

      // Refresh latest status of each favorite
      for (var item in favoritesMetadata) {
        _favorites.add(item);
      }

      // Post-process favorites
      _favorites.sort(
        (a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()),
      );
    } catch (e) {
      _state = FavoritesControllerState.error;
      notifyListeners();
      return;
    }

    _state = FavoritesControllerState.idle;
    notifyListeners();
  }
}

enum FavoritesControllerState { idle, refreshing, error }
