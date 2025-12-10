import 'dart:async';
import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:smartroots/core/processing_status.dart';
import 'package:smartroots/schemas/routing/itinerary.dart';
import 'package:smartroots/schemas/routing/leg.dart' as leg_schema;
import 'package:smartroots/schemas/routing/mode.dart';
import 'package:smartroots/schemas/routing/place.dart';
import 'package:maps_toolkit/maps_toolkit.dart' as maps_toolkit;

class RoutingController extends ChangeNotifier {
  // Constants
  static const double densificationThreshold = 2.0;

  // State tracking
  RoutingControllerState _state = RoutingControllerState.uninitialized;
  RoutingControllerState get state => _state;
  NavigationStatus _navigationStatus = NavigationStatus.idle;
  NavigationStatus get navigationStatus => _navigationStatus;
  AudioStatus _audioStatus = AudioStatus.unmuted;
  AudioStatus get audioStatus => _audioStatus;

  // Routing parameters
  Place? _origin;
  Place? get origin => _origin;
  Place? _destination;
  Place? get destination => _destination;
  ItineraryDetails? _itineraryDetails;
  ItineraryDetails? get itineraryDetails => _itineraryDetails;

  // Navigation tracking
  final LinkedHashMap<
    leg_schema.LegDetailed,
    LinkedHashMap<leg_schema.Step, List<maps_toolkit.LatLng>?>
  >
  _actionTrail = LinkedHashMap();
  LinkedHashMap<
    leg_schema.LegDetailed,
    LinkedHashMap<leg_schema.Step, List<maps_toolkit.LatLng>?>
  >
  get actionTrail => _actionTrail;
  StreamSubscription<Position>? _positionSubscription;
  leg_schema.LegDetailed? _activeLeg;
  leg_schema.LegDetailed? get activeLeg => _activeLeg;
  leg_schema.Step? _activeStep;
  leg_schema.Step? get activeStep => _activeStep;
  Position? _currentPosition;
  Position? get currentPosition => _currentPosition;
  bool _isCurrentPositionSnapped = false;
  bool get isCurrentPositionSnapped => _isCurrentPositionSnapped;

  void setParameters({
    required Place origin,
    required Place destination,
    required ItineraryDetails itineraryDetails,
  }) {
    _origin = origin;
    _destination = destination;
    _itineraryDetails = itineraryDetails;
    _buildActionTrail();
    _state = RoutingControllerState.initialized;
    notifyListeners();
  }

  void startNavigation() {
    _state = RoutingControllerState.navigating;
    _navigationStatus = NavigationStatus.navigating;
    _subscribeToLocationStream();
    notifyListeners();
  }

  void pauseNavigation() {
    _navigationStatus = NavigationStatus.paused;
    _unsubscribeFromLocationStream();
    notifyListeners();
  }

  void resumeNavigation() {
    _navigationStatus = NavigationStatus.navigating;
    _subscribeToLocationStream();
    notifyListeners();
  }

  void stopNavigation() {
    _reset();
    notifyListeners();
  }

  void muteAudio() {
    _audioStatus = AudioStatus.muted;
    notifyListeners();
  }

  void unmuteAudio() {
    _audioStatus = AudioStatus.unmuted;
    notifyListeners();
  }

