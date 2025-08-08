import 'package:flutter/material.dart';
import 'package:navi4all/schemas/routing/mode.dart';

class ModeIcons {
  static const Map<Mode, IconData> icons = {
    Mode.AIRPLANE: Icons.flight,
    Mode.BICYCLE: Icons.directions_bike,
    Mode.BUS: Icons.directions_bus,
    Mode.CABLE_CAR: Icons.directions_railway,
    Mode.CAR: Icons.directions_car,
    Mode.COACH: Icons.directions_bus,
    Mode.FERRY: Icons.directions_boat,
    Mode.FLEX: Icons.directions_bus,
    Mode.FUNICULAR: Icons.directions_railway,
    Mode.GONDOLA: Icons.directions_railway,
    Mode.RAIL: Icons.train,
    Mode.SCOOTER: Icons.electric_scooter,
    Mode.SUBWAY: Icons.subway,
    Mode.TRAM: Icons.tram,
    Mode.CARPOOL: Icons.people,
    Mode.TAXI: Icons.local_taxi,
    Mode.TRANSIT: Icons.directions_transit,
    Mode.WALK: Icons.directions_walk,
    Mode.TROLLEYBUS: Icons.directions_bus,
    Mode.MONORAIL: Icons.subway,
  };

  static IconData get(Mode mode) {
    return icons[mode] ?? Icons.commute;
  }
}
