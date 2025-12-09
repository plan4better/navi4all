import 'dart:async';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:matomo_tracker/matomo_tracker.dart';
import 'package:provider/provider.dart';
import 'package:smartroots/controllers/availability_controller.dart';
import 'package:smartroots/controllers/routing_controller.dart';
import 'package:smartroots/core/analytics/events.dart';
import 'package:smartroots/core/theme/colors.dart';
import 'package:smartroots/core/theme/values.dart';
import 'package:smartroots/l10n/app_localizations.dart';
import 'package:smartroots/schemas/routing/coordinates.dart';
import 'package:smartroots/view/common/accessible_icon_button.dart';
import 'package:smartroots/view/place/place.dart';
import 'package:smartroots/view/routing/map.dart';
import 'package:smartroots/view/common/sliding_bottom_sheet.dart';
import 'package:smartroots/view/common/sheet_button.dart';
import 'package:smartroots/view/search/search.dart';
import 'package:smartroots/schemas/routing/itinerary.dart';
import 'package:smartroots/core/processing_status.dart';
import 'package:smartroots/services/routing.dart';
import 'package:geolocator/geolocator.dart';
import 'package:smartroots/schemas/routing/leg.dart' as leg_schema;
import 'package:smartroots/schemas/routing/mode.dart';
import 'package:smartroots/schemas/routing/place.dart';
import 'package:smartroots/core/utils.dart';
import 'package:flutter_tts/flutter_tts.dart';

class RoutingScreen extends StatefulWidget {
  final Place parkingLocation;

  const RoutingScreen({required this.parkingLocation, super.key});

  @override
  RoutingState createState() => RoutingState();
}

class RoutingState extends State<RoutingScreen> {
  late Place _parkingLocation;
  bool disclaimerAccepted = false;
  final FlutterTts flutterTts = FlutterTts();
  late Place _origin;
  late Place _destination;
  List<ItinerarySummary> _itineraries = [];
  ItineraryDetails? _itineraryDetails;
  ProcessingStatus _processingStatus = ProcessingStatus.idle;
  leg_schema.Step? _activeStep;

  @override
  void initState() {
    super.initState();

    _parkingLocation = widget.parkingLocation;

    // flutterTts.setLanguage(AppLocalizations.of(context)!.localeName);

    // Initialise origin and destination places
    _origin = Place(
      id: SmartRootsValues.userLocation,
      name: '',
      type: PlaceType.address,
      description: '',
      address: '',
      coordinates: Coordinates(lat: 0.0, lon: 0.0),
    );
    _destination = _parkingLocation;

    // Initiate availability monitoring
    Provider.of<AvailabilityController>(
      context,
      listen: false,
    ).startMonitoring(_parkingLocation);

    // Listen for availability changes
    Provider.of<AvailabilityController>(context, listen: false).addListener(() {
      AvailabilityController availabilityController =
          Provider.of<AvailabilityController>(context, listen: false);
      if (availabilityController.state == AvailabilityControllerState.change) {
        setState(() {
          _parkingLocation = availabilityController.parkingLocation!;
        });
        _showAvailabilityChangeDialog();
        availabilityController.stopMonitoring();

        // Analytics event
        MatomoTracker.instance.trackEvent(
          eventInfo: EventInfo(
            category: EventCategory.routingScreen.toString(),
            action: EventAction.routingScreenAvailabilityChangeOccurred
                .toString(),
          ),
        );
      }
    });

    // Fetch itineraries
    _fetchItineraries();
  }