  void _buildActionTrail() {
    // Iterate over legs in itinerary
    for (leg_schema.LegDetailed leg in _itineraryDetails!.legs) {
      // Fetch leg geometry
      List<maps_toolkit.LatLng> legCoordinates =
          maps_toolkit.PolygonUtil.decode(leg.geometry);

      // Densify leg geometry using interpolation
      List<maps_toolkit.LatLng> densifiedLegCoordinates = [];
      for (int i = 0; i < legCoordinates.length - 1; i++) {
        maps_toolkit.LatLng start = legCoordinates[i];
        maps_toolkit.LatLng end = legCoordinates[i + 1];
        densifiedLegCoordinates.add(start);
        num distance = maps_toolkit.SphericalUtil.computeDistanceBetween(
          start,
          end,
        );
        if (distance > densificationThreshold) {
          int numIntermediatePoints = (distance / densificationThreshold)
              .floor();
          for (int j = 1; j <= numIntermediatePoints; j++) {
            double fraction = j / (numIntermediatePoints + 1);
            maps_toolkit.LatLng intermediatePoint =
                maps_toolkit.SphericalUtil.interpolate(start, end, fraction);
            densifiedLegCoordinates.add(intermediatePoint);
          }
        }
      }
      legCoordinates = densifiedLegCoordinates;

      // Build step map for this leg
      final LinkedHashMap<leg_schema.Step, List<maps_toolkit.LatLng>?> stepMap =
          LinkedHashMap();
      for (int i = 0; i < leg.steps.length; i++) {
        leg_schema.Step step = leg.steps[i];

        // Clip densified leg coordinates to this step
        maps_toolkit.LatLng stepStart = maps_toolkit.LatLng(step.lat, step.lon);
        int stepStartIndex = maps_toolkit.PolygonUtil.locationIndexOnPath(
          stepStart,
          legCoordinates,
          true,
          tolerance: 2.0,
        );
        maps_toolkit.LatLng stepEnd = (i < leg.steps.length - 1)
            ? maps_toolkit.LatLng(leg.steps[i + 1].lat, leg.steps[i + 1].lon)
            : maps_toolkit.LatLng(
                legCoordinates.last.latitude,
                legCoordinates.last.longitude,
              );
        int stepEndIndex = maps_toolkit.PolygonUtil.locationIndexOnPath(
          stepEnd,
          legCoordinates,
          true,
          tolerance: 2.0,
        );

        // Validate indices
        if (stepStartIndex == -1 ||
            stepEndIndex == -1 ||
            stepEndIndex < stepStartIndex) {
          if (leg.mode != Mode.WALK &&
              leg.mode != Mode.BICYCLE &&
              leg.mode != Mode.SCOOTER &&
              leg.mode != Mode.CAR) {
            // For transit legs, allow missing geometry
            stepMap[step] = null;
            continue;
          }
          _flagError();
          return;
        }

        stepMap[step] = legCoordinates.sublist(
          stepStartIndex,
          stepEndIndex + 1,
        );
      }

      // Append arrival step to last leg
      if (leg == _itineraryDetails!.legs.last) {
        leg_schema.Step arrivalStep = leg_schema.Step(
          distance: 0.0,
          lat: legCoordinates.last.latitude,
          lon: legCoordinates.last.longitude,
          relativeDirection: RelativeDirection.ARRIVE,
          absoluteDirection: AbsoluteDirection.UNKNOWN,
          streetName: '',
          bogusName: true,
        );
        stepMap[arrivalStep] = [
          maps_toolkit.LatLng(
            legCoordinates.last.latitude,
            legCoordinates.last.longitude,
          ),
        ];
      }

      _actionTrail[leg] = stepMap;
    }
  }

  void _flagError() {
    _state = RoutingControllerState.error;
    _navigationStatus = NavigationStatus.idle;
    _unsubscribeFromLocationStream();
    notifyListeners();
  }

  void _reset() {
    // Reset state tracking
    _state = RoutingControllerState.uninitialized;
    _navigationStatus = NavigationStatus.idle;
    _audioStatus = AudioStatus.unmuted;

    // Reset routing parameters
    _origin = null;
    _destination = null;
    _itineraryDetails = null;

    // Reset navigation tracking
    _unsubscribeFromLocationStream();
    _actionTrail.clear();
    _activeLeg = null;
    _activeStep = null;
    _currentPosition = null;
    _isCurrentPositionSnapped = false;
  }

  void _subscribeToLocationStream() {
    _positionSubscription = Geolocator.getPositionStream().listen(
      _onLocationChanged,
    );
  }

  void _unsubscribeFromLocationStream() {
    _positionSubscription?.cancel();
    _positionSubscription = null;
  }

