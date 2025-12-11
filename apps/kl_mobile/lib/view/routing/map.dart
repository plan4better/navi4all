import 'dart:collection';
import 'dart:math';
import 'dart:core';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:geolocator/geolocator.dart';
import 'package:maplibre_gl/maplibre_gl.dart';
import 'package:maps_toolkit/maps_toolkit.dart' as maps_toolkit;
import 'package:navi4all/core/theme/colors.dart';
import 'package:navi4all/core/theme/profile_mode.dart';
import 'package:navi4all/core/theme/values.dart';
import 'package:provider/provider.dart';
import 'package:navi4all/controllers/routing_controller.dart';
import 'package:navi4all/controllers/theme_controller.dart';
import 'package:navi4all/core/config.dart';
import 'package:navi4all/core/processing_status.dart';
import 'package:navi4all/schemas/routing/place.dart';
import 'package:navi4all/schemas/routing/leg.dart' as leg_schema;
import 'package:navi4all/schemas/routing/mode.dart';

class RoutingMap extends StatefulWidget {
  final Place destination;
  const RoutingMap({super.key, required this.destination});

  @override
  State<StatefulWidget> createState() => _RoutingMapState();
}

class _RoutingMapState extends State<RoutingMap> {
  bool _canInteractWithMap = false;
  late RoutingController _routingController;
  late MapLibreMapController _mapController;
  late CurrentPositionController _currentPositionController;
  late ActionTrailController _actionTrailController;

  // Symbol cache
  Circle? _originCircle;
  Symbol? _destinationSymbol;
  final List<Line> _actionTrailLines = [];
  final List<Symbol> _stepActionSymbols = [];
  final List<Circle> _stepActionCircles = [];
  Symbol? _currentPositionSymbol;

  @override
  void initState() {
    super.initState();

    _routingController = Provider.of<RoutingController>(context, listen: false);
    _currentPositionController = Provider.of<CurrentPositionController>(
      context,
      listen: false,
    );
    _actionTrailController = Provider.of<ActionTrailController>(
      context,
      listen: false,
    );
  }

  Future<void> _onStyleLoaded() async {
    // Load custom marker icons
    String assetMarkerPlace =
        Provider.of<ThemeController>(context, listen: false).profileMode ==
            ProfileMode.visionImpaired
        ? Navi4AllValues.assetMarkerPlaceVisImp
        : Navi4AllValues.assetMarkerPlaceGeneral;
    final bytes3 = await rootBundle.load(assetMarkerPlace);
    final list3 = bytes3.buffer.asUint8List();
    _mapController.addImage("place.png", list3);

    final bytes4 = await rootBundle.load('assets/user_position.png');
    final list4 = bytes4.buffer.asUint8List();
    _mapController.addImage("user_position.png", list4);

    final bytes5 = await rootBundle.load('assets/marker_walking.png');
    final list5 = bytes5.buffer.asUint8List();
    _mapController.addImage("marker_walking.png", list5);

    final bytes6 = await rootBundle.load('assets/marker_bus.png');
    final list6 = bytes6.buffer.asUint8List();
    _mapController.addImage("marker_bus.png", list6);

    final bytes7 = await rootBundle.load('assets/marker_train.png');
    final list7 = bytes7.buffer.asUint8List();
    _mapController.addImage("marker_train.png", list7);

    final bytes8 = await rootBundle.load('assets/line_dotted.png');
    final list8 = bytes8.buffer.asUint8List();
    _mapController.addImage("line_dotted.png", list8);

    await Future.delayed(const Duration(milliseconds: 250));
    setState(() => _canInteractWithMap = true);

    // Draw destination
    _drawDestination();

    // Register listeners
    _routingController.addListener(_refocusCamera);
    _currentPositionController.addListener(_drawUserPosition);
    _actionTrailController.addListener(_drawActionTrail);
    _actionTrailController.addListener(_drawStepActionPoints);
    _actionTrailController.addListener(_drawOrigin);
  }

