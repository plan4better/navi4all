import 'dart:async';

import 'package:flutter/material.dart';
import 'package:navi4all/controllers/itinerary_controller.dart';
import 'package:navi4all/view/routing/rerouting_dialog.dart';
import 'package:provider/provider.dart';
import 'package:navi4all/controllers/routing_controller.dart';
import 'package:navi4all/core/theme/colors.dart';
import 'package:navi4all/core/theme/values.dart';
import 'package:navi4all/l10n/app_localizations.dart';
import 'package:navi4all/schemas/routing/audio_stage.dart';
import 'package:navi4all/schemas/routing/coordinates.dart';
import 'package:navi4all/view/common/accessible_icon_button.dart';
import 'package:navi4all/view/routing/leg_tile.dart';
import 'package:navi4all/view/routing/map.dart';
import 'package:navi4all/view/common/sliding_bottom_sheet.dart';
import 'package:navi4all/view/common/sheet_button.dart';
import 'package:navi4all/schemas/routing/itinerary.dart';
import 'package:navi4all/core/processing_status.dart';
import 'package:navi4all/services/routing.dart';
import 'package:navi4all/schemas/routing/mode.dart';
import 'package:navi4all/schemas/routing/place.dart';
import 'package:navi4all/core/utils.dart';
import 'package:flutter_tts/flutter_tts.dart';

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
  late ItineraryController _itineraryController;
  late NavigationInstructionsController _navigationInstructionsController;
  late NavigationAudioController _navigationAudioController;
  late NavigationDigressingController _navigationDigressingController;
  bool disclaimerAccepted = false;
  final FlutterTts flutterTts = FlutterTts();
  ProcessingStatus _processingStatus = ProcessingStatus.idle;
  List<LegTile> _legTiles = [];

  @override
  void initState() {
    super.initState();

    _itineraryController = Provider.of<ItineraryController>(
      context,
      listen: false,
    );
    _itineraryController.addListener(_onItinerariesRefreshed);
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
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Navi4AllColors.klRed,
                    ),
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

  Future<void> _fetchItineraries() async {
    setState(() {
      _processingStatus = ProcessingStatus.processing;
    });

    // Delay allows map to initialize
    await Future.delayed(Duration(milliseconds: 500));

    // Initialise TTS language
    await flutterTts.setLanguage(AppLocalizations.of(context)!.localeName);

    try {
      await _fetchItineraryDetails(widget.itinerarySummary.itineraryId);
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
            AppLocalizations.of(context)!.errorUnableToFetchItineraries,
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

  void _watchNavigationDigressingState() {
    // Check if user is digressing
    if (_navigationDigressingController.routingControllerState ==
        RoutingControllerState.digressing) {
      // Play a sound to indicate rerouting
      flutterTts.speak(
        AppLocalizations.of(context)!.routingScreenReroutingDialogTitle,
      );

      // If primary mode is not transit, attempt to reroute automatically
      if (_itineraryController.primaryMode != Mode.TRANSIT) {
        // Refresh itineraries
        if (_itineraryController.hasParametersSet) {
          _itineraryController.setParameters(
            context: context,
            originPlace: Place(
              id: Navi4AllValues.userLocation,
              name: '',
              type: PlaceType.address,
              description: '',
              address: '',
              coordinates: Coordinates(lat: 0, lon: 0),
            ),
            destinationPlace: _itineraryController.destinationPlace!,
            time: DateTime.now(),
            primaryMode: _itineraryController.primaryMode!,
          );
          return;
        }
      }

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

              // Refresh itineraries
              if (_itineraryController.hasParametersSet) {
                _itineraryController.setParameters(
                  context: context,
                  originPlace: _itineraryController.originPlace!,
                  destinationPlace: _itineraryController.destinationPlace!,
                  time: _itineraryController.time!,
                  primaryMode: _itineraryController.primaryMode!,
                );
              }

              Navigator.of(context).pop();
            },
          );
        },
      );
    }
  }

  Future<void> _onItinerariesRefreshed() async {
    // Confirm itinerary controller has completed refreshing
    if (_itineraryController.state != ItineraryControllerState.idle) {
      return;
    }

    // Confirm this refrsh is the result of digressing
    if (_navigationDigressingController.routingControllerState !=
        RoutingControllerState.digressing) {
      return;
    }

    // Ensure new itineraries were found
    if (_itineraryController.itineraries.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.navigationNoRouteFound),
        ),
      );
      flutterTts.speak(AppLocalizations.of(context)!.navigationNoRouteFound);
      return;
    }

    // Stop navigation
    RoutingController routingController = Provider.of<RoutingController>(
      context,
      listen: false,
    );
    routingController.stopNavigation();

    // Prepare navigation with new itinerary
    await _fetchItineraryDetails(
      _itineraryController.itineraries.first.itineraryId,
    );

    // Restart navigation
    routingController.startNavigation();
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
    _itineraryController.removeListener(_onItinerariesRefreshed);
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
          RoutingMap(destination: widget.destinationPlace),
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
                                          Icons.place_rounded,
                                          color: Theme.of(
                                            context,
                                          ).textTheme.displayMedium?.color,
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
                                                  color: Navi4AllColors.klRed,
                                                  fontSize: 16,
                                                ),
                                              )
                                            : SizedBox.shrink(),
                                        SizedBox(width: 6.0),
                                        Icon(
                                          Icons.circle,
                                          size: 6,
                                          color: Navi4AllColors.klRed,
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
                                                  color: Navi4AllColors.klRed,
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
                        Divider(height: 0, color: Navi4AllColors.klPink),
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
                              widget.originPlace.id ==
                                      Navi4AllValues.userLocation
                                  ? AppLocalizations.of(
                                      context,
                                    )!.origDestCurrentLocation
                                  : widget.originPlace.name,
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
                                  onTap: null,
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
                                                color: Navi4AllColors.klRed,
                                                border: Border.all(
                                                  color: Navi4AllColors.klWhite,
                                                  width: 3.0,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                        SizedBox(width: 12),
                                        Expanded(
                                          child: Text(
                                            widget.originPlace.id ==
                                                    Navi4AllValues.userLocation
                                                ? AppLocalizations.of(
                                                    context,
                                                  )!.origDestCurrentLocation
                                                : widget.originPlace.name,
                                            style: const TextStyle(
                                              fontSize: 16,
                                              color: Navi4AllColors.klRed,
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
                          ? Divider(height: 0, color: Navi4AllColors.klPink)
                          : SizedBox.shrink(),
                      Semantics(
                        label: AppLocalizations.of(context)!
                            .origDestPickerDestinationSemantic(
                              widget.destinationPlace.id ==
                                      Navi4AllValues.userLocation
                                  ? AppLocalizations.of(
                                      context,
                                    )!.origDestCurrentLocation
                                  : widget.destinationPlace.name,
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
                                Icon(
                                  Icons.place_rounded,
                                  color: Navi4AllColors.klRed,
                                ),
                                SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    widget.destinationPlace.id ==
                                            Navi4AllValues.userLocation
                                        ? AppLocalizations.of(
                                            context,
                                          )!.origDestCurrentLocation
                                        : widget.destinationPlace.name,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      color: Navi4AllColors.klRed,
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
