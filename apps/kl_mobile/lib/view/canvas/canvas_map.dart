import 'dart:math';
import 'dart:core';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:maplibre_gl/maplibre_gl.dart';
import 'package:provider/provider.dart';
import 'package:navi4all/controllers/theme_controller.dart';
import 'package:navi4all/core/config.dart';

class CanvasMap extends StatefulWidget {
  const CanvasMap({super.key});

  @override
  State<StatefulWidget> createState() => _CanvasMapState();
}

class _CanvasMapState extends State<CanvasMap> {
  late MapLibreMapController _mapController;
  bool _canInteractWithMap = false;

  Future<void> _onStyleLoaded() async {
    // Load custom marker icons
    final bytes4 = await rootBundle.load('assets/place.png');
    final list4 = bytes4.buffer.asUint8List();
    _mapController.addImage("place.png", list4);

    // Enable user interaction
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
                Settings.defaultFocalPoint.lat - 0.003,
                Settings.defaultFocalPoint.lon,
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
}
