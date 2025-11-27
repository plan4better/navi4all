import 'dart:async';

import 'package:flutter/material.dart';
// import 'package:matomo_tracker/matomo_tracker.dart';
// import 'package:navi4all/core/analytics/events.dart';
import 'package:navi4all/core/theme/colors.dart';
import 'package:navi4all/core/theme/values.dart';
import 'package:navi4all/l10n/app_localizations.dart';
import 'package:navi4all/schemas/routing/coordinates.dart';
import 'package:navi4all/view/common/accessible_icon_button.dart';
import 'package:navi4all/view/common/sheet_button.dart';
import 'package:navi4all/schemas/routing/itinerary.dart';
import 'package:navi4all/core/processing_status.dart';
import 'package:navi4all/services/routing.dart';
import 'package:geolocator/geolocator.dart';
import 'package:navi4all/schemas/routing/leg.dart' as leg_schema;
import 'package:navi4all/schemas/routing/mode.dart';
import 'package:navi4all/schemas/routing/place.dart';
import 'package:navi4all/core/utils.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:maps_toolkit/maps_toolkit.dart';
import 'package:navi4all/core/theme/icons.dart';

class RoutingScreen extends StatefulWidget {
  final Place originPlace;
  final Place destinationPlace;
  final ItinerarySummary itinerarySummary;

  const RoutingScreen({
    required this.originPlace,
    required this.destinationPlace,
    required this.itinerarySummary,
    super.key,
  });

  @override
  RoutingState createState() => RoutingState();
}

class RoutingState extends State<RoutingScreen> {
  bool disclaimerAccepted = false;
  final FlutterTts flutterTts = FlutterTts();
  late Place _origin;
  late Place _destination;
  ItineraryDetails? _itineraryDetails;
  ProcessingStatus _processingStatus = ProcessingStatus.idle;
  NavigationStatus _navigationStatus = NavigationStatus.idle;
  AudioStatus _audioStatus = AudioStatus.unmuted;
  Stream<Position>? _positionStream;
  StreamSubscription<Position>? _positionStreamSubscription;
  Position? _userPosition;
  leg_schema.Step? _activeStep;

  @override
  void initState() {
    super.initState();

    // flutterTts.setLanguage(AppLocalizations.of(context)!.localeName);

    // Initialise origin and destination places
    _origin = widget.originPlace;
    _destination = widget.destinationPlace;

    // Fetch itineraries
    _fetchItineraries();
  }