  Future<void> _drawOrigin() async {
    List<MapEntry<Mode, List<maps_toolkit.LatLng>>> actionTrailRendered =
        Provider.of<ActionTrailController>(
          context,
          listen: false,
        ).actionTrailRendered;

    if (actionTrailRendered.isNotEmpty) {
      String originColor =
          Theme.of(context).textTheme.displayMedium?.color!
              .toARGB32()
              .toRadixString(16)
              .substring(2) ??
          "000000";

      // Build origin marker
      CircleOptions circleOptions = CircleOptions(
        geometry: LatLng(
          actionTrailRendered.first.value.first.latitude,
          actionTrailRendered.first.value.first.longitude,
        ),
        circleRadius: 6.0,
        circleColor: "#$originColor",
        circleStrokeColor: "#FFFFFF",
        circleStrokeWidth: 2.0,
      );

      if (_originCircle != null) {
        // Update marker
        await _mapController.updateCircle(_originCircle!, circleOptions);
      } else {
        // Draw new marker
        _originCircle = await _mapController.addCircle(circleOptions);
      }
    } else {
      // Remove existing marker
      if (_originCircle != null) {
        await _mapController.removeCircle(_originCircle!);
        _originCircle = null;
      }
    }
  }

  Future<void> _drawDestination() async {
    // Clear existing destination marker
    if (_destinationSymbol != null) {
      await _mapController.removeSymbol(_destinationSymbol!);
    }

    String iconName = 'place.png';

    // Draw new destination marker
    _destinationSymbol = await _mapController.addSymbol(
      SymbolOptions(
        geometry: LatLng(
          widget.destination.coordinates.lat,
          widget.destination.coordinates.lon,
        ),
        iconImage: iconName,
        iconSize: 0.85,
      ),
    );
  }

  Future<void> _drawActionTrail() async {
    List<MapEntry<Mode, List<maps_toolkit.LatLng>>> actionTrailRendered =
        Provider.of<ActionTrailController>(
          context,
          listen: false,
        ).actionTrailRendered;

    // Remove existing lines
    if (_actionTrailLines.isNotEmpty) {
      await _mapController.removeLines(_actionTrailLines);
      _actionTrailLines.clear();
    }

    final color =
        (Theme.of(context).textTheme.bodyMedium?.color ?? Navi4AllColors.klPink)
            .toARGB32()
            .toRadixString(16)
            .substring(2);

    List<LineOptions> lineOptions = [];
    for (MapEntry<Mode, List<maps_toolkit.LatLng>> legModeCoordinates
        in actionTrailRendered) {
      List<LatLng> lineCoordinates = legModeCoordinates.value
          .map((point) => LatLng(point.latitude, point.longitude))
          .toList();

      // Build line segment for this leg
      lineOptions.add(
        LineOptions(
          geometry: lineCoordinates,
          lineColor: "#$color",
          lineWidth: 8.0,
          lineOpacity: 0.8,
          lineJoin: "round",
          linePattern: legModeCoordinates.key == Mode.WALK
              ? 'line_dotted.png'
              : null,
        ),
      );
    }

    _actionTrailLines.addAll(await _mapController.addLines(lineOptions));
  }

