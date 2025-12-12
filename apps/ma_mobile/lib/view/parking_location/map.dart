import 'dart:async';
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
import 'package:smartroots/schemas/routing/place.dart';
import 'package:smartroots/services/poi_parking.dart';
import 'package:smartroots/view/parking_location/parking_location.dart';

class ParkingSiteMap extends StatefulWidget {
  final Place parkingLocation;
  final bool showAlternatives;
  const ParkingSiteMap({
    required this.parkingLocation,
    required this.showAlternatives,
    super.key,
  });

  @override
  State<StatefulWidget> createState() => _ParkingSiteMapState();
}

class _ParkingSiteMapState extends State<ParkingSiteMap>
    with WidgetsBindingObserver {
  late MapLibreMapController _mapController;
  Timer? _refreshTimer;
  bool _canInteractWithMap = false;
  late Place _parkingLocation;
  List<Place> _parkingLocations = [];

  @override
  void initState() {
    super.initState();
    _parkingLocation = widget.parkingLocation;
    WidgetsBinding.instance.addObserver(this);
  }

  Future<void> _onStyleLoaded() async {
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

    await Future.delayed(const Duration(milliseconds: 250));
    setState(() => _canInteractWithMap = true);

    // Fetch and draw map layers
    _drawMapLayers();
  }

  Future<void> _drawMapLayers() async {
    // Fetch parking locations and draw markers
    await _refreshData();

    // Only continue if alternative parking locations are to be shown
    if (!widget.showAlternatives) {
      return;
    }

    // Draw radius circle
    _drawRadius();

    // Compute new camera zoom and position to fit radius
    double zoomLevel = 14.0 - log(Settings.defaultRadius / 450) / log(2);
    zoomLevel = zoomLevel.clamp(9.0, 16.0);
    _mapController.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(
          target: LatLng(
            _parkingLocation.coordinates.lat -
                (Settings.defaultRadius / 200000),
            _parkingLocation.coordinates.lon,
          ),
          zoom: zoomLevel,
        ),
      ),
      duration: const Duration(seconds: 2),
    );
  }

  Future<void> _refreshData() async {
    // Schedule periodic data refresh
    if (_refreshTimer == null || !_refreshTimer!.isActive) {
      _refreshTimer = Timer.periodic(
        Duration(seconds: Settings.dataRefreshIntervalSeconds),
        (_) => _refreshData(),
      );
    }

    if (!_canInteractWithMap) {
      return;
    }

    // Fetch and display primary parking location
    await _fetchPrimaryParkingLocation();

    if (!widget.showAlternatives) {
      return;
    }

    // Fetch and display alternative parking locations
    await _fetchAlternativeParkingLocations();

    // Add feature tap listener
    _mapController.onFeatureTapped.clear();
    _mapController.onFeatureTapped.add(_onFeatureTapped);
  }

  Future<void> _fetchPrimaryParkingLocation() async {
    POIParkingService parkingService = POIParkingService();
    try {
      Place? parkingLocation;
      parkingLocation = await parkingService.getParkingLocationDetails(
        placeId: _parkingLocation.id,
        placeType: _parkingLocation.type,
      );

      if (parkingLocation != null) {
        _parkingLocation = parkingLocation;
        _drawPlace();
      }
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

  Future<void> _fetchAlternativeParkingLocations() async {
    POIParkingService parkingService = POIParkingService();
    try {
      List<Place> parkingLocations;
      Map<String, dynamic> geoJson;
      (parkingLocations, geoJson) = await parkingService.getParkingLocations(
        focusPoint: _parkingLocation.coordinates,
        radius: Settings.defaultRadius,
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

  void _drawRadius() {
    // Draw a polygon (circle approximation) with given radius in meters
    final center = LatLng(
      _parkingLocation.coordinates.lat,
      _parkingLocation.coordinates.lon,
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
      // Skip if location is the selected parking location
      var coords = feature['geometry']['coordinates'];
      if (coords[1] == _parkingLocation.coordinates.lat &&
          coords[0] == _parkingLocation.coordinates.lon) {
        continue;
      }

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
        circleOpacity: 0.5,
        circleStrokeWidth: 1.0,
        circleStrokeColor: "#FFFFFF",
        circleStrokeOpacity: 0.5,
      ),
    );

    // Add layer for unclustered points - Occupied (Red)
    await _mapController.addLayer(
      'parking_occupied',
      'parking_occupied_layer',
      CircleLayerProperties(
        circleColor: '#F4B1A4',
        circleRadius: 6.0,
        circleOpacity: 0.5,
        circleStrokeWidth: 1.0,
        circleStrokeColor: "#FFFFFF",
        circleStrokeOpacity: 0.5,
      ),
    );

    // Add layer for unclustered points - Available (Green)
    await _mapController.addLayer(
      'parking_available',
      'parking_available_layer',
      CircleLayerProperties(
        circleColor: '#089161',
        circleRadius: 6.0,
        circleOpacity: 0.5,
        circleStrokeWidth: 1.0,
        circleStrokeColor: "#FFFFFF",
        circleStrokeOpacity: 0.5,
      ),
    );
  }

  Future<void> _drawPlace() async {
    await _mapController.clearSymbols();

    String iconName;
    if (!_parkingLocation.attributes?["has_realtime_data"]) {
      iconName = "parking_avbl_unknown.png";
    } else if (widget
        .parkingLocation
        .attributes?["disabled_parking_available"]) {
      iconName = "parking_avbl_yes.png";
    } else {
      iconName = "parking_avbl_no.png";
    }

    await _mapController.addSymbol(
      SymbolOptions(
        geometry: LatLng(
          _parkingLocation.coordinates.lat,
          _parkingLocation.coordinates.lon,
        ),
        iconImage: iconName,
        iconSize: 0.85,
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

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive) {
      // Cancel periodic data refresh
      _refreshTimer?.cancel();
    } else if (state == AppLifecycleState.resumed) {
      _refreshData();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _refreshTimer?.cancel();
    _mapController.onFeatureTapped.clear();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Consumer<ThemeController>(
          builder: (context, themeController, child) => Semantics(
            excludeSemantics: true,
            child: MapLibreMap(
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
                  _parkingLocation.coordinates.lat - 0.003,
                  _parkingLocation.coordinates.lon,
                ),
                zoom: 13.5,
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
}
