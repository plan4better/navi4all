import 'dart:math';
import 'dart:core';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:geolocator/geolocator.dart';
import 'package:maplibre_gl/maplibre_gl.dart';
import 'package:maps_toolkit/maps_toolkit.dart' as maps_toolkit;
import 'package:smartroots/core/config.dart';
import 'package:smartroots/core/persistence/processing_status.dart';
import 'package:smartroots/schemas/routing/itinerary.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
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
  bool _isMapInitialized = false;
  late MapLibreMapController _mapController;
  // All points of leg geometry
  List<maps_toolkit.LatLng> _legPoints = [];
  int? _snappedPointIndex;
  Symbol? _userPositionSymbol;

  Future<void> _onStyleLoaded() async {
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

    _drawPlace();

    setState(() {
      _isMapInitialized = true;
    });
  }

  void _drawPlace() {
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

  Future<void> _drawLayers() async {
    if (!_isMapInitialized) {
      return;
    }

    // Clear existing layers
    _mapController.clearLines();
    _mapController.clearCircles();
    if (_userPositionSymbol != null) {
      _mapController.removeSymbol(_userPositionSymbol!);
      _userPositionSymbol = null;
    }

    // Ensure an itinerary is available
    if (widget.itineraryDetails == null ||
        widget.itineraryDetails!.legs.isEmpty) {
      return;
    }

    // Decode leg geometry points
    _legPoints = maps_toolkit.PolygonUtil.decode(
      widget.itineraryDetails!.legs.first.geometry,
    );

    // Draw journey polyline
    await _drawJourney();

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
            zoom: 18.0,
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
            zoom: 18.0,
            bearing: bearing.toDouble(),
          ),
        ),
        duration: const Duration(seconds: 2),
      );

      // Draw user position marker
      double latitude = _legPoints[positionIndex].latitude;
      double longitude = _legPoints[positionIndex].longitude;
      _userPositionSymbol = await _mapController.addSymbol(
        SymbolOptions(
          geometry: LatLng(latitude, longitude),
          iconImage: "user_position.png",
          iconSize: 0.75,
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
        MapLibreMap(
          annotationOrder: [
            AnnotationType.line,
            AnnotationType.circle,
            AnnotationType.symbol,
          ],
          myLocationEnabled:
              _snappedPointIndex == null ||
              widget.navigationStatus != NavigationStatus.navigating,
          styleString: Settings.mapStyleUrl,
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
