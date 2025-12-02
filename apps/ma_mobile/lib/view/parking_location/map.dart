import 'dart:math';
import 'dart:core';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:maplibre_gl/maplibre_gl.dart';
import 'package:provider/provider.dart';
import 'package:smartroots/controllers/theme_controller.dart';
import 'package:smartroots/core/config.dart';
import 'package:smartroots/l10n/app_localizations.dart';
import 'package:smartroots/services/poi_parking.dart';
import 'package:smartroots/view/parking_location/parking_location.dart';

class ParkingSiteMap extends StatefulWidget {
  final Map<String, dynamic> parkingSite;
  final bool showAlternatives;
  const ParkingSiteMap({
    required this.parkingSite,
    required this.showAlternatives,
    super.key,
  });

  @override
  State<StatefulWidget> createState() => _ParkingSiteMapState();
}

class _ParkingSiteMapState extends State<ParkingSiteMap> {
  late MapLibreMapController _mapController;
  bool _canInteractWithMap = false;
  List<Map<String, dynamic>> _parkingSites = [];
  final Map<String, Map<String, dynamic>> _symbolIdToSite = {};

  Future<void> _onStyleLoaded() async {
    // Fetch and draw map layers
    _fetchMapLayers().then((_) {
      // Add symbol tap listener
      _mapController.onCircleTapped.add(_onCircleTapped);
    });

    // Load custom marker icons
    final bytes = await rootBundle.load('assets/parking_avbl_yes.png');
    final list = bytes.buffer.asUint8List();
    await _mapController.addImage("parking_avbl_yes.png", list);

    final bytes2 = await rootBundle.load('assets/parking_avbl_no.png');
    final list2 = bytes2.buffer.asUint8List();
    await _mapController.addImage("parking_avbl_no.png", list2);

    final bytes3 = await rootBundle.load('assets/parking_avbl_unknown.png');
    final list3 = bytes3.buffer.asUint8List();
    await _mapController.addImage("parking_avbl_unknown.png", list3);

    await _drawPlace();

    await Future.delayed(const Duration(milliseconds: 250));
    setState(() => _canInteractWithMap = true);
  }

  Future<void> _fetchMapLayers() async {
    // Clear existing layers
    await _mapController.clearSymbols();
    _mapController.onSymbolTapped.clear();
    await _mapController.clearCircles();
    _mapController.onCircleTapped.clear();

    // Only continue if alternative parking locations are to be shown
    if (!widget.showAlternatives) {
      return;
    }

    // Draw radius circle
    _drawRadius();

    // Fetch parking sites and draw markers
    await _fetchParkingSites();

    // Draw place marker
    await _drawPlace();

    // Compute new camera zoom and position to fit radius
    double zoomLevel = 14.0 - log(Settings.defaultRadius / 450) / log(2);
    zoomLevel = zoomLevel.clamp(9.0, 16.0);
    await _mapController.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(
          target: LatLng(
            widget.parkingSite['coordinates'].latitude -
                (Settings.defaultRadius / 200000),
            widget.parkingSite['coordinates'].longitude,
          ),
          zoom: zoomLevel,
        ),
      ),
      duration: const Duration(seconds: 2),
    );
  }

  Future<void> _fetchParkingSites() async {
    POIParkingService parkingService = POIParkingService();
    try {
      List<Map<String, dynamic>> result;
      (result, _) = await parkingService.getParkingLocations(
        focusPointLat: widget.parkingSite['coordinates'].latitude,
        focusPointLon: widget.parkingSite['coordinates'].longitude,
        radius: Settings.defaultRadius,
      );

      setState(() {
        _parkingSites = result;
      });
      _updateMarkers();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            AppLocalizations.of(context)!.errorUnableToFetchParkingSites,
          ),
        ),
      );
    }
  }

  void _drawRadius() {
    // Draw a polygon (circle approximation) with given radius in meters
    final center = LatLng(
      widget.parkingSite['coordinates'].latitude,
      widget.parkingSite['coordinates'].longitude,
    );
    final int points = 60; // More points = smoother circle
    final double radiusInMeters = Settings.defaultRadius.toDouble();
    final double earthRadius = 6378137.0;

    List<LatLng> polygon = [];
    for (int i = 0; i < points; i++) {
      double angle = (i * 2 * pi) / points;
      double dx = radiusInMeters * cos(angle);
      double dy = radiusInMeters * sin(angle);

      double deltaLat = (dy / earthRadius) * (180 / pi);
      double deltaLon =
          (dx / (earthRadius * cos(pi * center.latitude / 180))) * (180 / pi);

      polygon.add(
        LatLng(center.latitude + deltaLat, center.longitude + deltaLon),
      );
    }

    _mapController.addFill(
      FillOptions(
        geometry: [polygon],
        fillColor: '#8FBBEF',
        fillOpacity: 0.15,
        fillOutlineColor: '#0F5FBD',
      ),
    );
  }

  void _updateMarkers() {
    for (var site in _parkingSites) {
      String markerColor = "#3685E2";
      if (!site["has_realtime_data"]) {
        markerColor = "#3685E2";
      } else if (site["disabled_parking_available"]) {
        markerColor = "#089161";
      } else {
        markerColor = "#F4B1A4";
      }

      _mapController
          .addCircle(
            CircleOptions(
              geometry: site["coordinates"],
              circleColor: markerColor,
              circleRadius: 6.0,
              circleOpacity: 0.5,
              circleStrokeWidth: 1.0,
              circleStrokeColor: "#FFFFFF",
              circleStrokeOpacity: 0.5,
            ),
          )
          .then((symbol) {
            _symbolIdToSite[symbol.id] = site;
          });
    }
  }

  Future<void> _drawPlace() async {
    String iconName;
    if (!widget.parkingSite["has_realtime_data"]) {
      iconName = "parking_avbl_unknown.png";
    } else if (widget.parkingSite["disabled_parking_available"]) {
      iconName = "parking_avbl_yes.png";
    } else {
      iconName = "parking_avbl_no.png";
    }

    await _mapController.addSymbol(
      SymbolOptions(
        geometry: widget.parkingSite["coordinates"],
        iconImage: iconName,
        iconSize: 0.85,
      ),
    );
  }

  void _onCircleTapped(Circle circle) {
    final site = _symbolIdToSite[circle.id] ?? {};
    if (site.isNotEmpty) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ParkingLocationScreen(parkingLocation: site),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Consumer<ThemeController>(
          builder: (context, themeController, child) => MapLibreMap(
            annotationOrder: [
              AnnotationType.line,
              AnnotationType.fill,
              AnnotationType.circle,
              AnnotationType.symbol,
            ],
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
                widget.parkingSite['coordinates'].latitude - 0.003,
                widget.parkingSite['coordinates'].longitude,
              ),
              zoom: 13.5,
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
