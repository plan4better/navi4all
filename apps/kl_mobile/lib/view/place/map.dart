import 'dart:math';
import 'dart:core';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:maplibre_gl/maplibre_gl.dart';
import 'package:navi4all/core/theme/profile_mode.dart';
import 'package:navi4all/core/theme/values.dart';
import 'package:navi4all/schemas/routing/place.dart';
import 'package:provider/provider.dart';
import 'package:navi4all/controllers/theme_controller.dart';
import 'package:navi4all/core/config.dart';

class PlaceMap extends StatefulWidget {
  final Place place;
  const PlaceMap({required this.place, super.key});

  @override
  State<StatefulWidget> createState() => _PlaceMapState();
}

class _PlaceMapState extends State<PlaceMap> {
  late MapLibreMapController _mapController;
  bool _canInteractWithMap = false;

  Future<void> _onStyleLoaded() async {
    // Clear existing markers and listeners
    await _mapController.clearSymbols();
    _mapController.onSymbolTapped.clear();

    // Load custom marker icons
    String assetMarkerPlace =
        Provider.of<ThemeController>(context, listen: false).profileMode ==
            ProfileMode.visionImpaired
        ? Navi4AllValues.assetMarkerPlaceVisImp
        : Navi4AllValues.assetMarkerPlaceGeneral;
    final bytes4 = await rootBundle.load(assetMarkerPlace);
    final list4 = bytes4.buffer.asUint8List();
    _mapController.addImage("place.png", list4);

    _drawPlace();

    await Future.delayed(const Duration(milliseconds: 250));
    setState(() => _canInteractWithMap = true);
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Consumer<ThemeController>(
          builder: (context, themeController, child) => MapLibreMap(
            myLocationEnabled: true,
            styleString:
                Settings.baseMapStyleUrls[themeController.baseMapStyle]!,
            onMapCreated: (controller) => _mapController = controller,
            minMaxZoomPreference: MinMaxZoomPreference(5.0, null),
            cameraTargetBounds: CameraTargetBounds(
              LatLngBounds(
                southwest: LatLng(47.2701, 5.8663),
                northeast: LatLng(55.0581, 15.0419),
              ),
            ),
            initialCameraPosition: CameraPosition(
              target: LatLng(
                widget.place.coordinates.lat - 0.003,
                widget.place.coordinates.lon,
              ),
              zoom: 14,
            ),
            onStyleLoadedCallback: _onStyleLoaded,
            compassViewMargins: const Point(16, 160),
            compassViewPosition: CompassViewPosition.topRight,
          ),
        ),
        // Fill screen with background while map is loading
        !_canInteractWithMap
            ? Container(color: Theme.of(context).colorScheme.surface)
            : SizedBox.shrink(),
      ],
    );
  }

  void _drawPlace() {
    _mapController.addSymbol(
      SymbolOptions(
        geometry: LatLng(
          widget.place.coordinates.lat,
          widget.place.coordinates.lon,
        ),
        iconImage: "place.png",
        iconSize: 0.9,
      ),
    );
  }
}