  void _onLocationChanged(Position position) {
    _currentPosition = position;

    // TODO: Handle arrival
    // TODO: Handle departure
    // TODO: Compute remaining time and distance
    // TODO: Handle rerouting
    // TODO: Handle transit legs

    // Update active leg and step
    for (leg_schema.LegDetailed leg in _actionTrail.keys) {
      if (leg.mode != Mode.WALK &&
          leg.mode != Mode.BICYCLE &&
          leg.mode != Mode.SCOOTER &&
          leg.mode != Mode.CAR) {
        // TODO: Handle transit legs differently
        // Especially since their geometry is not linked to a step
        continue;
      }

      // Ensure leg is post active leg
      if (_activeLeg != null &&
          leg != _activeLeg &&
          _actionTrail.keys.toList().indexOf(leg) <
              _actionTrail.keys.toList().indexOf(_activeLeg!)) {
        continue;
      }

      for (leg_schema.Step step in _actionTrail[leg]!.keys) {
        // Ensure step is post active step
        if (_activeStep != null &&
            step != _activeStep &&
            _actionTrail[leg]!.keys.toList().indexOf(step) <
                _actionTrail[leg]!.keys.toList().indexOf(_activeStep!)) {
          continue;
        }

        List<maps_toolkit.LatLng>? stepCoordinates = _actionTrail[leg]![step];
        if (stepCoordinates == null) {
          // TODO: Handle better
          _flagError();
          return;
        }

        int indexOnPath = maps_toolkit.PolygonUtil.locationIndexOnPath(
          maps_toolkit.LatLng(position.latitude, position.longitude),
          stepCoordinates,
          true,
          tolerance: 10.0,
        );
        if (indexOnPath > -1) {
          _activeLeg = leg;
          _activeStep = step;
          break;
        }
      }
    }

    // Perform snapping to step for non-transit legs
    _isCurrentPositionSnapped = false;
    if (_activeLeg != null &&
        (_activeLeg!.mode == Mode.WALK ||
            _activeLeg!.mode == Mode.BICYCLE ||
            _activeLeg!.mode == Mode.SCOOTER ||
            _activeLeg!.mode == Mode.CAR)) {
      Position? snappedPosition = _attemptSnapToStep(position);
      if (snappedPosition != null) {
        _isCurrentPositionSnapped = true;
        _currentPosition = snappedPosition;
      }
    }

    notifyListeners();
  }

  Position? _attemptSnapToStep(Position position) {
    List<maps_toolkit.LatLng> stepPoints =
        _actionTrail[_activeLeg!]![_activeStep!]!;

    // Fetch index of position on active step
    int positionIndex = maps_toolkit.PolygonUtil.locationIndexOnPath(
      maps_toolkit.LatLng(position.latitude, position.longitude),
      stepPoints,
      true,
      tolerance: 10,
    );

    if (positionIndex > -1 && positionIndex < stepPoints.length - 1) {
      maps_toolkit.LatLng snappedPoint = stepPoints[positionIndex];
      maps_toolkit.LatLng nextPoint = stepPoints[positionIndex + 1];

      // Compute bearing, then normalise between 0-360 degrees
      num bearing = maps_toolkit.SphericalUtil.computeHeading(
        snappedPoint,
        nextPoint,
      );
      bearing = (bearing + 360) % 360;

      return Position(
        latitude: snappedPoint.latitude,
        longitude: snappedPoint.longitude,
        timestamp: position.timestamp,
        accuracy: position.accuracy,
        altitude: position.altitude,
        altitudeAccuracy: position.altitudeAccuracy,
        heading: bearing.toDouble(),
        headingAccuracy: position.headingAccuracy,
        speed: position.speed,
        speedAccuracy: position.speedAccuracy,
      );
    }
    return null;
  }
}

enum RoutingControllerState { uninitialized, initialized, error, navigating }

enum RoutingActionStatus { upcoming, active, await, completed }

class CurrentPositionController extends ChangeNotifier {
  late RoutingController _routingController;

  NavigationStatus? _navigationStatus;

  Position? _currentPosition;
  Position? get currentPosition => _currentPosition;

  bool _isCurrentPositionSnapped = false;
  bool get isCurrentPositionSnapped => _isCurrentPositionSnapped;

  CurrentPositionController(RoutingController routingController) {
    _routingController = routingController;
    _routingController.addListener(_refreshCurrentPositionControllerState);
  }

