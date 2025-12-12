import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:smartroots/core/persistence/preference_helper.dart';
import 'package:smartroots/schemas/routing/place.dart';
import 'package:smartroots/services/poi_parking.dart';

class FavoritesController extends ChangeNotifier {
  POIParkingService parkingService = POIParkingService();

  final List<Place> _favorites = [];
  FavoritesControllerState _state = FavoritesControllerState.idle;

  FavoritesController(BuildContext context) {
    refresh();
  }

  UnmodifiableListView<Place> get favorites => UnmodifiableListView(_favorites);
  FavoritesControllerState get state => _state;

  Future<void> addFavorite(Place place) async {
    await PreferenceHelper.addFavorite(place);
    refresh();
  }

  Future<void> removeFavorite(Place place) async {
    await PreferenceHelper.removeFavorite(place);
    refresh();
  }

  Future<bool> checkIsFavorite(Place place) async {
    return await PreferenceHelper.isFavorite(place);
  }

  Future<void> refresh() async {
    _state = FavoritesControllerState.refreshing;

    try {
      _favorites.clear();

      // Fetch favourites from persistent storage
      List<Place> favoritesMetadata = await PreferenceHelper.getFavorites();

      // Refresh latest status of each favourite
      for (var item in favoritesMetadata) {
        // Non-parking places
        if (item.type != PlaceType.parkingSpot &&
            item.type != PlaceType.parkingSite) {
          _favorites.add(item);
          continue;
        }

        // Parking places
        var details = await parkingService.getParkingLocationDetails(
          placeId: item.id,
          placeType: item.type,
        );
        if (details != null) {
          _favorites.add(details);
        }
      }

      // Post-process favourites
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
