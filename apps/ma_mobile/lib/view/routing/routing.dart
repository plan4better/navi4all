import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
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
import 'package:smartroots/view/routing/rerouting_dialog.dart';
import 'package:smartroots/view/search/search.dart';
import 'package:smartroots/schemas/routing/itinerary.dart';
import 'package:smartroots/core/processing_status.dart';
import 'package:smartroots/services/routing.dart';
import 'package:geolocator/geolocator.dart';
import 'package:smartroots/schemas/routing/mode.dart';
import 'package:smartroots/schemas/routing/place.dart';
import 'package:smartroots/core/utils.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:smartroots/schemas/routing/leg.dart' as leg_schema;

class RoutingScreen extends StatefulWidget {
  final Place parkingLocation;

  const RoutingScreen({required this.parkingLocation, super.key});

  @override
  RoutingState createState() => RoutingState();
}

class RoutingState extends State<RoutingScreen> {
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
    _destination = widget.parkingLocation;

    // Initiate availability monitoring
    if (_destination.type == PlaceType.parkingSpot ||
        _destination.type == PlaceType.parkingSite) {
      Provider.of<AvailabilityController>(
        context,
        listen: false,
      ).startMonitoring(_destination);
    }

    // Listen for availability changes
    Provider.of<AvailabilityController>(context, listen: false).addListener(() {
      AvailabilityController availabilityController =
          Provider.of<AvailabilityController>(context, listen: false);
      if (availabilityController.state == AvailabilityControllerState.change) {
        setState(() {
          _destination = availabilityController.parkingLocation!;
        });
        _showAvailabilityChangeDialog();
        availabilityController.stopMonitoring();

        // Analytics event
        MatomoTracker.instance.trackEvent(
          eventInfo: EventInfo(
            category: EventCategory.routingScreen.toString(),
            action: EventAction.routingScreenAvailabilityChangeOccurred
                .toString(),
            name:
                eventActionLabels[EventAction
                    .routingScreenAvailabilityChangeOccurred]!,
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
            child: OrientationBuilder(
              builder: (context, orientation) => Container(
                width: orientation == Orientation.portrait
                    ? double.infinity
                    : MediaQuery.of(context).size.width * 0.5,
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Align(
                      alignment: Alignment.topLeft,
                      child: Row(
                        children: [
                          _destination.type == PlaceType.parkingSpot ||
                                  _destination.type == PlaceType.parkingSite
                              ? WidgetGenerator.getParkingPlaceIcon(
                                  _destination,
                                )
                              : Icon(
                                  Icons.place_rounded,
                                  color: SmartRootsColors.maBlueExtraExtraDark,
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
                                  name:
                                      eventActionLabels[EventAction
                                          .routingScreenAvailabilityChangeAlternativeSearchCancelled]!,
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

                              Navigator.of(context).pop();
                              Navigator.of(context).pushReplacement(
                                MaterialPageRoute(
                                  builder: (context) =>
                                      PlaceScreen(place: _destination),
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
                                  name:
                                      eventActionLabels[EventAction
                                          .routingScreenAvailabilityChangeAlternativeSearchConfirmed]!,
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
          child: OrientationBuilder(
            builder: (context, orientation) => Container(
              width: orientation == Orientation.portrait
                  ? double.infinity
                  : MediaQuery.of(context).size.width * 0.5,
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
                      ),
                    ),
                  ),
                  SizedBox(height: 16),
                  Align(
                    alignment: Alignment.topLeft,
                    child: Text(
                      AppLocalizations.of(context)!.routingDisclaimerMessage,
                      style: TextStyle(fontSize: 14),
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
                                category: EventCategory.routingScreen
                                    .toString(),
                                action: EventAction
                                    .routingScreenDisclaimerRejected
                                    .toString(),
                                name:
                                    eventActionLabels[EventAction
                                        .routingScreenDisclaimerRejected]!,
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
                                category: EventCategory.routingScreen
                                    .toString(),
                                action: EventAction
                                    .routingScreenDisclaimerAccepted
                                    .toString(),
                                name:
                                    eventActionLabels[EventAction
                                        .routingScreenDisclaimerAccepted]!,
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

    // Initialise TTS
    await flutterTts.setSpeechRate(0.5);
    await flutterTts.setVolume(1.0);

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
      // Call routing service
      RoutingService routingService = RoutingService();
      List<ItinerarySummary> results = (await routingService.getItineraries(
        originLat: _origin.coordinates.lat,
        originLon: _origin.coordinates.lon,
        destinationLat: _destination.coordinates.lat,
        destinationLon: _destination.coordinates.lon,
        time: DateTime.now(),
        transportModes: [Mode.CAR.name],
        timeIsArrival: false,
        guidanceLanguage: Localizations.localeOf(context).toLanguageTag(),
        summarized: true,
      )).cast<ItinerarySummary>();

      // For now, always reorder by duration ascending
      results.sort((a, b) => a.duration.compareTo(b.duration));

      if (results.isNotEmpty) {
        await _fetchItineraryDetails(results.first.itineraryId);
      } else {
        setState(() {
          _processingStatus = ProcessingStatus.error;
        });
      }
    } catch (e) {
      setState(() {
        _processingStatus = ProcessingStatus.error;
      });
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
        ).startNavigation(context);
        break;
      case NavigationStatus.paused:
        Provider.of<RoutingController>(
          context,
          listen: false,
        ).resumeNavigation(context);
        break;
      case NavigationStatus.navigating:
        Provider.of<RoutingController>(
          context,
          listen: false,
        ).pauseNavigation();
        break;
      case NavigationStatus.arrived:
        Provider.of<RoutingController>(context, listen: false).stopNavigation();
        Navigator.of(context).pop();
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

  void _watchNavigationDigressingState() {
    // Check if user is digressing
    if (_navigationDigressingController.routingControllerState ==
        RoutingControllerState.digressing) {
      // Play a sound to indicate rerouting
      flutterTts.speak(
        AppLocalizations.of(context)!.routingScreenReroutingDialogTitle,
      );

      // Stop navigation
      RoutingController routingController = Provider.of<RoutingController>(
        context,
        listen: false,
      );
      routingController.stopNavigation();

      // Show rerouting dialog
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return ReroutingDialog(
            onCancel: () {
              Navigator.of(context).pop();
            },
            onConfirm: () {
              Navigator.of(context).pop();

              // Attempt to fetch new itineraries
              _fetchItineraries();

              Navigator.of(context).pop();
            },
          );
        },
      );
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

  String _getStepVoiceInstruction(leg_schema.Step step) {
    if (step.voiceInstruction != null && step.voiceInstruction!.isNotEmpty) {
      return step.voiceInstruction!;
    } else if (step.textInstruction != null &&
        step.textInstruction!.isNotEmpty) {
      return step.textInstruction!;
    } else {
      return getRelativeDirectionTextMapping(step.relativeDirection, context);
    }
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
    stepAnnouncement += _getStepVoiceInstruction(
      _navigationAudioController.instructionStep!,
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
    return PopScope(
      canPop: true,
      onPopInvokedWithResult: (didPop, result) {
        Provider.of<RoutingController>(context, listen: false).stopNavigation();
      },
      child: Scaffold(
        body: Stack(
          children: [
            Semantics(
              excludeSemantics: true,
              child: RoutingMap(destination: _destination),
            ),
            SafeArea(
              bottom: false,
              child: Consumer<RoutingController>(
                builder: (context, routingController, _) => Semantics(
                  sortKey: OrdinalSortKey(7),
                  child: OrientationBuilder(
                    builder: (context, orientation) => Align(
                      alignment: orientation == Orientation.portrait
                          ? Alignment.bottomCenter
                          : Alignment.bottomLeft,
                      child: SizedBox(
                        width: orientation == Orientation.portrait
                            ? double.infinity
                            : MediaQuery.of(context).size.width * 0.5,
                        child: Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: orientation == Orientation.portrait
                                ? 0.0
                                : 16.0,
                          ),
                          child: SlidingBottomSheet(
                            listItems:
                                _processingStatus == ProcessingStatus.completed
                                ? [
                                    ..._legTiles,
                                    orientation == Orientation.portrait
                                        ? SizedBox(height: 132)
                                        : SizedBox.shrink(),
                                  ]
                                : null,
                            body:
                                _processingStatus ==
                                        ProcessingStatus.processing ||
                                    _processingStatus == ProcessingStatus.error
                                ? NavigationProcessingTile(
                                    processingStatus: _processingStatus,
                                  )
                                : null,
                            initSize: 0.35,
                            maxSize:
                                routingController.navigationStatus ==
                                    NavigationStatus.navigating
                                ? 0.75
                                : orientation == Orientation.portrait
                                ? 0.75
                                : 0.55,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            OrientationBuilder(
              builder: (context, orientation) => Align(
                alignment: orientation == Orientation.portrait
                    ? Alignment.bottomCenter
                    : Alignment.bottomRight,
                child: SafeArea(
                  bottom: orientation == Orientation.portrait ? false : true,
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: orientation == Orientation.portrait
                          ? 0.0
                          : 16.0,
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        orientation == Orientation.portrait
                            ? Divider(
                                height: 0.0,
                                color: SmartRootsColors.maBlue,
                              )
                            : SizedBox.shrink(),
                        Container(
                          width: orientation == Orientation.portrait
                              ? double.infinity
                              : MediaQuery.of(context).size.width * 0.35,
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.surface,
                            borderRadius: orientation == Orientation.portrait
                                ? null
                                : BorderRadius.circular(16.0),
                          ),
                          padding: const EdgeInsets.symmetric(
                            vertical: 12.0,
                            horizontal: 16.0,
                          ),
                          child: SafeArea(
                            child: Material(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8.0,
                                    ),
                                    child: Consumer<NavigationStatsController>(
                                      builder: (context, navigationStatsController, _) => Semantics(
                                        excludeSemantics: true,
                                        sortKey: OrdinalSortKey(3),
                                        label:
                                            navigationStatsController
                                                        .timeToArrival !=
                                                    null &&
                                                navigationStatsController
                                                        .distanceToArrival !=
                                                    null
                                            ? AppLocalizations.of(
                                                context,
                                              )!.routingScreenNavigationStatsSemantic(
                                                TextFormatter.formatDurationText(
                                                  navigationStatsController
                                                      .timeToArrival!,
                                                ),
                                                TextFormatter.formatDistanceValueText(
                                                  navigationStatsController
                                                      .distanceToArrival!,
                                                ),
                                              )
                                            : null,
                                        child: Row(
                                          children: [
                                            Icon(
                                              Icons.directions_car_outlined,
                                              color: Theme.of(
                                                context,
                                              ).textTheme.displayMedium!.color,
                                            ),
                                            SizedBox(width: 12.0),
                                            navigationStatsController
                                                        .timeToArrival !=
                                                    null
                                                ? Text(
                                                    TextFormatter.formatDurationText(
                                                      navigationStatsController
                                                          .timeToArrival!,
                                                    ),
                                                    maxLines: 1,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    style: TextStyle(
                                                      fontSize: 16,
                                                    ),
                                                  )
                                                : SizedBox.shrink(),
                                            SizedBox(width: 6.0),
                                            Icon(
                                              Icons.circle,
                                              size: 6,
                                              color: Theme.of(
                                                context,
                                              ).textTheme.displayMedium!.color,
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
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    style: TextStyle(
                                                      fontSize: 16,
                                                    ),
                                                  )
                                                : SizedBox.shrink(),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                  SizedBox(height: 12.0),
                                  Consumer<RoutingController>(
                                    builder: (context, routingController, _) => Row(
                                      children: [
                                        Expanded(
                                          child: Semantics(
                                            sortKey: OrdinalSortKey(4),
                                            child: SheetButton(
                                              icon:
                                                  routingController
                                                          .navigationStatus ==
                                                      NavigationStatus.idle
                                                  ? Icons.play_arrow
                                                  : routingController
                                                            .navigationStatus ==
                                                        NavigationStatus
                                                            .navigating
                                                  ? Icons.pause
                                                  : routingController
                                                            .navigationStatus ==
                                                        NavigationStatus.arrived
                                                  ? Icons.check
                                                  : Icons.play_arrow,
                                              label:
                                                  routingController
                                                          .navigationStatus ==
                                                      NavigationStatus.idle
                                                  ? AppLocalizations.of(
                                                      context,
                                                    )!.routingScreenNavigationStartButton
                                                  : routingController
                                                            .navigationStatus ==
                                                        NavigationStatus
                                                            .navigating
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
                                                  routingController
                                                          .navigationStatus ==
                                                      NavigationStatus.idle
                                                  ? AppLocalizations.of(
                                                      context,
                                                    )!.routingScreenNavigationStartButton
                                                  : routingController
                                                            .navigationStatus ==
                                                        NavigationStatus
                                                            .navigating
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
                                              onTap: () =>
                                                  _toggleNavigationState(),
                                              shrinkWrap: false,
                                            ),
                                          ),
                                        ),
                                        SizedBox(width: 8),
                                        Semantics(
                                          sortKey: OrdinalSortKey(5),
                                          child: AccessibleIconButton(
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
                                        Semantics(
                                          sortKey: OrdinalSortKey(6),
                                          child: AccessibleIconButton(
                                            icon: Icons.close,
                                            semanticLabel: AppLocalizations.of(
                                              context,
                                            )!.routingScreenExitRoutingButtonSemantic,
                                            onTap: () {
                                              routingController
                                                  .stopNavigation();
                                              Navigator.of(context).pop();
                                            },
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
                        orientation == Orientation.portrait
                            ? Container(
                                height: 8.0,
                                color: Theme.of(context).colorScheme.surface,
                              )
                            : SizedBox.shrink(),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            OrientationBuilder(
              builder: (context, orientation) => Align(
                alignment: orientation == Orientation.portrait
                    ? Alignment.topCenter
                    : Alignment.topLeft,
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.only(
                      top: 16,
                      left: 16,
                      right: 16,
                    ),
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
                            sortKey: OrdinalSortKey(1),
                            child:
                                routingController.navigationStatus !=
                                    NavigationStatus.navigating
                                ? Material(
                                    elevation: 4,
                                    borderRadius: BorderRadius.only(
                                      topLeft: Radius.circular(16),
                                      topRight: Radius.circular(16),
                                    ),
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
                                        width:
                                            orientation == Orientation.portrait
                                            ? double.infinity
                                            : MediaQuery.of(
                                                    context,
                                                  ).size.width *
                                                  0.35,
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.only(
                                            topLeft: Radius.circular(16),
                                            topRight: Radius.circular(16),
                                          ),
                                        ),
                                        child: Row(
                                          children: [
                                            SizedBox(width: 16),
                                            Padding(
                                              padding: const EdgeInsets.all(
                                                2.0,
                                              ),
                                              child: Material(
                                                elevation: 2.0,
                                                borderRadius:
                                                    BorderRadius.circular(12.0),
                                                child: Container(
                                                  width: 20.0,
                                                  height: 20.0,
                                                  decoration: BoxDecoration(
                                                    shape: BoxShape.circle,
                                                    color: SmartRootsColors
                                                        .maBlueExtraDark,
                                                    border: Border.all(
                                                      color: SmartRootsColors
                                                          .maWhite,
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
                              ? SizedBox(
                                  width: orientation == Orientation.portrait
                                      ? double.infinity
                                      : MediaQuery.of(context).size.width *
                                            0.35,
                                  child: Divider(
                                    height: 0,
                                    color: SmartRootsColors.maBlue,
                                  ),
                                )
                              : SizedBox.shrink(),
                          Semantics(
                            label: AppLocalizations.of(context)!
                                .origDestPickerDestinationSemantic(
                                  _destination.id ==
                                          SmartRootsValues.userLocation
                                      ? AppLocalizations.of(
                                          context,
                                        )!.origDestCurrentLocation
                                      : _destination.name,
                                ),
                            excludeSemantics: true,
                            button: false,
                            sortKey: OrdinalSortKey(2),
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
                              child: InkWell(
                                borderRadius: BorderRadius.only(
                                  bottomLeft: Radius.circular(16),
                                  bottomRight: Radius.circular(16),
                                ),
                                onTap: () {
                                  Navigator.of(context)
                                      .push(
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              const SearchScreen(
                                                isSecondarySearch: true,
                                                isOriginPlaceSearch: false,
                                              ),
                                        ),
                                      )
                                      .then((result) {
                                        if (result is Place) {
                                          setState(() {
                                            _destination = result;
                                            routingController.stopNavigation();
                                          });
                                          _fetchItineraries();
                                        }
                                      });
                                },
                                child: Container(
                                  height: 56,
                                  width: orientation == Orientation.portrait
                                      ? double.infinity
                                      : MediaQuery.of(context).size.width *
                                            0.35,
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
                                  ),
                                  child: Row(
                                    children: [
                                      SizedBox(width: 16),
                                      _destination.type ==
                                                  PlaceType.parkingSpot ||
                                              _destination.type ==
                                                  PlaceType.parkingSite
                                          ? WidgetGenerator.getParkingPlaceIcon(
                                              _destination,
                                            )
                                          : Icon(
                                              Icons.place_rounded,
                                              color: SmartRootsColors
                                                  .maBlueExtraExtraDark,
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
                                          style: const TextStyle(fontSize: 16),
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
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class NavigationProcessingTile extends StatelessWidget {
  final ProcessingStatus processingStatus;

  const NavigationProcessingTile({required this.processingStatus, super.key});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
    child: Column(
      children: [
        Icon(
          processingStatus == ProcessingStatus.error
              ? Icons.error_outline
              : Icons.directions_car_filled_outlined,
          size: 48,
          color: SmartRootsColors.maBlue,
        ),
        SizedBox(height: 8),
        Text(
          processingStatus == ProcessingStatus.error
              ? AppLocalizations.of(context)!.navigationNoRouteFound
              : AppLocalizations.of(
                  context,
                )!.navigationGettingDrivingDirections,
          style: const TextStyle(fontSize: 16, color: SmartRootsColors.maBlue),
        ),
      ],
    ),
  );
}