  void _refreshCurrentPositionControllerState() {
    // Compare with cached state
    if (_navigationStatus == _routingController.navigationStatus &&
        _arePositionsEqual(
          _currentPosition,
          _routingController.currentPosition,
        ) &&
        _isCurrentPositionSnapped ==
            _routingController.isCurrentPositionSnapped) {
      return;
    }

    // Current position is only snapped during navigation
    if (_routingController.navigationStatus == NavigationStatus.navigating) {
      _currentPosition = _routingController.currentPosition;
      _isCurrentPositionSnapped = _routingController.isCurrentPositionSnapped;
      notifyListeners();
    } else {
      if (_navigationStatus != _routingController.navigationStatus) {
        _currentPosition = null;
        _isCurrentPositionSnapped = false;
        notifyListeners();
      }
    }

    _navigationStatus = _routingController.navigationStatus;
  }

  bool _arePositionsEqual(Position? position1, Position? position2) {
    if (position1 == null && position2 == null) {
      return true;
    }
    if (position1 == null || position2 == null) {
      return false;
    }
    return position1.latitude == position2.latitude &&
        position1.longitude == position2.longitude &&
        position1.heading == position2.heading;
  }

  @override
  void dispose() {
    _routingController.removeListener(_refreshCurrentPositionControllerState);
    super.dispose();
  }
}

class ActionTrailController extends ChangeNotifier {
  late RoutingController _routingController;

  final LinkedHashMap<
    leg_schema.LegDetailed,
    LinkedHashMap<leg_schema.Step, List<maps_toolkit.LatLng>?>
  >
  _actionTrail = LinkedHashMap();
  LinkedHashMap<
    leg_schema.LegDetailed,
    LinkedHashMap<leg_schema.Step, List<maps_toolkit.LatLng>?>
  >
  get actionTrail => _actionTrail;

  final List<MapEntry<Mode, List<maps_toolkit.LatLng>>> _actionTrailRendered =
      [];
  UnmodifiableListView<MapEntry<Mode, List<maps_toolkit.LatLng>>>
  get actionTrailRendered => UnmodifiableListView(_actionTrailRendered);

  ActionTrailController(RoutingController routingController) {
    _routingController = routingController;
    _routingController.addListener(_refreshActionTrailControllerState);
  }

  void _refreshActionTrailControllerState() {
    // Compare with cached state
    if (_areActionTrailsEqual(_actionTrail, _routingController.actionTrail)) {
      return;
    }
    _actionTrail.clear();
    _actionTrail.addAll(_routingController.actionTrail);

    // Build action trail for rendering
    _actionTrailRendered.clear();
    for (leg_schema.LegDetailed leg in _routingController.actionTrail.keys) {
      List<maps_toolkit.LatLng> legCoordinates = [];
      for (leg_schema.Step step in _routingController.actionTrail[leg]!.keys) {
        List<maps_toolkit.LatLng>? stepCoordinates =
            _routingController.actionTrail[leg]![step];
        if (stepCoordinates != null) {
          legCoordinates.addAll(stepCoordinates);
        }
      }
      _actionTrailRendered.add(MapEntry(leg.mode, legCoordinates));
    }

    notifyListeners();
  }

  bool _areActionTrailsEqual(
    LinkedHashMap<
      leg_schema.LegDetailed,
      LinkedHashMap<leg_schema.Step, List<maps_toolkit.LatLng>?>
    >
    trail1,
    LinkedHashMap<
      leg_schema.LegDetailed,
      LinkedHashMap<leg_schema.Step, List<maps_toolkit.LatLng>?>
    >
    trail2,
  ) {
    if (trail1.length != trail2.length) {
      return false;
    }
    for (leg_schema.LegDetailed leg in trail1.keys) {
      if (!trail2.containsKey(leg)) {
        return false;
      }
      LinkedHashMap<leg_schema.Step, List<maps_toolkit.LatLng>?> steps1 =
          trail1[leg]!;
      LinkedHashMap<leg_schema.Step, List<maps_toolkit.LatLng>?> steps2 =
          trail2[leg]!;
      if (steps1.length != steps2.length) {
        return false;
      }
      for (leg_schema.Step step in steps1.keys) {
        if (!steps2.containsKey(step)) {
          return false;
        }
      }
    }
    return true;
  }