  void _showAvailabilityChangeDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setStateDialog) => Dialog(
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
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color:
                                (_parkingLocation
                                    .attributes?['has_realtime_data'])
                                ? (_parkingLocation
                                          .attributes?['disabled_parking_available'])
                                      ? SmartRootsColors.maGreen
                                      : SmartRootsColors.maRed
                                : SmartRootsColors.maBlueExtraDark,
                            borderRadius: BorderRadius.circular(32),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.local_parking,
                                size: 16,
                                color: SmartRootsColors.maWhite,
                              ),
                            ],
                          ),
                        ),
                        SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            AppLocalizations.of(
                              context,
                            )!.availabilityChangeDialogTitle,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: SmartRootsColors.maBlueExtraExtraDark,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 24),
                  Align(
                    alignment: Alignment.topLeft,
                    child: Text(
                      AppLocalizations.of(
                        context,
                      )!.availabilityChangeDialogMessage,
                      style: TextStyle(
                        color: SmartRootsColors.maBlueExtraExtraDark,
                      ),
                    ),
                  ),
                  SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: SheetButton(
                          label: AppLocalizations.of(
                            context,
                          )!.availabilityChangeDialogCancelButton,
                          onTap: () {
                            Navigator.of(context).pop();

                            // Analytics event
                            MatomoTracker.instance.trackEvent(
                              eventInfo: EventInfo(
                                category: EventCategory.routingScreen
                                    .toString(),
                                action: EventAction
                                    .routingScreenAvailabilityChangeAlternativeSearchCancelled
                                    .toString(),
                              ),
                            );
                          },
                        ),
                      ),
                      SizedBox(width: 8),
                      Expanded(
                        child: SheetButton(
                          label: AppLocalizations.of(
                            context,
                          )!.availabilityChangeDialogConfirmButton,
                          onTap: () {
                            Provider.of<RoutingController>(
                              context,
                              listen: false,
                            ).stopNavigation();

                            Place place = _parkingLocation;
                            Navigator.of(context).pop();
                            Navigator.of(context).pushReplacement(
                              MaterialPageRoute(
                                builder: (context) => PlaceScreen(place: place),
                              ),
                            );

                            // Analytics event
                            MatomoTracker.instance.trackEvent(
                              eventInfo: EventInfo(
                                category: EventCategory.routingScreen
                                    .toString(),
                                action: EventAction
                                    .routingScreenAvailabilityChangeAlternativeSearchConfirmed
                                    .toString(),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
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
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: SmartRootsColors.maBlueExtraExtraDark,
                    ),
                  ),
                ),
                SizedBox(height: 16),
                Align(
                  alignment: Alignment.topLeft,
                  child: Text(
                    AppLocalizations.of(context)!.routingDisclaimerMessage,
                    style: TextStyle(
                      fontSize: 14,
                      color: SmartRootsColors.maBlueExtraExtraDark,
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

                          // Analytics event
                          MatomoTracker.instance.trackEvent(
                            eventInfo: EventInfo(
                              category: EventCategory.routingScreen.toString(),
                              action: EventAction
                                  .routingScreenDisclaimerRejected
                                  .toString(),
                            ),
                          );
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
                          _toggleNavigationState();
                          Navigator.of(context).pop();

                          // Analytics event
                          MatomoTracker.instance.trackEvent(
                            eventInfo: EventInfo(
                              category: EventCategory.routingScreen.toString(),
                              action: EventAction
                                  .routingScreenDisclaimerAccepted
                                  .toString(),
                            ),
                          );
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
      _itineraries = [];
      _itineraryDetails = null;
    });

    // Delay allows map to initialize
    await Future.delayed(Duration(milliseconds: 250));

    if (_origin.id == SmartRootsValues.userLocation ||
        _destination.id == SmartRootsValues.userLocation) {
      final userLocation = await _getUserLocation();
      if (userLocation == null) {
        setState(() {
          _processingStatus = ProcessingStatus.error;
        });
        return;
      }

      if (_origin.id == SmartRootsValues.userLocation) {
        _origin = Place(
          id: SmartRootsValues.userLocation,
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

      if (_destination.id == SmartRootsValues.userLocation) {
        _destination = Place(
          id: SmartRootsValues.userLocation,
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

    List<ItinerarySummary> itineraries = [];
    RoutingService routingService = RoutingService();
    try {
      final response = await routingService.getItineraries(
        originLat: _origin.coordinates.lat,
        originLon: _origin.coordinates.lon,
        destinationLat: _destination.coordinates.lat,
        destinationLon: _destination.coordinates.lon,
        date: DateFormat('yyyy-MM-dd').format(DateTime.now()),
        time: DateFormat('HH:mm:ss').format(DateTime.now()),
        timeIsArrival: false,
        transportModes: ["CAR"],
      );
      if (response.statusCode == 200) {
        final data = response.data["itineraries"] as List;
        itineraries = data
            .map((item) => ItinerarySummary.fromJson(item))
            .toList();
        setState(() {
          _itineraries = itineraries;
        });
      } else {
        throw Exception('Failed to load itineraries');
      }

      if (itineraries.isNotEmpty) {
        await _fetchItineraryDetails(itineraries.first.itineraryId);

        // Initialize routing controller
        Provider.of<RoutingController>(context, listen: false).setParameters(
          origin: _origin,
          destination: _destination,
          itineraryDetails: _itineraryDetails!,
        );
      } else {
        setState(() {
          _processingStatus = ProcessingStatus.error;
        });
      }
    } catch (e) {
      setState(() {
        _processingStatus = ProcessingStatus.error;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            AppLocalizations.of(context)!.errorUnableToFetchDrivingTime,
          ),
        ),
      );
    }
  }

  Future<void> _fetchItineraryDetails(String itineraryId) async {
    ItineraryDetails? itineraryDetails;
    RoutingService routingService = RoutingService();
    try {
      final response = await routingService.getItineraryDetails(
        itineraryId: itineraryId,
      );
      if (response.statusCode == 200) {
        itineraryDetails = ItineraryDetails.fromJson(response.data);
      } else {
        throw Exception('Failed to load itinerary details');
      }

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
            AppLocalizations.of(context)!.errorUnableToFetchDrivingTime,
          ),
        ),
      );
    }
  }

  void _toggleNavigationState() {
    NavigationStatus navigationStatus = Provider.of<RoutingController>(
      context,
      listen: false,
    ).navigationStatus;

    switch (navigationStatus) {
      case NavigationStatus.idle:
        if (!disclaimerAccepted) {
          _showDisclaimerDialog();
          break;
        }
        Provider.of<RoutingController>(
          context,
          listen: false,
        ).startNavigation();
        break;
      case NavigationStatus.paused:
        Provider.of<RoutingController>(
          context,
          listen: false,
        ).resumeNavigation();
        break;
      case NavigationStatus.navigating:
        Provider.of<RoutingController>(
          context,
          listen: false,
        ).pauseNavigation();
        break;
      case NavigationStatus.arrived:
        // TODO: Handle this scenario better
        break;
    }
  }

  /* if (_navigationStatus == NavigationStatus.navigating) {
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
    } */

  void _toggleAudioStatus() {
    AudioStatus audioStatus = Provider.of<RoutingController>(
      context,
      listen: false,
    ).audioStatus;
    if (audioStatus == AudioStatus.muted) {
      Provider.of<RoutingController>(context, listen: false).unmuteAudio();
    } else {
      Provider.of<RoutingController>(context, listen: false).muteAudio();
    }
  }

  /* void _onPositionChange(Position position) {
    if (context.read<RoutingController>().navigationStatus !=
            NavigationStatus.navigating ||
        _itineraryDetails == null) {
      return;
    }

    // Update user position
    setState(() {
      _userPosition = position;
    });

    // All points of leg geometry
    leg_schema.LegDetailed leg = _itineraryDetails!.legs.first;
    List<LatLng> legPoints = PolygonUtil.decode(leg.geometry);

    // Remaining steps
    List<leg_schema.Step> remainingSteps = _activeStep != null
        ? leg.steps.sublist(leg.steps.indexOf(_activeStep!))
        : leg.steps;
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
        legPoints,
        true,
        tolerance: 2,
      );
      int stepEndIndex = PolygonUtil.locationIndexOnPath(
        i < remainingSteps.length - 1
            ? LatLng(remainingSteps[i + 1].lat, remainingSteps[i + 1].lon)
            : LatLng(legPoints.last.latitude, legPoints.last.longitude),
        legPoints,
        true,
        tolerance: 2,
      );

      if (stepStartIndex == -1 ||
          stepEndIndex == -1 ||
          stepEndIndex < stepStartIndex) {
        continue;
      }

      List<LatLng> stepPoints = legPoints.sublist(stepStartIndex, stepEndIndex);

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
          if (context.read<RoutingController>().audioStatus ==
              AudioStatus.unmuted) {
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
  } */

  List<ItineraryLegStepTile> get _legSteps {
    if (_itineraryDetails == null || _itineraryDetails!.legs.isEmpty) return [];

    List<leg_schema.Step> steps = _itineraryDetails!.legs.first.steps;
    List<ItineraryLegStepTile> stepTiles = [];
    for (int i = 0; i < steps.length; i++) {
      stepTiles.add(
        ItineraryLegStepTile(
          step: steps[i],
          distanceToStep: i > 0 ? steps[i - 1].distance : null,
          isActive: steps[i] == _activeStep,
        ),
      );
    }
    stepTiles.add(
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
        distanceToStep: steps.isNotEmpty ? steps.last.distance : null,
        isActive: false,
      ),
    );

    if (_activeStep == null) {
      return stepTiles;
    }
    return stepTiles.sublist(
      _itineraryDetails!.legs.first.steps.indexOf(_activeStep!),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          RoutingMap(destination: _parkingLocation),
          SlidingBottomSheet(
            Row(
              children: <Widget>[
                Expanded(
                  child: Column(
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24.0,
                          vertical: 16.0,
                        ),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Consumer<RoutingController>(
                                    builder: (context, routingController, _) => SheetButton(
                                      icon:
                                          routingController.navigationStatus ==
                                              NavigationStatus.idle
                                          ? Icons.play_arrow
                                          : routingController
                                                    .navigationStatus ==
                                                NavigationStatus.navigating
                                          ? Icons.pause
                                          : routingController
                                                    .navigationStatus ==
                                                NavigationStatus.arrived
                                          ? Icons.check
                                          : Icons.play_arrow,
                                      label:
                                          routingController.navigationStatus ==
                                              NavigationStatus.idle
                                          ? AppLocalizations.of(
                                              context,
                                            )!.routingScreenNavigationStartButton
                                          : routingController
                                                    .navigationStatus ==
                                                NavigationStatus.navigating
                                          ? AppLocalizations.of(
                                              context,
                                            )!.routingScreenNavigationPauseButton
                                          : routingController
                                                    .navigationStatus ==
                                                NavigationStatus.arrived
                                          ? AppLocalizations.of(
                                              context,
                                            )!.routingScreenNavigationDoneButton
                                          : AppLocalizations.of(
                                              context,
                                            )!.routingScreenNavigationResumeButton,
                                      semanticLabel:
                                          routingController.navigationStatus ==
                                              NavigationStatus.idle
                                          ? AppLocalizations.of(
                                              context,
                                            )!.routingScreenNavigationStartButton
                                          : routingController
                                                    .navigationStatus ==
                                                NavigationStatus.navigating
                                          ? AppLocalizations.of(
                                              context,
                                            )!.routingScreenNavigationPauseButton
                                          : routingController
                                                    .navigationStatus ==
                                                NavigationStatus.arrived
                                          ? AppLocalizations.of(
                                              context,
                                            )!.routingScreenNavigationDoneButton
                                          : AppLocalizations.of(
                                              context,
                                            )!.routingScreenNavigationResumeButton,
                                      onTap: () => _toggleNavigationState(),
                                      shrinkWrap: false,
                                    ),
                                  ),
                                ),
                                SizedBox(width: 8),
                                Consumer<RoutingController>(
                                  builder: (context, routingController, _) =>
                                      AccessibleIconButton(
                                        icon:
                                            routingController.audioStatus ==
                                                AudioStatus.muted
                                            ? Icons.volume_off
                                            : Icons.volume_up,
                                        semanticLabel:
                                            routingController.audioStatus ==
                                                AudioStatus.muted
                                            ? AppLocalizations.of(
                                                context,
                                              )!.routeNavigationMuteButtonUnmuteText
                                            : AppLocalizations.of(
                                                context,
                                              )!.routeNavigationMuteButtonMuteText,
                                        onTap: () => _toggleAudioStatus(),
                                      ),
                                ),
                                SizedBox(width: 8),
                                AccessibleIconButton(
                                  icon: Icons.close,
                                  semanticLabel: AppLocalizations.of(
                                    context,
                                  )!.routingScreenExitRoutingButtonSemantic,
                                  onTap: () {
                                    context
                                        .read<RoutingController>()
                                        .stopNavigation();
                                    Navigator.of(context).pop();
                                  },
                                ),
                              ],
                            ),
                            SizedBox(height: 16),
                            _itineraries.isNotEmpty
                                ? Row(
                                    children: [
                                      Icon(
                                        Icons.directions_car_outlined,
                                        color: SmartRootsColors
                                            .maBlueExtraExtraDark,
                                      ),
                                      SizedBox(width: 8.0),
                                      Text(
                                        TextFormatter.formatDurationText(
                                          _itineraries.first.duration,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                          color: SmartRootsColors
                                              .maBlueExtraExtraDark,
                                          fontSize: 16,
                                        ),
                                      ),
                                      SizedBox(width: 6.0),
                                      Icon(
                                        Icons.circle,
                                        size: 6,
                                        color: SmartRootsColors
                                            .maBlueExtraExtraDark,
                                      ),
                                      SizedBox(width: 6.0),
                                      Text(
                                        TextFormatter.formatDistanceText(
                                          _itineraries.first,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                          color: SmartRootsColors
                                              .maBlueExtraExtraDark,
                                          fontSize: 16,
                                        ),
                                      ),
                                    ],
                                  )
                                : SizedBox.shrink(),
                          ],
                        ),
                      ),
                      Divider(height: 0, color: SmartRootsColors.maBlue),
                    ],
                  ),
                ),
              ],
            ),
            listItems: _processingStatus == ProcessingStatus.completed
                ? _legSteps
                : null,
            body:
                _processingStatus == ProcessingStatus.processing ||
                    _processingStatus == ProcessingStatus.error
                ? NavigationProcessingTile(processingStatus: _processingStatus)
                : SizedBox.shrink(),
            initSize: 0.35,
            maxSize: 0.7,
          ),
          SafeArea(
            child: Align(
              alignment: Alignment.topCenter,
              child: Padding(
                padding: const EdgeInsets.only(top: 32, left: 16, right: 16),
                child: Consumer<RoutingController>(
                  builder: (context, routingController, _) => Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Semantics(
                        label: AppLocalizations.of(context)!
                            .origDestPickerOriginSemantic(
                              _origin.id == SmartRootsValues.userLocation
                                  ? AppLocalizations.of(
                                      context,
                                    )!.origDestCurrentLocation
                                  : _origin.name,
                            ),
                        excludeSemantics: true,
                        button: true,
                        focused: true,
                        child:
                            routingController.navigationStatus !=
                                NavigationStatus.navigating
                            ? Material(
                                elevation: 4,
                                borderRadius: BorderRadius.circular(16),
                                child: InkWell(
                                  borderRadius: BorderRadius.only(
                                    topLeft: Radius.circular(16),
                                    topRight: Radius.circular(16),
                                  ),
                                  onTap: () {
                                    Navigator.of(context)
                                        .push(
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                const SearchScreen(
                                                  isSecondarySearch: true,
                                                  isOriginPlaceSearch: true,
                                                ),
                                          ),
                                        )
                                        .then((result) {
                                          if (result is Place) {
                                            setState(() {
                                              _origin = result;
                                              routingController
                                                  .stopNavigation();
                                            });
                                            _fetchItineraries();
                                          }
                                        });
                                  },
                                  child: Container(
                                    height: 56,
                                    decoration: BoxDecoration(
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.secondary,
                                      borderRadius: BorderRadius.only(
                                        topLeft: Radius.circular(28),
                                        topRight: Radius.circular(28),
                                      ),
                                    ),
                                    child: Row(
                                      children: [
                                        SizedBox(width: 16),
                                        Padding(
                                          padding: const EdgeInsets.all(2.0),
                                          child: Material(
                                            elevation: 2.0,
                                            borderRadius: BorderRadius.circular(
                                              12.0,
                                            ),
                                            child: Container(
                                              width: 20.0,
                                              height: 20.0,
                                              decoration: BoxDecoration(
                                                shape: BoxShape.circle,
                                                color: SmartRootsColors
                                                    .maBlueExtraDark,
                                                border: Border.all(
                                                  color:
                                                      SmartRootsColors.maWhite,
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
                                                    SmartRootsValues
                                                        .userLocation
                                                ? AppLocalizations.of(
                                                    context,
                                                  )!.origDestCurrentLocation
                                                : _origin.name,
                                            style: const TextStyle(
                                              fontSize: 16,
                                              color: SmartRootsColors
                                                  .maBlueExtraExtraDark,
                                            ),
                                            overflow: TextOverflow.ellipsis,
                                            maxLines: 1,
                                          ),
                                        ),
                                        SizedBox(width: 16),
                                      ],
                                    ),
                                  ),
                                ),
                              )
                            : SizedBox.shrink(),
                      ),
                      routingController.navigationStatus !=
                              NavigationStatus.navigating
                          ? Divider(height: 0, color: SmartRootsColors.maBlue)
                          : SizedBox.shrink(),
                      Semantics(
                        label: AppLocalizations.of(context)!
                            .origDestPickerDestinationSemantic(
                              _destination.id == SmartRootsValues.userLocation
                                  ? AppLocalizations.of(
                                      context,
                                    )!.origDestCurrentLocation
                                  : _destination.name,
                            ),
                        excludeSemantics: true,
                        button: false,
                        child: Material(
                          elevation: 4,
                          borderRadius: BorderRadius.circular(16),
                          child: Container(
                            height: 56,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.only(
                                topLeft:
                                    routingController.navigationStatus !=
                                        NavigationStatus.navigating
                                    ? Radius.circular(0)
                                    : Radius.circular(16),
                                topRight:
                                    routingController.navigationStatus !=
                                        NavigationStatus.navigating
                                    ? Radius.circular(0)
                                    : Radius.circular(16),
                                bottomLeft: Radius.circular(16),
                                bottomRight: Radius.circular(16),
                              ),
                              color: Theme.of(context).colorScheme.secondary,
                            ),
                            child: Row(
                              children: [
                                SizedBox(width: 16),
                                Container(
                                  padding: const EdgeInsets.all(4),
                                  decoration: BoxDecoration(
                                    color:
                                        (_parkingLocation
                                            .attributes?['has_realtime_data'])
                                        ? (_parkingLocation
                                                  .attributes?['disabled_parking_available'])
                                              ? SmartRootsColors.maGreen
                                              : SmartRootsColors.maRed
                                        : SmartRootsColors.maBlueExtraDark,
                                    borderRadius: BorderRadius.circular(32),
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.local_parking,
                                        size: 16,
                                        color: SmartRootsColors.maWhite,
                                      ),
                                    ],
                                  ),
                                ),
                                SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    _destination.id ==
                                            SmartRootsValues.userLocation
                                        ? AppLocalizations.of(
                                            context,
                                          )!.origDestCurrentLocation
                                        : _destination.name,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      color:
                                          SmartRootsColors.maBlueExtraExtraDark,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 1,
                                  ),
                                ),
                                SizedBox(width: 16),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
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
        TextFormatter.formatKilometersDistanceFromMeters(
          distanceToStep!,
        ).toString().replaceAll('.', ','),
      );
    } else {
      return AppLocalizations.of(context)!.navigationStepDistanceToActionMetres(
        TextFormatter.formatMetersDistanceFromMeters(
          distanceToStep!,
        ).toString(),
      );
    }
  }

  @override
  Widget build(BuildContext context) => Semantics(
    excludeSemantics: true,
    label:
        '${_distance(context) != null ? '${_distance(context)!}, ' : ''}${_streetName != null ? '${_streetName!}, ' : ''}${getRelativeDirectionTextMapping(step.relativeDirection, context)}',
    child: Container(
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 24),
      color: isActive
          ? Theme.of(context).colorScheme.tertiary
          : Theme.of(context).colorScheme.surface,
      child: Row(
        children: [
          Icon(
            getRelativeDirectionIconMapping(step.relativeDirection),
            color: SmartRootsColors.maBlue,
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
                    color: SmartRootsColors.maBlueExtraExtraDark,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                _streetName != null
                    ? Text(
                        _streetName!,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 16,
                          color: SmartRootsColors.maBlueExtraExtraDark,
                        ),
                      )
                    : SizedBox.shrink(),
                _distance(context) != null
                    ? Text(
                        _distance(context)!,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 14,
                          color: SmartRootsColors.maBlueExtraExtraDark,
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
              : Icons.directions_car_filled_outlined,
          size: 48,
          color: SmartRootsColors.maBlue,
        ),
        SizedBox(height: 16),
        Text(
          processingStatus == ProcessingStatus.error
              ? AppLocalizations.of(context)!.navigationNoRouteFound
              : AppLocalizations.of(
                  context,
                )!.navigationGettingDrivingDirections,
          style: const TextStyle(fontSize: 18, color: SmartRootsColors.maBlue),
        ),
      ],
    ),
  );
}
