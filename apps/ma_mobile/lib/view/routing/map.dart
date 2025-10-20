import 'dart:math';
import 'dart:core';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:geolocator/geolocator.dart';
import 'package:maplibre_gl/maplibre_gl.dart';
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

    _drawPlace();

    setState(() {
      _isMapInitialized = true;
    });
  }

  void _drawPlace() {
    bool hasRealtimeData = widget.parkingSite["has_realtime_data"];
    int? total = widget.parkingSite["capacity_disabled"];
    int? occupied = widget.parkingSite["occupied_disabled"];

    String iconName;
    if (!hasRealtimeData || total == null || occupied == null) {
      iconName = "parking_avbl_unknown.png";
    } else if (occupied < total) {
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
    if (!_isMapInitialized) {
      return;
    }

    // Clear existing lines
    _mapController.clearLines();

    if (widget.itineraryDetails == null) {
      return;
    }

    List<PointLatLng> polylinePoints = PolylinePoints.decodePolyline(
      widget.itineraryDetails!.legs.first.geometry,
    );

    _mapController.addLine(
      LineOptions(
        geometry: polylinePoints
            .map((p) => LatLng(p.latitude, p.longitude))
            .toList(),
        lineColor: "#0078D7",
        lineWidth: 4.5,
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

  void _drawStepActionPoints() {
    if (!_isMapInitialized) {
      return;
    }

    // Clear existing circles
    _mapController.clearCircles();

    // Ensure action points should be drawn
    if (!_isMapInitialized ||
        widget.itineraryDetails == null ||
        widget.navigationStatus != NavigationStatus.navigating) {
      return;
    }

    // Draw a circle for each step action point
    for (var step in widget.itineraryDetails!.legs.first.steps) {
      _mapController.addCircle(
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
  }

  @override
  Widget build(BuildContext context) {
    _drawJourney();
    _drawStepActionPoints();

    return Stack(
      children: [
        MapLibreMap(
          myLocationEnabled: true,
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