  @override
  void dispose() {
    _routingController.removeListener(_refreshActionTrailControllerState);
    super.dispose();
  }
}

class NavigationStatsController extends ChangeNotifier {
  late RoutingController _routingController;

  int? _timeToArrival;
  int? get timeToArrival => _timeToArrival;
  double? _distanceToArrival;
  double? get distanceToArrival => _distanceToArrival;

  NavigationStatsController(RoutingController routingController) {
    _routingController = routingController;
    _routingController.addListener(_refreshNavigationStatsControllerState);
  }

  void _refreshNavigationStatsControllerState() {
    // Fetch action trail
    LinkedHashMap<
      leg_schema.LegDetailed,
      LinkedHashMap<leg_schema.Step, List<maps_toolkit.LatLng>?>
    >
    actionTrail = _routingController.actionTrail;
    if (actionTrail.isEmpty) {
      _timeToArrival = null;
      _distanceToArrival = null;
      notifyListeners();
      return;
    }

    // If current position is unavailable, use default stats
    if (_routingController.currentPosition == null) {
      _timeToArrival = _routingController.actionTrail.keys.fold(
        0,
        (sum, leg) => sum! + leg.duration,
      );
      _distanceToArrival = _routingController.actionTrail.keys.fold(
        0.0,
        (sum, leg) => sum! + leg.distance,
      );
      notifyListeners();
      return;
    }

    Position currentPosition = _routingController.currentPosition!;
    leg_schema.LegDetailed? activeLeg = _routingController.activeLeg;
    leg_schema.Step? activeStep = _routingController.activeStep;

    double totalRemainingDistance = 0.0; // in meters
    int totalRemainingTime = 0; // in seconds

    List<leg_schema.LegDetailed> legs = actionTrail.keys.toList();
    int activeLegIndex = activeLeg != null ? legs.indexOf(activeLeg) : 0;

    // Iterate through remaining legs starting from active leg
    for (int legIndex = activeLegIndex; legIndex < legs.length; legIndex++) {
      leg_schema.LegDetailed leg = legs[legIndex];
      LinkedHashMap<leg_schema.Step, List<maps_toolkit.LatLng>?> stepMap =
          actionTrail[leg]!;
      List<leg_schema.Step> steps = stepMap.keys.toList();

      // For the active leg, process steps starting from active step
      if (legIndex == activeLegIndex && activeStep != null) {
        int activeStepIndex = steps.indexOf(activeStep);

        for (
          int stepIndex = activeStepIndex;
          stepIndex < steps.length;
          stepIndex++
        ) {
          leg_schema.Step step = steps[stepIndex];
          List<maps_toolkit.LatLng>? stepGeometry = stepMap[step];

          // For the active step, calculate remaining distance from current position
          if (stepIndex == activeStepIndex) {
            if (stepGeometry != null && stepGeometry.isNotEmpty) {
              maps_toolkit.LatLng currentLatLng = maps_toolkit.LatLng(
                currentPosition.latitude,
                currentPosition.longitude,
              );

              // Find closest point on step geometry
              int closestIndex = maps_toolkit.PolygonUtil.locationIndexOnPath(
                currentLatLng,
                stepGeometry,
                true,
                tolerance: 50.0,
              );

              if (closestIndex >= 0 && closestIndex < stepGeometry.length - 1) {
                // Remaining distance for this step
                for (int i = closestIndex; i < stepGeometry.length - 1; i++) {
                  totalRemainingDistance +=
                      maps_toolkit.SphericalUtil.computeDistanceBetween(
                        stepGeometry[i],
                        stepGeometry[i + 1],
                      );
                }

                // Remaining time for this step
                double stepProgress = closestIndex / (stepGeometry.length - 1);
                totalRemainingTime +=
                    ((1 - stepProgress) *
                            step.distance /
                            leg.distance *
                            leg.duration)
                        .round();
              } else {
                // Unable to snap, use full step distance
                totalRemainingDistance += step.distance;
                totalRemainingTime +=
                    (step.distance / leg.distance * leg.duration).round();
              }
            }
          } else {
            // For subsequent steps in active leg, add full distance/time
            totalRemainingDistance += step.distance;
            totalRemainingTime += (step.distance / leg.distance * leg.duration)
                .round();
          }
        }
      } else {
        // For legs after the active leg, add full distance/time
        totalRemainingDistance += leg.distance;
        totalRemainingTime += leg.duration;
      }
    }

    _timeToArrival = totalRemainingTime;
    _distanceToArrival = totalRemainingDistance;

    notifyListeners();
  }

