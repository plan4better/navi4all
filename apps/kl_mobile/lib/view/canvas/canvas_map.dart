import 'dart:math';
import 'dart:core';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:maplibre_gl/maplibre_gl.dart';
import 'package:navi4all/controllers/canvas_controller.dart';
import 'package:navi4all/controllers/itinerary_controller.dart';
import 'package:navi4all/controllers/place_controller.dart';
import 'package:navi4all/core/theme/colors.dart';
import 'package:navi4all/core/theme/profile_mode.dart';
import 'package:navi4all/core/theme/values.dart';
import 'package:navi4all/schemas/routing/itinerary.dart';
import 'package:navi4all/schemas/routing/place.dart';
import 'package:provider/provider.dart';
import 'package:navi4all/controllers/theme_controller.dart';
import 'package:navi4all/core/config.dart';
import 'package:maps_toolkit/maps_toolkit.dart' as maps_toolkit;

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
    String assetMarkerPlace =
        Provider.of<ThemeController>(context, listen: false).profileMode ==
            ProfileMode.visionImpaired
        ? Navi4AllValues.assetMarkerPlaceVisImp
        : Navi4AllValues.assetMarkerPlaceGeneral;
    final bytes4 = await rootBundle.load(assetMarkerPlace);
    final list4 = bytes4.buffer.asUint8List();
    _mapController.addImage("place.png", list4);

    // Enable user interaction
    await Future.delayed(const Duration(milliseconds: 250));
    setState(() => _canInteractWithMap = true);

    // Draw map layers
    _drawLayers();

    // Redraw layers when canvas state changes
    Provider.of<CanvasController>(
      context,
      listen: false,
    ).addListener(_drawLayers);
  }

  Future<void> _drawLayers() async {
    if (!_canInteractWithMap) {
      return;
    }

    // Clear existing layers
    await _mapController.clearLines();
    await _mapController.clearCircles();
    await _mapController.clearSymbols();

    switch (Provider.of<CanvasController>(context, listen: false).state) {
      case CanvasControllerState.place:
        await _drawPlace();
        break;
      case CanvasControllerState.itinerary:
        await _drawItineraries();
        await _drawOrigin();
        await _drawDestination();
        Provider.of<ItineraryController>(
          context,
          listen: false,
        ).removeListener(_drawLayers);
        Provider.of<ItineraryController>(
          context,
          listen: false,
        ).addListener(_drawLayers);
        break;
      default:
        break;
    }
  }

  Future<void> _drawOrigin() async {
    Place place = Provider.of<ItineraryController>(
      context,
      listen: false,
    ).originPlace!;

    String originColor =
        Theme.of(context).textTheme.displayMedium?.color!
            .toARGB32()
            .toRadixString(16)
            .substring(2) ??
        "000000";

    await _mapController.addCircle(
      CircleOptions(
        geometry: LatLng(place.coordinates.lat, place.coordinates.lon),
        circleRadius: 6.0,
        circleColor: "#$originColor",
        circleStrokeColor: "#FFFFFF",
        circleStrokeWidth: 2.0,
      ),
    );
  }

  Future<void> _drawDestination() async {
    Place place = Provider.of<ItineraryController>(
      context,
      listen: false,
    ).destinationPlace!;

    await _mapController.addSymbol(
      SymbolOptions(
        geometry: LatLng(place.coordinates.lat, place.coordinates.lon),
        iconImage: "place.png",
        iconSize: 0.9,
      ),
    );
  }

  Future<void> _drawPlace() async {
    Place place = Provider.of<PlaceController>(context, listen: false).place!;

    await _mapController.addSymbol(
      SymbolOptions(
        geometry: LatLng(place.coordinates.lat, place.coordinates.lon),
        iconImage: "place.png",
        iconSize: 0.9,
      ),
    );

    await _mapController.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(
          target: LatLng(place.coordinates.lat - 0.003, place.coordinates.lon),
          zoom: 14,
        ),
      ),
      duration: const Duration(seconds: 2),
    );
  }

  Future<void> _drawItineraries() async {
    List<ItinerarySummary> itineraries = Provider.of<ItineraryController>(
      context,
      listen: false,
    ).itineraries;

    // Collect all polyline points to compute bounding box later
    List<maps_toolkit.LatLng> polylinePoints = [];

    for (var itinerary in itineraries.reversed) {
      for (var leg in itinerary.legs) {
        List<maps_toolkit.LatLng> decodedPoints =
            maps_toolkit.PolygonUtil.decode(leg.geometry);
        polylinePoints.addAll(decodedPoints);

        // Draw line for each itinerary option with the first highlighted
        final color =
            (itineraries.first == itinerary
                    ? Theme.of(context).textTheme.bodyMedium?.color ??
                          Navi4AllColors.klPink
                    : Navi4AllColors.klPink)
                .toARGB32()
                .toRadixString(16)
                .substring(2);
        _mapController.addLine(
          LineOptions(
            geometry: decodedPoints
                .map((p) => LatLng(p.latitude, p.longitude))
                .toList(),
            lineColor: '#$color',
            lineWidth: 5.0,
            lineOpacity: 0.8,
            lineJoin: "round",
          ),
        );
      }
    }

    if (polylinePoints.isEmpty) {
      return;
    }

    // Compute bounding box
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
        left: 32,
        top: 208,
        right: 32,
        bottom: 336,
      ),
      duration: const Duration(seconds: 2),
    );
  }

  @override
  void dispose() {
    // TODO: Does not work, fix this
    Provider.of<CanvasController>(
      context,
      listen: false,
    ).removeListener(_drawLayers);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Consumer<ThemeController>(
          builder: (context, themeController, child) => MapLibreMap(
            annotationOrder: [
              AnnotationType.line,
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
