import 'package:flutter/material.dart';
import 'package:navi4all/schemas/routing/place.dart';

class PlaceController extends ChangeNotifier {
  Place? _place;

  Place? get place => _place;

  void setPlace(Place place) {
    _place = place;
    notifyListeners();
  }

  void reset() {
    _place = null;
    notifyListeners();
  }
}