  @override
  void dispose() {
    _routingController.removeListener(_refreshNavigationStatsControllerState);
    super.dispose();
  }
}

class NavigationInstructionsController extends ChangeNotifier {
  late RoutingController _routingController;

  leg_schema.LegDetailed? _instructionLeg;
  leg_schema.LegDetailed? get instructionLeg => _instructionLeg;
  leg_schema.Step? _instructionStep;
  leg_schema.Step? get instructionStep => _instructionStep;

  final List<MapEntry<leg_schema.LegDetailed, List<leg_schema.Step>>>
  _upcomingInstructions = [];
  UnmodifiableListView<MapEntry<leg_schema.LegDetailed, List<leg_schema.Step>>>
  get upcomingInstructions => UnmodifiableListView(_upcomingInstructions);

  NavigationInstructionsController(RoutingController routingController) {
    _routingController = routingController;
    _routingController.addListener(
      _refreshNavigationInstructionsControllerState,
    );
  }

  void _refreshNavigationInstructionsControllerState() {
    // Fetch navigation state
    LinkedHashMap<
      leg_schema.LegDetailed,
      LinkedHashMap<leg_schema.Step, List<maps_toolkit.LatLng>?>
    >
    actionTrail = _routingController.actionTrail;
    leg_schema.LegDetailed? activeLeg = _routingController.activeLeg;
    leg_schema.Step? activeStep = _routingController.activeStep;

    // Clear instructions
    _instructionLeg = null;
    _instructionStep = null;
    _upcomingInstructions.clear();

    // Nothing more to do if navigation state is uninitialized
    if (actionTrail.isEmpty) {
      _instructionLeg = null;
      _instructionStep = null;
      notifyListeners();
      return;
    }

    // Build upcoming instructions
    // This frames the instructions in a distance-to-upcoming-action format
    List<leg_schema.LegDetailed> legs = actionTrail.keys.toList();
    int activeLegIndex = activeLeg != null ? legs.indexOf(activeLeg) : 0;
    for (int i = activeLegIndex; i < legs.length; i++) {
      leg_schema.LegDetailed leg = legs[i];

      List<leg_schema.Step> steps = actionTrail[leg]!.keys.toList();
      int activeStepIndex = 0;
      if (i == activeLegIndex && activeStep != null) {
        activeStepIndex = steps.indexOf(activeStep) + 1;
      }

      // Build new upcoming steps list using distance-to-step
      List<leg_schema.Step> upcomingSteps = [];
      for (int j = activeStepIndex; j < steps.length; j++) {
        double previousStepDistance = 0.0;
        if (j > 0) {
          previousStepDistance = steps[j - 1].distance;
        }

        upcomingSteps.add(steps[j].copyWith(distance: previousStepDistance));
      }

      _upcomingInstructions.add(MapEntry(leg, upcomingSteps));
    }

    // Set instruction leg and step
    _instructionLeg = upcomingInstructions.isNotEmpty
        ? upcomingInstructions.first.key
        : null;
    _instructionStep =
        upcomingInstructions.isNotEmpty &&
            upcomingInstructions.first.value.isNotEmpty
        ? upcomingInstructions.first.value.first
        : null;

    notifyListeners();
  }

  @override
  void dispose() {
    _routingController.removeListener(
      _refreshNavigationInstructionsControllerState,
    );
    super.dispose();
  }
}