  Future<void> _drawStepActionPoints() async {
    LinkedHashMap<
      leg_schema.LegDetailed,
      LinkedHashMap<leg_schema.Step, List<maps_toolkit.LatLng>?>
    >?
    actionTrail = Provider.of<ActionTrailController>(
      context,
      listen: false,
    ).actionTrail;

    // Remove existing markers
    if (_stepActionSymbols.isNotEmpty) {
      await _mapController.removeSymbols(_stepActionSymbols);
      _stepActionSymbols.clear();
    }
    if (_stepActionCircles.isNotEmpty) {
      await _mapController.removeCircles(_stepActionCircles);
      _stepActionCircles.clear();
    }

    List<SymbolOptions> legMarkers = [];
    List<CircleOptions> stepMarkers = [];
    for (leg_schema.LegDetailed leg in actionTrail.keys) {
      // Leg action markers
      String? legActionSymbol;
      switch (leg.mode) {
        case Mode.WALK:
          legActionSymbol = "marker_walking.png";
          break;
        case Mode.BICYCLE:
        case Mode.CAR:
          legActionSymbol = null;
          break;
        case Mode.BUS:
          legActionSymbol = "marker_bus.png";
          break;
        case Mode.TRAM:
        case Mode.SUBWAY:
        case Mode.RAIL:
          legActionSymbol = "marker_train.png";
          break;
        default:
          break;
      }

      if (legActionSymbol != null) {
        double legOriginLat;
        double legOriginLon;

        if (actionTrail[leg]!.keys.isNotEmpty) {
          legOriginLat = actionTrail[leg]!.keys.first.lat;
          legOriginLon = actionTrail[leg]!.keys.first.lon;
        } else {
          List<maps_toolkit.LatLng> decodedLegPoints =
              maps_toolkit.PolygonUtil.decode(leg.geometry);
          legOriginLat = decodedLegPoints.first.latitude;
          legOriginLon = decodedLegPoints.first.longitude;
        }

        legMarkers.add(
          SymbolOptions(
            geometry: LatLng(legOriginLat, legOriginLon),
            iconImage: legActionSymbol,
            iconSize: 0.7,
          ),
        );
      }

      // Step action markers
      for (leg_schema.Step step in actionTrail[leg]!.keys) {
        // Skip first step
        if (step == actionTrail[leg]!.keys.first) {
          continue;
        }

        stepMarkers.add(
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

    _stepActionSymbols.addAll(await _mapController.addSymbols(legMarkers));
    _stepActionCircles.addAll(await _mapController.addCircles(stepMarkers));
  }

  Future<void> _drawUserPosition() async {
    CurrentPositionController currentPositionController =
        Provider.of<CurrentPositionController>(context, listen: false);
    Position? currentPosition = currentPositionController.currentPosition;
    bool isCurrentPositionSnapped =
        currentPositionController.isCurrentPositionSnapped;

    if (currentPosition != null && isCurrentPositionSnapped) {
      // Build user position marker
      SymbolOptions symbolOptions = SymbolOptions(
        geometry: LatLng(currentPosition.latitude, currentPosition.longitude),
        iconImage: "user_position.png",
        iconSize: 0.7,
      );

      if (_currentPositionSymbol != null) {
        // Update marker
        await _mapController.updateSymbol(
          _currentPositionSymbol!,
          symbolOptions,
        );
      } else {
        // Draw new marker
        _currentPositionSymbol = await _mapController.addSymbol(symbolOptions);
      }
    } else {
      // Remove existing marker
      if (_currentPositionSymbol != null) {
        await _mapController.removeSymbol(_currentPositionSymbol!);
        _currentPositionSymbol = null;
      }
    }
  }

  Future<void> _refocusCamera() async {
    NavigationStatus? navigationStatus = Provider.of<RoutingController>(
      context,
      listen: false,
    ).navigationStatus;
    List<MapEntry<Mode, List<maps_toolkit.LatLng>>> actionTrailRendered =
        Provider.of<ActionTrailController>(
          context,
          listen: false,
        ).actionTrailRendered;

    // Frame map and camera for route overview
    if (navigationStatus != NavigationStatus.navigating) {
      if (actionTrailRendered.isEmpty) {
        return;
      }

      double minLat = actionTrailRendered.first.value.first.latitude;
      double maxLat = actionTrailRendered.first.value.first.latitude;
      double minLng = actionTrailRendered.first.value.first.longitude;
      double maxLng = actionTrailRendered.first.value.first.longitude;
      for (MapEntry<Mode, List<maps_toolkit.LatLng>> actionTrailEntry
          in actionTrailRendered) {
        for (var point in actionTrailEntry.value) {
          if (point.latitude < minLat) minLat = point.latitude;
          if (point.latitude > maxLat) maxLat = point.latitude;
          if (point.longitude < minLng) minLng = point.longitude;
          if (point.longitude > maxLng) maxLng = point.longitude;
        }
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

      return;
    }

    // Frame map and camera for navigation
    Position? currentPosition = Provider.of<CurrentPositionController>(
      context,
      listen: false,
    ).currentPosition;
    if (currentPosition != null) {
      _mapController.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(
            target: LatLng(currentPosition.latitude, currentPosition.longitude),
            zoom: 17.0,
            bearing: currentPosition.heading,
          ),
        ),
        duration: const Duration(seconds: 2),
      );
    }
  }

  @override
  void dispose() {
    _routingController.removeListener(_refocusCamera);
    _currentPositionController.removeListener(_drawUserPosition);
    _actionTrailController.removeListener(_drawActionTrail);
    _actionTrailController.removeListener(_drawStepActionPoints);
    _actionTrailController.removeListener(_drawOrigin);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Consumer<ThemeController>(
          builder: (context, themeController, child) => ExcludeSemantics(
            child: Consumer<CurrentPositionController>(
              builder: (context, controller, _) => MapLibreMap(
                annotationOrder: [
                  AnnotationType.line,
                  AnnotationType.circle,
                  AnnotationType.symbol,
                ],
                myLocationEnabled: !controller.isCurrentPositionSnapped,
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
                    widget.destination.coordinates.lat - 0.002,
                    widget.destination.coordinates.lon,
                  ),
                  zoom: 14,
                ),
                onStyleLoadedCallback: _onStyleLoaded,
                compassViewMargins: const Point(16, 192),
                compassViewPosition: CompassViewPosition.topRight,
              ),
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
