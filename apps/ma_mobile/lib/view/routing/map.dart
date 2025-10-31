import 'dart:math';
import 'dart:core';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:geolocator/geolocator.dart';
import 'package:maplibre_gl/maplibre_gl.dart';
import 'package:maps_toolkit/maps_toolkit.dart' as maps_toolkit;
import 'package:provider/provider.dart';
import 'package:smartroots/controllers/theme_controller.dart';
import 'package:smartroots/core/config.dart';
import 'package:smartroots/core/processing_status.dart';
import 'package:smartroots/schemas/routing/itinerary.dart';
import 'package:smartroots/schemas/routing/place.dart';

class RoutingMap extends StatefulWidget {
  final Place origin;
  final Map<String, dynamic> parkingSite;
  final ItineraryDetails? itineraryDetails;
  final NavigationStatus navigationStatus;
  final Position? userPosition;
  const RoutingMap({
    required this.origin,
    required this.parkingSite,
    required this.itineraryDetails,
    required this.navigationStatus,
    required this.userPosition,
    super.key,
  });

  @override
  State<StatefulWidget> createState() => _RoutingMapState();
}

class _RoutingMapState extends State<RoutingMap> {
  bool _canInteractWithMap = false;
  late MapLibreMapController _mapController;
  List<maps_toolkit.LatLng> _legPoints = [];
  int? _snappedPointIndex;

  Future<void> _onStyleLoaded() async {
    // Clear existing markers and listeners
    await _mapController.clearLines();
    await _mapController.clearCircles();
    await _mapController.clearSymbols();
    _mapController.onLineTapped.clear();
    _mapController.onCircleTapped.clear();
    _mapController.onSymbolTapped.clear();

    // Load custom marker icons
    final bytes = await rootBundle.load('assets/parking_avbl_yes.png');
    final list = bytes.buffer.asUint8List();
    _mapController.addImage("parking_avbl_yes.png", list);

    final bytes2 = await rootBundle.load('assets/parking_avbl_no.png');
    final list2 = bytes2.buffer.asUint8List();
    _mapController.addImage("parking_avbl_no.png", list2);

    final bytes3 = await rootBundle.load('assets/parking_avbl_unknown.png');
    final list3 = bytes3.buffer.asUint8List();
    _mapController.addImage("parking_avbl_unknown.png", list3);

    final bytes4 = await rootBundle.load('assets/user_position.png');
    final list4 = bytes4.buffer.asUint8List();
    _mapController.addImage("user_position.png", list4);

    await Future.delayed(const Duration(milliseconds: 250));
    setState(() => _canInteractWithMap = true);
  }

  Future<void> _drawLayers() async {
    if (!_canInteractWithMap) {
      return;
    }

    // Clear existing layers
    await _mapController.clearLines();
    await _mapController.clearCircles();
    await _mapController.clearSymbols();

    // Draw parking location marker
    _drawPlace();

    // Ensure an itinerary is available
    if (widget.itineraryDetails == null ||
        widget.itineraryDetails!.legs.isEmpty) {
      return;
    }

    // Process leg geometry
    if (widget.navigationStatus == NavigationStatus.idle ||
        _legPoints.isEmpty) {
      _processPolyline();
    }

    // Draw journey polyline
    await _drawJourney();

    // Draw origin point
    await _drawOrigin();

    // Draw step action points
    if (widget.navigationStatus == NavigationStatus.navigating) {
      await _drawStepActionPoints();
    }

    // Draw user position
    if (widget.navigationStatus == NavigationStatus.navigating &&
        widget.userPosition != null) {
      await _drawUserPosition();
    }
  }

  void _processPolyline() {
    // Decode leg geometry points
    _legPoints = maps_toolkit.PolygonUtil.decode(
      widget.itineraryDetails!.legs.first.geometry,
    );

    // Densify polyline using interpolation
    List<maps_toolkit.LatLng> densifiedPoints = [];
    for (int i = 0; i < _legPoints.length - 1; i++) {
      maps_toolkit.LatLng start = _legPoints[i];
      maps_toolkit.LatLng end = _legPoints[i + 1];
      densifiedPoints.add(start);
      num distance = maps_toolkit.SphericalUtil.computeDistanceBetween(
        start,
        end,
      );
      if (distance > 5) {
        int numIntermediatePoints = (distance / 5).floor();
        for (int j = 1; j <= numIntermediatePoints; j++) {
          double fraction = j / (numIntermediatePoints + 1);
          maps_toolkit.LatLng intermediatePoint =
              maps_toolkit.SphericalUtil.interpolate(start, end, fraction);
          densifiedPoints.add(intermediatePoint);
        }
      }
    }
    _legPoints = densifiedPoints;
  }

  Future<void> _drawOrigin() async {
    await _mapController.addCircle(
      CircleOptions(
        geometry: LatLng(_legPoints.first.latitude, _legPoints.first.longitude),
        circleRadius: 6.0,
        circleColor: "#3685E2",
        circleStrokeColor: "#FFFFFF",
        circleStrokeWidth: 2.0,
      ),
    );
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

    _mapController.addSymbol(
      SymbolOptions(
        geometry: widget.parkingSite["coordinates"],
        iconImage: iconName,
        iconSize: 0.85,
      ),
    );
  }

