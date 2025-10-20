import 'dart:async';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:smartroots/core/theme/colors.dart';
import 'package:smartroots/core/theme/values.dart';
import 'package:smartroots/l10n/app_localizations.dart';
import 'package:smartroots/schemas/routing/coordinates.dart';
import 'package:smartroots/view/routing/map.dart';
import 'package:smartroots/view/common/sliding_bottom_sheet.dart';
import 'package:smartroots/view/common/sheet_button.dart';
import 'package:smartroots/view/search/search.dart';
import 'package:smartroots/schemas/routing/itinerary.dart';
import 'package:smartroots/core/persistence/processing_status.dart';
import 'package:smartroots/services/routing.dart';
import 'package:geolocator/geolocator.dart';
import 'package:smartroots/schemas/routing/leg.dart' as leg_schema;
import 'package:smartroots/schemas/routing/mode.dart';
import 'package:smartroots/schemas/routing/place.dart';
import 'package:smartroots/core/utils.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:maps_toolkit/maps_toolkit.dart';

class RoutingScreen extends StatefulWidget {
  final Map<String, dynamic> parkingSite;

  const RoutingScreen({required this.parkingSite, super.key});

  @override
  RoutingState createState() => RoutingState();
}

class RoutingState extends State<RoutingScreen> {
  bool disclaimerAccepted = false;
  final FlutterTts flutterTts = FlutterTts();
  late Place _origin;
  late Place _destination;
  List<ItinerarySummary> _itineraries = [];
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
    _origin = Place(
      id: SmartRootsValues.userLocation,
      name: '',
      type: '',
      description: '',
      address: '',
      coordinates: Coordinates(lat: 0.0, lon: 0.0),
    );
    _destination = Place(
      id: widget.parkingSite['id'].toString(),
      type: 'PARKING',
      name: widget.parkingSite['name'],
      description: widget.parkingSite['description'] ?? '',
      address: widget.parkingSite['address'] ?? '',
      coordinates: Coordinates(
        lat: widget.parkingSite['coordinates'].latitude,
        lon: widget.parkingSite['coordinates'].longitude,
      ),
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
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(32),
          ),
          backgroundColor: SmartRootsColors.maWhite,
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
          type: '',
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
          type: '',
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
      }

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

  Future<void> _fetchItineraryDetails(String itineraryId) async {
    setState(() {
      _processingStatus = ProcessingStatus.processing;
    });

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
          RoutingMap(
            origin: _origin,
            parkingSite: widget.parkingSite,
            itineraryDetails: _itineraryDetails,
            navigationStatus: _navigationStatus,
            userPosition: _userPosition,
          ),
          SlidingBottomSheet(
            Row(
              children: <Widget>[
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    child: Column(
                      children: <Widget>[
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  SizedBox(height: 16),
                                  Text(
                                    widget.parkingSite["name"],
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontSize: 22,
                                      fontWeight: FontWeight.bold,
                                      color:
                                          SmartRootsColors.maBlueExtraExtraDark,
                                    ),
                                  ),
                                  Text(
                                    widget.parkingSite["address"],
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      color:
                                          SmartRootsColors.maBlueExtraExtraDark,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(width: 8),
                            IconButton(
                              icon: const Icon(
                                Icons.close,
                                color: SmartRootsColors.maBlueExtraExtraDark,
                              ),
                              onPressed: () {
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
                        Row(
                          children: [
                            Flexible(
                              flex: 3,
                              child: SheetButton(
                                icon: _navigationStatus == NavigationStatus.idle
                                    ? Icons.play_arrow
                                    : _navigationStatus ==
                                          NavigationStatus.navigating
                                    ? Icons.pause
                                    : _navigationStatus ==
                                          NavigationStatus.arrived
                                    ? Icons.check
                                    : Icons.play_arrow,
                                label:
                                    _navigationStatus == NavigationStatus.idle
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
                                shrinkWrap: false,
                              ),
                            ),
                            SizedBox(width: 8),
                            Flexible(
                              flex: 1,
                              child: SheetButton(
                                icon: _audioStatus == AudioStatus.muted
                                    ? Icons.volume_off
                                    : Icons.volume_up,
                                onTap: () => _toggleAudioState(),
                                shrinkWrap: false,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 16),
                        _itineraries.isNotEmpty
                            ? Row(
                                children: [
                                  Icon(
                                    Icons.directions_car_outlined,
                                    color:
                                        SmartRootsColors.maBlueExtraExtraDark,
                                  ),
                                  SizedBox(width: 8.0),
                                  Text(
                                    '${_itineraries.first.duration ~/ 60} min',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      color:
                                          SmartRootsColors.maBlueExtraExtraDark,
                                      fontSize: 16,
                                    ),
                                  ),
                                  SizedBox(width: 6.0),
                                  Icon(
                                    Icons.circle,
                                    size: 6,
                                    color:
                                        SmartRootsColors.maBlueExtraExtraDark,
                                  ),
                                  SizedBox(width: 6.0),
                                  Text(
                                    getItineraryDistanceText(
                                      _itineraries.first,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      color:
                                          SmartRootsColors.maBlueExtraExtraDark,
                                      fontSize: 16,
                                    ),
                                  ),
                                ],
                              )
                            : SizedBox.shrink(),
                        SizedBox(height: 16.0),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            listItems:
                _navigationStatus == NavigationStatus.idle ||
                    _navigationStatus == NavigationStatus.paused
                ? _processingStatus == ProcessingStatus.completed &&
                          _itineraries.isNotEmpty
                      ? [
                          ItinerarySummaryTile(
                            itinerarySummary: _itineraries.first,
                          ),
                        ]
                      : []
                : _navigationStatus == NavigationStatus.navigating
                ? _legSteps
                : [],
            initSize: 0.35,
            maxSize: 0.7,
          ),
          SafeArea(
            child: Align(
              alignment: Alignment.topCenter,
              child: Padding(
                padding: const EdgeInsets.only(top: 32, left: 16, right: 16),
                child: Material(
                  elevation: 4,
                  borderRadius: BorderRadius.circular(28),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      InkWell(
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(28),
                          topRight: Radius.circular(28),
                        ),
                        onTap: () {
                          Navigator.of(context)
                              .push(
                                MaterialPageRoute(
                                  builder: (context) => const SearchScreen(
                                    isSecondarySearch: true,
                                    isOriginPlaceSearch: true,
                                  ),
                                ),
                              )
                              .then((result) {
                                if (result is Place) {
                                  setState(() {
                                    _origin = result;
                                    _navigationStatus = NavigationStatus.idle;
                                  });
                                  _fetchItineraries();
                                }
                              });
                        },
                        child: Container(
                          height: 56,
                          decoration: BoxDecoration(
                            color: SmartRootsColors.maWhite,
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(28),
                              topRight: Radius.circular(28),
                            ),
                          ),
                          child: Row(
                            children: [
                              SizedBox(width: 16),
                              Icon(
                                Icons.place_outlined,
                                color: SmartRootsColors.maBlueExtraExtraDark,
                              ),
                              SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  _origin.id == SmartRootsValues.userLocation
                                      ? AppLocalizations.of(
                                          context,
                                        )!.origDestCurrentLocation
                                      : _origin.name,
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
                      Divider(height: 0, color: SmartRootsColors.maBlue),
                      Container(
                        height: 56,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.only(
                            bottomLeft: Radius.circular(28),
                            bottomRight: Radius.circular(28),
                          ),
                          color: SmartRootsColors.maWhite,
                        ),
                        child: Row(
                          children: [
                            SizedBox(width: 16),
                            Container(
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                color: widget.parkingSite['has_realtime_data']
                                    ? widget.parkingSite['occupied_disabled'] !=
                                                  null &&
                                              widget.parkingSite['occupied_disabled'] <
                                                  widget
                                                      .parkingSite['capacity_disabled']
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
                                _destination.id == SmartRootsValues.userLocation
                                    ? AppLocalizations.of(
                                        context,
                                      )!.origDestCurrentLocation
                                    : _destination.name,
                                style: const TextStyle(
                                  fontSize: 16,
                                  color: SmartRootsColors.maBlueExtraExtraDark,
                                ),
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                              ),
                            ),
                            SizedBox(width: 16),
                          ],
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

class ItinerarySummaryTile extends StatelessWidget {
  final ItinerarySummary itinerarySummary;

  const ItinerarySummaryTile({required this.itinerarySummary, super.key});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
    child: SizedBox.shrink(),
  );
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
    padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 24),
    color: isActive ? SmartRootsColors.maBlueLight : SmartRootsColors.maWhite,
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
  );
}
