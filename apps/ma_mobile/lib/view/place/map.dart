import 'dart:async';
import 'dart:math';
import 'dart:core';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:maplibre_gl/maplibre_gl.dart';
import 'package:smartroots/core/config.dart';
import 'package:smartroots/l10n/app_localizations.dart';
import 'package:smartroots/services/poi_parking.dart';
import 'package:smartroots/schemas/routing/place.dart';
import 'package:smartroots/view/parking_site/parking_site.dart';

class PlaceMap extends StatefulWidget {
  final Place place;
  final int radius;
  const PlaceMap({required this.place, required this.radius, super.key});

  @override
  State<StatefulWidget> createState() => _PlaceMapState();
}

class _PlaceMapState extends State<PlaceMap> {
  late MapLibreMapController _mapController;
  List<Map<String, dynamic>> _parkingSites = [];
  Map<String, Map<String, dynamic>> _symbolIdToSite = {};
  int? _lastRadius;

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

    final bytes4 = await rootBundle.load('assets/place.png');
    final list4 = bytes4.buffer.asUint8List();
    _mapController.addImage("place.png", list4);

    await _fetchMapLayers();

    // Add symbol tap listener
    _mapController.onSymbolTapped.add(_onSymbolTapped);
  }

  Future<void> _fetchMapLayers() async {
    // Clear existing layers
    _mapController.clearSymbols();
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
      List<Map<String, dynamic>> result = await parkingService
          .getParkingLocations(
            focusPointLat: widget.place.coordinates.lat,
            focusPointLon: widget.place.coordinates.lon,
            radius: widget.radius,
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

  void _onSymbolTapped(Symbol symbol) {
    final site = _symbolIdToSite[symbol.id] ?? {};
    if (site.isNotEmpty) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ParkingSiteScreen(parkingSite: site),
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
        MapLibreMap(
          annotationOrder: [AnnotationType.fill, AnnotationType.symbol],
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
              widget.place.coordinates.lat - 0.003,
              widget.place.coordinates.lon,
            ),
            zoom: 14,
          ),
          onStyleLoadedCallback: _onStyleLoaded,
          compassViewMargins: const Point(16, 160),
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
    for (var site in _parkingSites) {
      bool hasRealtimeData = site["has_realtime_data"];
      int? total = site["capacity_disabled"];
      int? occupied = site["occupied_disabled"];

      String iconName;
      if (!hasRealtimeData || total == null || occupied == null) {
        iconName = "parking_avbl_unknown.png";
      } else if (occupied < total) {
        iconName = "parking_avbl_yes.png";
      } else {
        iconName = "parking_avbl_no.png";
      }

      _mapController
          .addSymbol(
            SymbolOptions(
              geometry: site["coordinates"],
              iconImage: iconName,
              iconSize: 0.85,
            ),
          )
          .then((symbol) {
            _symbolIdToSite[symbol.id] = site;
          });
    }
  }
}