  Future<void> _drawJourney() async {
    List<LatLng> polylinePoints = _snappedPointIndex != null
        ? _legPoints
              .sublist(_snappedPointIndex!)
              .map((p) => LatLng(p.latitude, p.longitude))
              .toList()
        : _legPoints.map((p) => LatLng(p.latitude, p.longitude)).toList();
    _mapController.addLine(
      LineOptions(
        geometry: polylinePoints,
        lineColor: "#0078D7",
        lineWidth: widget.navigationStatus == NavigationStatus.navigating
            ? 8.0
            : 5.0,
        lineOpacity: 0.8,
        lineJoin: "round",
      ),
    );

    // Adjust camera to fit the polyline
    if (widget.navigationStatus != NavigationStatus.navigating) {
      if (polylinePoints.isNotEmpty) {
        double minLat = polylinePoints.first.latitude;
        double maxLat = polylinePoints.first.latitude;
        double minLng = polylinePoints.first.longitude;
        double maxLng = polylinePoints.first.longitude;
        for (var point in polylinePoints) {
          if (point.latitude < minLat) minLat = point.latitude;
          if (point.latitude > maxLat) maxLat = point.latitude;
          if (point.longitude < minLng) minLng = point.longitude;
          if (point.longitude > maxLng) maxLng = point.longitude;
        }

        _mapController.animateCamera(
          CameraUpdate.newLatLngBounds(
            LatLngBounds(
              southwest: LatLng(minLat, minLng),
              northeast: LatLng(maxLat, maxLng),
            ),
            left: 48,
            top: 240,
            right: 48,
            bottom: 336,
          ),
          duration: const Duration(seconds: 2),
        );
      }
    } else {
      if (widget.userPosition == null) {
        return;
      }

      // Focus on the user's current location during navigation
      _mapController.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(
            target: LatLng(
              widget.userPosition!.latitude - 0.0001,
              widget.userPosition!.longitude,
            ),
            zoom: 17.0,
          ),
        ),
        duration: const Duration(seconds: 2),
      );
    }
  }

  Future<void> _drawStepActionPoints() async {
    // Draw a circle for each step action point
    List<CircleOptions> circles = [];
    for (var step in widget.itineraryDetails!.legs.first.steps) {
      circles.add(
        CircleOptions(
          geometry: LatLng(step.lat, step.lon),
          circleRadius: 2.0,
          circleColor: "#FFFFFF",
          circleStrokeColor: "#000000",
          circleStrokeWidth: 1.0,
          circleStrokeOpacity: 0.8,
        ),
      );
    }
    await _mapController.addCircles(circles);
  }

  Future<void> _drawUserPosition() async {
    // Attempt to snap user position to leg path
    int positionIndex = maps_toolkit.PolygonUtil.locationIndexOnPath(
      maps_toolkit.LatLng(
        widget.userPosition!.latitude,
        widget.userPosition!.longitude,
      ),
      _legPoints,
      true,
      tolerance: 10,
    );

    // If snapping was possible, compute bearing and adjust map view
    if (positionIndex > -1 && positionIndex < _legPoints.length - 1) {
      if (_snappedPointIndex != positionIndex) {
        setState(() {
          _snappedPointIndex = positionIndex;
        });
      }

      maps_toolkit.LatLng snappedPoint = _legPoints[positionIndex];
      maps_toolkit.LatLng nextPoint = _legPoints[positionIndex + 1];

      num bearing = maps_toolkit.SphericalUtil.computeHeading(
        snappedPoint,
        nextPoint,
      );

      // Adjust camera to focus on user position with bearing
      _mapController.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(
            target: LatLng(snappedPoint.latitude, snappedPoint.longitude),
            zoom: 17.0,
            bearing: bearing.toDouble(),
          ),
        ),
        duration: const Duration(seconds: 2),
      );

      // Draw user position marker
      double latitude = _legPoints[positionIndex].latitude;
      double longitude = _legPoints[positionIndex].longitude;
      await _mapController.addSymbol(
        SymbolOptions(
          geometry: LatLng(latitude, longitude),
          iconImage: "user_position.png",
          iconSize: 0.7,
        ),
      );
    } else {
      if (_snappedPointIndex != null) {
        setState(() {
          _snappedPointIndex = null;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    _drawLayers();

    return Stack(
      children: [
        Consumer<ThemeController>(
          builder: (context, themeController, child) => MapLibreMap(
            annotationOrder: [
              AnnotationType.line,
              AnnotationType.circle,
              AnnotationType.symbol,
            ],
            myLocationEnabled:
                _snappedPointIndex == null ||
                widget.navigationStatus != NavigationStatus.navigating,
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
                widget.parkingSite['coordinates'].latitude - 0.002,
                widget.parkingSite['coordinates'].longitude,
              ),
              zoom: 14,
            ),
            onStyleLoadedCallback: _onStyleLoaded,
            compassViewMargins: const Point(16, 192),
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
}
