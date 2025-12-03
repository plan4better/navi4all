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
import 'package:smartroots/schemas/routing/place.dart';
import 'package:smartroots/view/parking_location/parking_location.dart';

class PlaceMap extends StatefulWidget {
  final Place place;
  final int radius;
  const PlaceMap({required this.place, required this.radius, super.key});

  @override
  State<StatefulWidget> createState() => _PlaceMapState();
}

class _PlaceMapState extends State<PlaceMap> {
  late MapLibreMapController _mapController;
  bool _canInteractWithMap = false;
  List<Place> _parkingLocations = [];
  final Map<String, Place> _featureIdToParkingLocation = {};
  int? _lastRadius;

  Future<void> _onStyleLoaded() async {
    // Clear existing markers and listeners
    await _mapController.clearCircles();
    _mapController.onCircleTapped.clear();

    // Fetch and draw map layers
    _fetchMapLayers().then((_) {
      // Add symbol tap listener
      _mapController.onCircleTapped.add(_onCircleTapped);
    });

    // Load custom marker icons
    final bytes4 = await rootBundle.load('assets/place.png');
    final list4 = bytes4.buffer.asUint8List();
    _mapController.addImage("place.png", list4);

    await Future.delayed(const Duration(milliseconds: 250));
    setState(() => _canInteractWithMap = true);
  }

  Future<void> _fetchMapLayers() async {
    // Clear existing layers
    _mapController.clearSymbols();
    _mapController.clearCircles();
    _mapController.clearFills();

    // Draw radius circle
    _lastRadius = widget.radius;
    _drawRadius();

    // Fetch parking sites and draw markers
    await _fetchParkingSites();

    // Draw place marker
    _drawPlace();

    // Compute new camera zoom and position to fit radius
    double zoomLevel = 14.0 - log(widget.radius / 400) / log(2);
    zoomLevel = zoomLevel.clamp(9.0, 16.0);
    _mapController.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(
          target: LatLng(
            widget.place.coordinates.lat - (widget.radius / 125000),
            widget.place.coordinates.lon,
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
      List<Place> result;
      (result, _) = await parkingService.getParkingLocations(
        focusPoint: widget.place.coordinates,
        radius: widget.radius,
      );

      setState(() {
        _parkingLocations = result;
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

  void _onCircleTapped(Circle circle) {
    final Place? parkingLocation = _featureIdToParkingLocation[circle.id];
    if (parkingLocation != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) =>
              ParkingLocationScreen(parkingLocation: parkingLocation),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_lastRadius != null && widget.radius != _lastRadius) {
      // Radius changed, update map
      _fetchMapLayers();
    }

    return Stack(
      children: [
        Consumer<ThemeController>(
          builder: (context, themeController, child) => MapLibreMap(
            annotationOrder: [
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
        /*SafeArea(
          child: Align(
            alignment: Alignment.bottomRight,
            child: Padding(
              padding: const EdgeInsets.only(right: 16, bottom: 128),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  FloatingActionButton(
                    onPressed: () {},
                    child: Icon(Icons.layers),
                  ),
                  SizedBox(height: 16),
                  FloatingActionButton(
                    onPressed: () {
                      _mapController.requestMyLocationLatLng().then((latLng) {
                        if (latLng != null) {
                          _mapController.animateCamera(
                            CameraUpdate.newCameraPosition(
                              CameraPosition(target: latLng, zoom: 14.0),
                            ),
                            duration: const Duration(seconds: 2),
                          );
                        }
                      });
                    },
                    child: Icon(Icons.my_location),
                  ),
                ],
              ),
            ),
          ),
        ),*/
      ],
    );
  }

  void _drawRadius() {
    // Draw a polygon (circle approximation) with given radius in meters
    final center = LatLng(
      widget.place.coordinates.lat,
      widget.place.coordinates.lon,
    );
    final int points = 60; // More points = smoother circle
    final double radiusInMeters = widget.radius.toDouble();
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
        fillOpacity: 0.25,
        fillOutlineColor: '#0F5FBD',
      ),
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
        iconSize: 1,
      ),
    );
  }

  void _updateMarkers() {
    for (Place parkingLocation in _parkingLocations) {
      String markerColor = "#3685E2";
      if (!parkingLocation.attributes?["has_realtime_data"]) {
        markerColor = "#3685E2";
      } else if (parkingLocation.attributes?["disabled_parking_available"]) {
        markerColor = "#089161";
      } else {
        markerColor = "#F4B1A4";
      }

      _mapController
          .addCircle(
            CircleOptions(
              geometry: LatLng(
                parkingLocation.coordinates.lat,
                parkingLocation.coordinates.lon,
              ),
              circleColor: markerColor,
              circleRadius: 6.0,
              circleStrokeWidth: 1.0,
              circleStrokeColor: "#FFFFFF",
            ),
          )
          .then((symbol) {
            _featureIdToParkingLocation[symbol.id] = parkingLocation;
          });
    }
  }
}
