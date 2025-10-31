import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:smartroots/core/persistence/preference_helper.dart';
import 'package:smartroots/schemas/poi/parking_type.dart';
import 'package:smartroots/services/poi_parking.dart';

class FavouritesController extends ChangeNotifier {
  POIParkingService parkingService = POIParkingService();

  final List<Map<String, dynamic>> _favouriteParkingLocations = [];
  FavouritesControllerState _state = FavouritesControllerState.idle;

  FavouritesController(BuildContext context) {
    _refresh();
  }

  UnmodifiableListView<Map<String, dynamic>> get favouriteParkingLocations =>
      UnmodifiableListView(_favouriteParkingLocations);
  FavouritesControllerState get state => _state;

  Future<void> addFavouriteParkingLocation(
    String id,
    ParkingType parkingType,
  ) async {
    await PreferenceHelper.addFavoriteParkingLocation(id, parkingType);
    _refresh();
  }

  Future<void> removeFavouriteParkingLocation(
    String id,
    ParkingType parkingType,
  ) async {
    await PreferenceHelper.removeFavoriteParkingLocation(id, parkingType);
    _refresh();
  }

  Future<bool> checkIsFavouriteParkingLocation(
    String id,
    ParkingType parkingType,
  ) async {
    return await PreferenceHelper.isFavoriteParkingLocation(id, parkingType);
  }

  Future<void> _refresh() async {
    _state = FavouritesControllerState.refreshing;

    try {
      _favouriteParkingLocations.clear();

      // Fetch favourites from persistent storage
      List<Map<String, dynamic>> favouriteParkingLocationsMetadata =
          await PreferenceHelper.getFavoriteParkingLocations();

      // Refresh latest status of each favourite
      for (var item in favouriteParkingLocationsMetadata) {
        var details = await parkingService.getParkingLocationDetails(
          id: item["id"],
          parkingType: item["parking_type"],
        );
        if (details != null) {
          _favouriteParkingLocations.add(details);
        }
      }

      // Post-process favourites
      _favouriteParkingLocations.sort(
        (a, b) => a["name"].toString().toLowerCase().compareTo(
          b["name"].toString().toLowerCase(),
        ),
      );
    } catch (e) {
      _state = FavouritesControllerState.error;
      notifyListeners();
      return;
    }

    _state = FavouritesControllerState.idle;
    notifyListeners();
  }
}

enum FavouritesControllerState { idle, refreshing, error }
