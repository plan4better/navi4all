import 'dart:async';

import 'package:flutter/material.dart';
import 'package:matomo_tracker/matomo_tracker.dart';
import 'package:provider/provider.dart';
import 'package:smartroots/controllers/availability_controller.dart';
import 'package:smartroots/controllers/routing_controller.dart';
import 'package:smartroots/core/analytics/events.dart';
import 'package:smartroots/core/theme/colors.dart';
import 'package:smartroots/core/theme/values.dart';
import 'package:smartroots/l10n/app_localizations.dart';
import 'package:smartroots/schemas/routing/audio_stage.dart';
import 'package:smartroots/schemas/routing/coordinates.dart';
import 'package:smartroots/view/common/accessible_icon_button.dart';
import 'package:smartroots/view/place/place.dart';
import 'package:smartroots/view/routing/leg_tile.dart';
import 'package:smartroots/view/routing/map.dart';
import 'package:smartroots/view/common/sliding_bottom_sheet.dart';
import 'package:smartroots/view/common/sheet_button.dart';
import 'package:smartroots/view/search/search.dart';
import 'package:smartroots/schemas/routing/itinerary.dart';
import 'package:smartroots/core/processing_status.dart';
import 'package:smartroots/services/routing.dart';
import 'package:geolocator/geolocator.dart';
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
  late NavigationInstructionsController _navigationInstructionsController;
  late NavigationAudioController _navigationAudioController;
  late NavigationDigressingController _navigationDigressingController;
  bool disclaimerAccepted = false;
  final FlutterTts flutterTts = FlutterTts();
  late Place _origin;
  late Place _destination;
  ItineraryDetails? _itineraryDetails;
  ProcessingStatus _processingStatus = ProcessingStatus.idle;
  List<LegTile> _legTiles = [];

  @override
  void initState() {
    super.initState();

    _parkingLocation = widget.parkingLocation;

    _navigationInstructionsController =
        Provider.of<NavigationInstructionsController>(context, listen: false);
    _navigationInstructionsController.addListener(_buildLegTiles);
    _navigationAudioController = Provider.of<NavigationAudioController>(
      context,
      listen: false,
    );
    _navigationAudioController.addListener(_triggerNavigationAudio);
    _navigationDigressingController =
        Provider.of<NavigationDigressingController>(context, listen: false);
    _navigationDigressingController.addListener(
      _watchNavigationDigressingState,
    );

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
    });

    // Delay allows map to initialize
    await Future.delayed(Duration(milliseconds: 500));

    // Initialise TTS language
    await flutterTts.setLanguage(AppLocalizations.of(context)!.localeName);

    // Initialize origin and destination places
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

    try {
      // Fetch data
      RoutingService routingService = RoutingService();
      List<ItinerarySummary> results = await routingService.getItineraries(
        originLat: _origin.coordinates.lat,
        originLon: _origin.coordinates.lon,
        destinationLat: _destination.coordinates.lat,
        destinationLon: _destination.coordinates.lon,
        time: DateTime.now(),
        transportModes: [Mode.CAR.name],
        timeIsArrival: false,
      );

      if (results.isNotEmpty) {
        await _fetchItineraryDetails(results.first.itineraryId);
      } else {
        throw Exception(AppLocalizations.of(context)!.navigationNoRouteFound);
      }
    } catch (e) {
      setState(() {
        _processingStatus = ProcessingStatus.error;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            AppLocalizations.of(context)!.errorUnableToFetchItineraries,
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

      // Initialize routing controller
      Provider.of<RoutingController>(
        context,
        listen: false,
      ).setParameters(itineraryDetails: itineraryDetails);

      setState(() {
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

  Future<void> _watchNavigationDigressingState() async {
    // Check if user is digressing
    if (_navigationDigressingController.routingControllerState ==
        RoutingControllerState.digressing) {
      // Play a sound to indicate rerouting
      flutterTts.speak(
        AppLocalizations.of(context)!.routingScreenReroutingDialogTitle,
      );

      // Attempt to reroute automatically
      // Stop navigation
      RoutingController routingController = Provider.of<RoutingController>(
        context,
        listen: false,
      );
      routingController.stopNavigation();

      // Prepare navigation with new itinerary
      await _fetchItineraries();

      // Restart navigation
      routingController.startNavigation();
    }
  }

  void _buildLegTiles() {
    List<LegTile> legTiles = [];
    _navigationInstructionsController.upcomingInstructions.forEach((
      MapEntry instruction,
    ) {
      legTiles.add(
        LegTile(
          leg: instruction.key,
          activeLeg: _navigationInstructionsController.instructionLeg,
          steps: instruction.value,
          activeStep: _navigationInstructionsController.instructionStep,
          isPrimaryLeg:
              _navigationInstructionsController.upcomingInstructions.length ==
              1,
        ),
      );
    });

    setState(() {
      _legTiles = legTiles;
    });
  }

  Future<void> _triggerNavigationAudio() async {
    if (_navigationAudioController.audioStatus == AudioStatus.muted ||
        _navigationAudioController.instructionStep == null) {
      return;
    }

    // Make text-to-speech announcement for new active step
    String stepAnnouncement = "";
    if (_navigationAudioController.audioStage != AudioStage.near) {
      // Exclude distance for final audio stage
      if (_navigationAudioController.instructionStep!.distance >= 1000) {
        stepAnnouncement += AppLocalizations.of(context)!
            .navigationStepDistanceToActionKilometres(
              '${TextFormatter.formatKilometersDistanceFromMeters(_navigationAudioController.instructionStep!.distance)}. ',
            );
      } else {
        stepAnnouncement +=
            '${AppLocalizations.of(context)!.navigationStepDistanceToActionMetres(TextFormatter.formatMetersDistanceFromMeters(_navigationAudioController.instructionStep!.distance).toString())}. ';
      }
    }
    stepAnnouncement += getRelativeDirectionTextMapping(
      _navigationAudioController.instructionStep!.relativeDirection,
      context,
    );

    flutterTts.speak(stepAnnouncement);
  }

  @override
  void dispose() {
    _navigationInstructionsController.removeListener(_buildLegTiles);
    _navigationAudioController.removeListener(_triggerNavigationAudio);
    _navigationDigressingController.removeListener(
      _watchNavigationDigressingState,
    );
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          RoutingMap(destination: _parkingLocation),
          Consumer<RoutingController>(
            builder: (context, routingController, _) => SlidingBottomSheet(
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
                                    child: SheetButton(
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
                                  SizedBox(width: 8),
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
                                  SizedBox(width: 8),
                                  AccessibleIconButton(
                                    icon: Icons.close,
                                    semanticLabel: AppLocalizations.of(
                                      context,
                                    )!.routingScreenExitRoutingButtonSemantic,
                                    onTap: () {
                                      routingController.stopNavigation();
                                      Navigator.of(context).pop();
                                    },
                                  ),
                                ],
                              ),
                              SizedBox(height: 16),
                              Consumer<NavigationStatsController>(
                                builder:
                                    (
                                      context,
                                      navigationStatsController,
                                      _,
                                    ) => Row(
                                      children: [
                                        Icon(
                                          Icons.directions_car_outlined,
                                          color: SmartRootsColors
                                              .maBlueExtraExtraDark,
                                        ),
                                        SizedBox(width: 8.0),
                                        navigationStatsController
                                                    .timeToArrival !=
                                                null
                                            ? Text(
                                                TextFormatter.formatDurationText(
                                                  navigationStatsController
                                                      .timeToArrival!,
                                                ),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                                style: TextStyle(
                                                  color: SmartRootsColors
                                                      .maBlueExtraExtraDark,
                                                  fontSize: 16,
                                                ),
                                              )
                                            : SizedBox.shrink(),
                                        SizedBox(width: 6.0),
                                        Icon(
                                          Icons.circle,
                                          size: 6,
                                          color: SmartRootsColors
                                              .maBlueExtraExtraDark,
                                        ),
                                        SizedBox(width: 6.0),
                                        navigationStatsController
                                                    .distanceToArrival !=
                                                null
                                            ? Text(
                                                TextFormatter.formatDistanceValueText(
                                                  navigationStatsController
                                                      .distanceToArrival!,
                                                ),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                                style: TextStyle(
                                                  color: SmartRootsColors
                                                      .maBlueExtraExtraDark,
                                                  fontSize: 16,
                                                ),
                                              )
                                            : SizedBox.shrink(),
                                      ],
                                    ),
                              ),
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
                  ? _legTiles
                  : null,
              body:
                  _processingStatus == ProcessingStatus.processing ||
                      _processingStatus == ProcessingStatus.error
                  ? NavigationProcessingTile(
                      processingStatus: _processingStatus,
                    )
                  : SizedBox.shrink(),
              initSize: 0.35,
              maxSize: 0.7,
            ),
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
                          borderRadius:
                              routingController.navigationStatus !=
                                  NavigationStatus.navigating
                              ? BorderRadius.only(
                                  bottomLeft: Radius.circular(16),
                                  bottomRight: Radius.circular(16),
                                )
                              : BorderRadius.circular(64),
                          child: Container(
                            height: 56,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.only(
                                topLeft:
                                    routingController.navigationStatus !=
                                        NavigationStatus.navigating
                                    ? Radius.circular(0)
                                    : Radius.circular(64),
                                topRight:
                                    routingController.navigationStatus !=
                                        NavigationStatus.navigating
                                    ? Radius.circular(0)
                                    : Radius.circular(64),
                                bottomLeft:
                                    routingController.navigationStatus !=
                                        NavigationStatus.navigating
                                    ? Radius.circular(16)
                                    : Radius.circular(64),
                                bottomRight:
                                    routingController.navigationStatus !=
                                        NavigationStatus.navigating
                                    ? Radius.circular(16)
                                    : Radius.circular(64),
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