  void _showDisclaimerDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Theme.of(context).colorScheme.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(32),
          ),
          child: Container(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Align(
                  alignment: Alignment.topLeft,
                  child: Text(
                    AppLocalizations.of(context)!.routingDisclaimerTitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
                SizedBox(height: 16),
                Flexible(
                  child: SingleChildScrollView(
                    child: Text(
                      AppLocalizations.of(context)!.routingDisclaimerMessage,
                      style: TextStyle(fontSize: 14),
                    ),
                  ),
                ),
                SizedBox(height: 32),
                Row(
                  children: [
                    Expanded(
                      child: SheetButton(
                        label: AppLocalizations.of(
                          context,
                        )!.routingDisclaimerCancelButton,
                        onTap: () {
                          disclaimerAccepted = false;
                          Navigator.of(context).pop();
                          Navigator.of(context).pop();

                          // Analytics event
                          /* MatomoTracker.instance.trackEvent(
                            eventInfo: EventInfo(
                              category: EventCategory.routingScreen.toString(),
                              action: EventAction
                                  .routingScreenDisclaimerRejected
                                  .toString(),
                            ),
                          ); */
                        },
                      ),
                    ),
                    SizedBox(width: 8),
                    Expanded(
                      child: SheetButton(
                        label: AppLocalizations.of(
                          context,
                        )!.routingDisclaimerAcceptButton,
                        onTap: () {
                          disclaimerAccepted = true;
                          Navigator.of(context).pop();

                          // Analytics event
                          /* MatomoTracker.instance.trackEvent(
                            eventInfo: EventInfo(
                              category: EventCategory.routingScreen.toString(),
                              action: EventAction
                                  .routingScreenDisclaimerAccepted
                                  .toString(),
                            ),
                          ); */
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<Position?> _getUserLocation() async {
    // Check location permission status
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      // User will need to enable permissions from app settings
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            AppLocalizations.of(context)!.userLocationDeniedSnackbarText,
          ),
        ),
      );
      return null;
    }

    // Fetch user location
    return await Geolocator.getCurrentPosition();
  }

  Future<void> _fetchItineraries() async {
    setState(() {
      _processingStatus = ProcessingStatus.processing;
      _itineraryDetails = null;
    });

    if (_origin.id == Navi4AllValues.userLocation ||
        _destination.id == Navi4AllValues.userLocation) {
      final userLocation = await _getUserLocation();
      if (userLocation == null) {
        setState(() {
          _processingStatus = ProcessingStatus.error;
        });
        return;
      }

      if (_origin.id == Navi4AllValues.userLocation) {
        _origin = Place(
          id: Navi4AllValues.userLocation,
          name: '',
          type: PlaceType.address,
          description: '',
          address: '',
          coordinates: Coordinates(
            lat: userLocation.latitude,
            lon: userLocation.longitude,
          ),
        );
      }

      if (_destination.id == Navi4AllValues.userLocation) {
        _destination = Place(
          id: Navi4AllValues.userLocation,
          name: '',
          type: PlaceType.address,
          description: '',
          address: '',
          coordinates: Coordinates(
            lat: userLocation.latitude,
            lon: userLocation.longitude,
          ),
        );
      }
    }

    try {
      await _fetchItineraryDetails(widget.itinerarySummary.itineraryId);
    } catch (e) {
      setState(() {
        _processingStatus = ProcessingStatus.error;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            AppLocalizations.of(context)!.errorUnableToFetchTravelTime,
          ),
        ),
      );
    }
  }

  Future<void> _fetchItineraryDetails(String itineraryId) async {
    RoutingService routingService = RoutingService();
    try {
      final itineraryDetails = await routingService.getItineraryDetails(
        itineraryId: itineraryId,
      );

      setState(() {
        _itineraryDetails = itineraryDetails;
        _processingStatus = ProcessingStatus.completed;
      });
    } catch (e) {
      setState(() {
        _processingStatus = ProcessingStatus.error;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            AppLocalizations.of(context)!.errorUnableToFetchTravelTime,
          ),
        ),
      );
    }
  }

  void _toggleNavigationState() {
    if (_navigationStatus == NavigationStatus.navigating) {
      setState(() {
        _navigationStatus = NavigationStatus.paused;
      });

      // Unsubscribe from location stream
      _positionStream?.drain();
      _positionStreamSubscription?.cancel();
      _positionStream = null;
      _positionStreamSubscription = null;
    } else if (_navigationStatus == NavigationStatus.idle ||
        _navigationStatus == NavigationStatus.paused) {
      if (!disclaimerAccepted) {
        _showDisclaimerDialog();
      }

      setState(() {
        _navigationStatus = NavigationStatus.navigating;
      });

      // Subscribe to location stream
      _positionStream = Geolocator.getPositionStream();
      _positionStreamSubscription = _positionStream!.listen(
        (Position position) => _onPositionChange(position),
      );
      _getUserLocation();
    }
  }

  void _toggleAudioState() {
    setState(() {
      _audioStatus = _audioStatus == AudioStatus.muted
          ? AudioStatus.unmuted
          : AudioStatus.muted;
    });
  }

  void _onPositionChange(Position position) {
    if (_navigationStatus != NavigationStatus.navigating ||
        _itineraryDetails == null) {
      return;
    }

    // Update user position
    setState(() {
      _userPosition = position;
    });

    // All points of all legs
    List<leg_schema.Step> allSteps = [];
    for (var leg in _itineraryDetails!.legs) {
      allSteps.addAll(leg.steps);
    }

    List<LatLng> allPoints = [];
    for (var leg in _itineraryDetails!.legs) {
      allPoints.addAll(PolygonUtil.decode(leg.geometry));
    }

    // Remaining steps
    List<leg_schema.Step> remainingSteps = _activeStep != null
        ? allSteps.sublist(allSteps.indexOf(_activeStep!))
        : allSteps;
    List<double?> remainingStepDistanceToAction = [];
    for (int i = 0; i < remainingSteps.length; i++) {
      remainingStepDistanceToAction.add(
        i > 0 ? remainingSteps[i - 1].distance : null,
      );
    }

    // Update active step based on user location
    for (int i = 0; i < remainingSteps.length; i++) {
      leg_schema.Step step = remainingSteps[i];
      int stepStartIndex = PolygonUtil.locationIndexOnPath(
        LatLng(step.lat, step.lon),
        allPoints,
        true,
        tolerance: 2,
      );
      int stepEndIndex = PolygonUtil.locationIndexOnPath(
        i < remainingSteps.length - 1
            ? LatLng(remainingSteps[i + 1].lat, remainingSteps[i + 1].lon)
            : LatLng(allPoints.last.latitude, allPoints.last.longitude),
        allPoints,
        true,
        tolerance: 2,
      );

      if (stepStartIndex == -1 ||
          stepEndIndex == -1 ||
          stepEndIndex < stepStartIndex) {
        continue;
      }

      List<LatLng> stepPoints = allPoints.sublist(stepStartIndex, stepEndIndex);

      int positionIndex = PolygonUtil.locationIndexOnPath(
        LatLng(position.latitude, position.longitude),
        stepPoints,
        true,
        tolerance: 10,
      );

      if (positionIndex > -1) {
        if (remainingSteps[i + 1] != _activeStep) {
          setState(() {
            _activeStep = remainingSteps[i + 1];
          });

          // Make text-to-speech announcement for new active step
          int indexOfActiveStep = remainingSteps.indexOf(_activeStep!);
          if (_audioStatus == AudioStatus.unmuted) {
            String stepAnnouncement = "";
            if (remainingStepDistanceToAction[indexOfActiveStep]! >= 1000) {
              stepAnnouncement += AppLocalizations.of(context)!
                  .navigationStepDistanceToActionKilometres(
                    (remainingStepDistanceToAction[indexOfActiveStep]! / 1000)
                        .toStringAsFixed(1),
                  );
            } else {
              stepAnnouncement += AppLocalizations.of(context)!
                  .navigationStepDistanceToActionMetres(
                    remainingStepDistanceToAction[indexOfActiveStep]!
                        .round()
                        .toString(),
                  );
            }
            stepAnnouncement +=
                ". ${getRelativeDirectionTextMapping(_activeStep!.relativeDirection, context)}";

            flutterTts.speak(stepAnnouncement);
          }
        }
        break;
      }
    }
  }

  List<Widget> get _getInstructionTiles {
    if (_itineraryDetails == null || _itineraryDetails!.legs.isEmpty) return [];

    List<Widget> instructionTiles = [];
    for (var leg in _itineraryDetails!.legs) {
      if (leg.steps.isNotEmpty) {
        for (int i = 0; i < leg.steps.length; i++) {
          instructionTiles.add(
            ItineraryLegStepTile(
              step: leg.steps[i],
              distanceToStep: i > 0 ? leg.steps[i - 1].distance : null,
              isActive: leg.steps[i] == _activeStep,
            ),
          );
        }
      } else {
        instructionTiles.add(ItineraryLegTile(leg: leg, isActive: false));
      }
    }

    // Add arrival tile
    instructionTiles.add(
      ItineraryLegStepTile(
        step: leg_schema.Step(
          distance: 0,
          lat: _destination.coordinates.lat,
          lon: _destination.coordinates.lon,
          relativeDirection: RelativeDirection.ARRIVE,
          absoluteDirection: AbsoluteDirection.UNKNOWN,
          streetName: '',
          bogusName: true,
        ),
        distanceToStep: null,
        isActive: false,
      ),
    );

    if (_activeStep == null) {
      return instructionTiles;
    }
    return instructionTiles.sublist(
      _itineraryDetails!.legs.any((leg) => leg.steps.contains(_activeStep!))
          ? instructionTiles.indexWhere((tile) {
              if (tile is ItineraryLegStepTile) {
                return tile.step == _activeStep;
              }
              return false;
            })
          : 0,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Semantics(
        focused: true,
        label: AppLocalizations.of(context)!.routingScreenSemantic,
        child: Column(
          children: [
            SafeArea(
              child: Align(
                alignment: Alignment.topCenter,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Material(
                    elevation: 4.0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16.0),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              _navigationStatus != NavigationStatus.navigating
                                  ? Semantics(
                                      label: AppLocalizations.of(context)!
                                          .origDestPickerOriginSemantic(
                                            _origin.id ==
                                                    Navi4AllValues.userLocation
                                                ? AppLocalizations.of(
                                                    context,
                                                  )!.origDestCurrentLocation
                                                : _origin.name,
                                          ),
                                      excludeSemantics: true,
                                      child: InkWell(
                                        borderRadius: BorderRadius.only(
                                          topLeft: Radius.circular(16.0),
                                          topRight: Radius.circular(16.0),
                                        ),
                                        onTap: null,
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 8.0,
                                            vertical: 4.0,
                                          ),
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.vertical(
                                              top: Radius.circular(16.0),
                                            ),
                                          ),
                                          child: Row(
                                            children: [
                                              SizedBox(width: 8.0),
                                              Padding(
                                                padding: const EdgeInsets.all(
                                                  2.0,
                                                ),
                                                child: Material(
                                                  elevation: 2.0,
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                        12.0,
                                                      ),
                                                  child: Container(
                                                    width: 20.0,
                                                    height: 20.0,
                                                    decoration: BoxDecoration(
                                                      shape: BoxShape.circle,
                                                      color: Theme.of(context)
                                                          .textTheme
                                                          .displayMedium
                                                          ?.color,
                                                      border: Border.all(
                                                        color: Navi4AllColors
                                                            .klWhite,
                                                        width: 3.0,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              SizedBox(width: 12),
                                              Expanded(
                                                child: Text(
                                                  _origin.id ==
                                                          Navi4AllValues
                                                              .userLocation
                                                      ? AppLocalizations.of(
                                                          context,
                                                        )!.origDestCurrentLocation
                                                      : _origin.name,
                                                  maxLines: 1,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  style: TextStyle(
                                                    fontSize: 16.0,
                                                  ),
                                                ),
                                              ),
                                              SizedBox(width: 8.0),
                                              SizedBox(
                                                width: 48.0,
                                                height: 48.0,
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    )
                                  : SizedBox.shrink(),
                              _navigationStatus != NavigationStatus.navigating
                                  ? Divider(
                                      height: 0,
                                      color: Navi4AllColors.klPink,
                                    )
                                  : SizedBox.shrink(),
                              Semantics(
                                label: AppLocalizations.of(context)!
                                    .origDestPickerDestinationSemantic(
                                      _destination.id ==
                                              Navi4AllValues.userLocation
                                          ? AppLocalizations.of(
                                              context,
                                            )!.origDestCurrentLocation
                                          : _destination.name,
                                    ),
                                excludeSemantics: true,
                                child: InkWell(
                                  borderRadius: BorderRadius.only(
                                    bottomLeft: Radius.circular(16.0),
                                    bottomRight: Radius.circular(16.0),
                                  ),
                                  onTap: null,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8.0,
                                      vertical: 4.0,
                                    ),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.vertical(
                                        bottom: Radius.circular(16.0),
                                      ),
                                    ),
                                    child: Row(
                                      children: [
                                        SizedBox(width: 8.0),
                                        Icon(
                                          _navigationStatus !=
                                                  NavigationStatus.navigating
                                              ? Icons.place_rounded
                                              : Icons.navigation_rounded,
                                          color: Theme.of(
                                            context,
                                          ).textTheme.displayMedium?.color,
                                        ),
                                        SizedBox(width: 12),
                                        Expanded(
                                          child: Text(
                                            _destination.id ==
                                                    Navi4AllValues.userLocation
                                                ? AppLocalizations.of(
                                                    context,
                                                  )!.origDestCurrentLocation
                                                : _destination.name,
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: TextStyle(
                                              fontSize: 16.0,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                        SizedBox(width: 8.0),
                                        SizedBox(width: 48.0, height: 48.0),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            Row(
              children: <Widget>[
                Expanded(
                  child: Column(
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: SheetButton(
                                    icon:
                                        _navigationStatus ==
                                            NavigationStatus.idle
                                        ? Icons.play_arrow
                                        : _navigationStatus ==
                                              NavigationStatus.navigating
                                        ? Icons.pause
                                        : _navigationStatus ==
                                              NavigationStatus.arrived
                                        ? Icons.check
                                        : Icons.play_arrow,
                                    label:
                                        _navigationStatus ==
                                            NavigationStatus.idle
                                        ? AppLocalizations.of(
                                            context,
                                          )!.routingScreenNavigationStartButton
                                        : _navigationStatus ==
                                              NavigationStatus.navigating
                                        ? AppLocalizations.of(
                                            context,
                                          )!.routingScreenNavigationPauseButton
                                        : _navigationStatus ==
                                              NavigationStatus.arrived
                                        ? AppLocalizations.of(
                                            context,
                                          )!.routingScreenNavigationDoneButton
                                        : AppLocalizations.of(
                                            context,
                                          )!.routingScreenNavigationResumeButton,
                                    onTap: () => _toggleNavigationState(),
                                    semanticLabel:
                                        _navigationStatus ==
                                            NavigationStatus.idle
                                        ? AppLocalizations.of(
                                            context,
                                          )!.routingScreenNavigationStartButton
                                        : _navigationStatus ==
                                              NavigationStatus.navigating
                                        ? AppLocalizations.of(
                                            context,
                                          )!.routingScreenNavigationPauseButton
                                        : _navigationStatus ==
                                              NavigationStatus.arrived
                                        ? AppLocalizations.of(
                                            context,
                                          )!.routingScreenNavigationDoneButton
                                        : AppLocalizations.of(
                                            context,
                                          )!.routingScreenNavigationResumeButton,
                                    shrinkWrap: false,
                                  ),
                                ),
                                SizedBox(width: 8),
                                AccessibleIconButton(
                                  icon: _audioStatus == AudioStatus.muted
                                      ? Icons.volume_off
                                      : Icons.volume_up,
                                  semanticLabel:
                                      _audioStatus == AudioStatus.muted
                                      ? AppLocalizations.of(
                                          context,
                                        )!.routeNavigationMuteButtonUnmuteText
                                      : AppLocalizations.of(
                                          context,
                                        )!.routeNavigationMuteButtonMuteText,
                                  onTap: _toggleAudioState,
                                ),
                                SizedBox(width: 8),
                                AccessibleIconButton(
                                  icon: Icons.close,
                                  semanticLabel: AppLocalizations.of(
                                    context,
                                  )!.routingScreenExitRoutingButtonSemantic,
                                  onTap: () {
                                    _positionStream?.drain();
                                    _positionStreamSubscription?.cancel();
                                    _positionStream = null;
                                    _positionStreamSubscription = null;
                                    setState(() {
                                      _navigationStatus = NavigationStatus.idle;
                                    });
                                    Navigator.of(context).pop();
                                  },
                                ),
                              ],
                            ),
                            SizedBox(height: 16),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8.0,
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.place_rounded,
                                    color: Theme.of(
                                      context,
                                    ).textTheme.displayMedium?.color,
                                  ),
                                  SizedBox(width: 4.0),
                                  Text(
                                    TextFormatter.formatDurationText(
                                      widget.itinerarySummary.duration,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(fontSize: 16),
                                  ),
                                  SizedBox(width: 8.0),
                                  Icon(
                                    Icons.circle,
                                    size: 6,
                                    color: Theme.of(
                                      context,
                                    ).textTheme.displayMedium?.color,
                                  ),
                                  SizedBox(width: 8.0),
                                  Text(
                                    TextFormatter.formatDistanceText(
                                      widget.itinerarySummary,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(fontSize: 16),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      Divider(height: 0, color: Navi4AllColors.klPink),
                    ],
                  ),
                ),
              ],
            ),
            Expanded(
              child: Stack(
                children: [
                  ListView.separated(
                    padding: EdgeInsets.zero,
                    shrinkWrap: true,
                    itemCount: _getInstructionTiles.length,
                    itemBuilder: (BuildContext context, int index) =>
                        _getInstructionTiles[index],
                    separatorBuilder: (BuildContext context, int index) =>
                        const Divider(
                          height: 1,
                          color: Navi4AllColors.klPink,
                          indent: 16,
                          endIndent: 16,
                        ),
                  ),
                  _processingStatus == ProcessingStatus.processing ||
                          _processingStatus == ProcessingStatus.error
                      ? Center(
                          child: NavigationProcessingTile(
                            processingStatus: _processingStatus,
                          ),
                        )
                      : SizedBox.shrink(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ItineraryLegStepTile extends StatelessWidget {
  final leg_schema.Step step;
  final double? distanceToStep;
  final bool isActive;

  const ItineraryLegStepTile({
    required this.step,
    required this.distanceToStep,
    required this.isActive,
    super.key,
  });

  String? get _streetName {
    return step.bogusName ? null : step.streetName;
  }

  String? _distance(BuildContext context) {
    if (distanceToStep == null) {
      return null;
    }

    if (distanceToStep! >= 1000) {
      return AppLocalizations.of(
        context,
      )!.navigationStepDistanceToActionKilometres(
        (distanceToStep! / 1000).toStringAsFixed(1),
      );
    } else {
      return AppLocalizations.of(context)!.navigationStepDistanceToActionMetres(
        distanceToStep!.round().toString(),
      );
    }
  }

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(24),
    color: isActive
        ? Theme.of(context).colorScheme.tertiary
        : Theme.of(context).colorScheme.surface,
    child: Semantics(
      excludeSemantics: true,
      label:
          '${_distance(context) != null ? _distance(context)! + ', ' : ''}${_streetName != null ? _streetName! + ', ' : ''}${getRelativeDirectionTextMapping(step.relativeDirection, context)}',
      child: Row(
        children: [
          Icon(
            getRelativeDirectionIconMapping(step.relativeDirection),
            color: Navi4AllColors.klPink,
            size: 32,
          ),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  getRelativeDirectionTextMapping(
                    step.relativeDirection,
                    context,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                _streetName != null
                    ? Text(
                        _streetName!,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 16),
                      )
                    : SizedBox.shrink(),
                _distance(context) != null
                    ? Text(
                        _distance(context)!,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 14),
                      )
                    : SizedBox.shrink(),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}

class ItineraryLegTile extends StatelessWidget {
  final leg_schema.LegDetailed leg;
  final bool isActive;

  const ItineraryLegTile({
    required this.leg,
    required this.isActive,
    super.key,
  });

  String _getModeString(BuildContext context) {
    switch (leg.mode) {
      case Mode.WALK:
        return AppLocalizations.of(context)!.commonModeWalking;
      case Mode.BUS:
        return AppLocalizations.of(context)!.commonModeBus;
      case Mode.TRAM:
        return AppLocalizations.of(context)!.commonModeTram;
      case Mode.SUBWAY:
        return AppLocalizations.of(context)!.commonModeUBahn;
      case Mode.RAIL:
        return AppLocalizations.of(context)!.commonModeTrain;
      default:
        return leg.mode.toString();
    }
  }

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(24),
    color: isActive
        ? Theme.of(context).colorScheme.tertiary
        : Theme.of(context).colorScheme.surface,
    child: Row(
      children: [
        Icon(ModeIcons.get(leg.mode), color: Navi4AllColors.klPink, size: 32),
        SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _getModeString(context),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              leg.route?.shortName != null
                  ? Text(
                      leg.route!.shortName!,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 16),
                    )
                  : SizedBox.shrink(),
              null != null
                  ? Text(
                      'for 5 stops',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 14),
                    )
                  : SizedBox.shrink(),
            ],
          ),
        ),
      ],
    ),
  );
}

class NavigationProcessingTile extends StatelessWidget {
  final ProcessingStatus processingStatus;

  const NavigationProcessingTile({required this.processingStatus, super.key});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 24),
    child: Column(
      children: [
        Icon(
          processingStatus == ProcessingStatus.error
              ? Icons.error_outline
              : Icons.directions_outlined,
          size: 48,
          color: Navi4AllColors.klPink,
        ),
        SizedBox(height: 16),
        Text(
          processingStatus == ProcessingStatus.error
              ? AppLocalizations.of(context)!.navigationNoRouteFound
              : AppLocalizations.of(context)!.navigationGettingDirections,
          style: const TextStyle(fontSize: 18, color: Navi4AllColors.klPink),
        ),
      ],
    ),
  );
}
