import 'dart:math';
import 'dart:core';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:geolocator/geolocator.dart';
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
  int? _lastRadius;

  Future<void> _onStyleLoaded() async {
    // Clear existing markers and listeners
    await _mapController.clearCircles();
    _mapController.onCircleTapped.clear();

    // Fetch and draw map layers
    _fetchMapLayers().then((_) {
      // Add feature tap listener
      _mapController.onFeatureTapped.add(_onFeatureTapped);
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
      List<Place> parkingLocations;
      Map<String, dynamic> geoJson;
      (parkingLocations, geoJson) = await parkingService.getParkingLocations(
        focusPoint: widget.place.coordinates,
        radius: widget.radius,
      );
      setState(() {
        _parkingLocations = parkingLocations;
      });
      _updateMarkers(geoJson);
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

  @override
  Widget build(BuildContext context) {
    if (_lastRadius != null && widget.radius != _lastRadius) {
      // Radius changed, update map
      _fetchMapLayers();
    }

    return Stack(
      children: [
        Consumer<ThemeController>(
          builder: (context, themeController, child) => Semantics(
            excludeSemantics: true,
            child: MapLibreMap(
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
        ),
        // Fill screen with background while map is loading
        !_canInteractWithMap
            ? Container(color: Theme.of(context).colorScheme.surface)
            : SizedBox.shrink(),
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

  void _updateMarkers(Map<String, dynamic> geoJson) async {
    // Remove existing parking layers and sources
    for (String layerId in (await _mapController.getLayerIds())) {
      if (layerId.startsWith('parking_')) {
        await _mapController.removeLayer(layerId);
      }
    }
    for (String sourceId in (await _mapController.getSourceIds())) {
      if (sourceId.startsWith('parking_')) {
        await _mapController.removeSource(sourceId);
      }
    }

    // Separate features by availability status
    List<Map<String, dynamic>> unknownFeatures = [];
    List<Map<String, dynamic>> occupiedFeatures = [];
    List<Map<String, dynamic>> availableFeatures = [];

    for (var feature in geoJson['features']) {
      var properties = feature['properties'];
      if (properties['disabled_parking_available'] == true) {
        availableFeatures.add(feature);
      } else if (properties['has_realtime_data'] == true) {
        occupiedFeatures.add(feature);
      } else {
        unknownFeatures.add(feature);
      }
    }

    // Create separate GeoJSON for each group
    Map<String, dynamic> unknownGeoJson = {
      'type': 'FeatureCollection',
      'features': unknownFeatures,
    };
    Map<String, dynamic> occupiedGeoJson = {
      'type': 'FeatureCollection',
      'features': occupiedFeatures,
    };
    Map<String, dynamic> availableGeoJson = {
      'type': 'FeatureCollection',
      'features': availableFeatures,
    };

    // Add sources for each availability group
    await _mapController.addSource(
      'parking_unknown',
      GeojsonSourceProperties(data: unknownGeoJson),
    );

    await _mapController.addSource(
      'parking_occupied',
      GeojsonSourceProperties(data: occupiedGeoJson),
    );

    await _mapController.addSource(
      'parking_available',
      GeojsonSourceProperties(data: availableGeoJson),
    );

    // Add layer for unclustered points - Unknown (Blue)
    await _mapController.addLayer(
      'parking_unknown',
      'parking_unknown_layer',
      CircleLayerProperties(
        circleColor: '#3685E2',
        circleRadius: 6.0,
        circleStrokeWidth: 1.0,
        circleStrokeColor: '#FFFFFF',
      ),
    );

    // Add layer for unclustered points - Occupied (Red)
    await _mapController.addLayer(
      'parking_occupied',
      'parking_occupied_layer',
      CircleLayerProperties(
        circleColor: '#F4B1A4',
        circleRadius: 6.0,
        circleStrokeWidth: 1.0,
        circleStrokeColor: '#FFFFFF',
      ),
    );

    // Add layer for unclustered points - Available (Green)
    await _mapController.addLayer(
      'parking_available',
      'parking_available_layer',
      CircleLayerProperties(
        circleColor: '#089161',
        circleRadius: 6.0,
        circleStrokeWidth: 1.0,
        circleStrokeColor: '#FFFFFF',
      ),
    );
  }

  void _onFeatureTapped(
    Point<double> point,
    LatLng coordinates,
    String id,
    String layerId,
    Annotation? annotation,
  ) {
    // Fetch selected place by feature ID, sorted by distance
    // This is necessary as feature IDs may not be unique
    Place? selectedPlace;
    List<Place> orderedParkingLocations = _parkingLocations.where((location) {
      return location.id == id;
    }).toList();
    orderedParkingLocations.sort((a, b) {
      double distanceA = Geolocator.distanceBetween(
        coordinates.latitude,
        coordinates.longitude,
        a.coordinates.lat,
        a.coordinates.lon,
      );
      double distanceB = Geolocator.distanceBetween(
        coordinates.latitude,
        coordinates.longitude,
        b.coordinates.lat,
        b.coordinates.lon,
      );
      return distanceA.compareTo(distanceB);
    });
    selectedPlace = orderedParkingLocations.isNotEmpty
        ? orderedParkingLocations.first
        : null;

    if (selectedPlace != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) =>
              ParkingLocationScreen(parkingLocation: selectedPlace!),
        ),
      );
    }
  }
}
