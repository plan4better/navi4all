import 'package:flutter/material.dart';

class CanvasController extends ChangeNotifier {
  CanvasControllerState _state = CanvasControllerState.home;

  CanvasControllerState get state => _state;

  void setState(CanvasControllerState state) {
    _state = state;
    notifyListeners();
  }
}

enum CanvasControllerState { home, place, itinerary, navigating }
