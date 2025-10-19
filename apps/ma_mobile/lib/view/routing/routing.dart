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

class RoutingScreen extends StatefulWidget {
  final Map<String, dynamic> parkingSite;

  const RoutingScreen({required this.parkingSite, super.key});

  @override
  RoutingState createState() => RoutingState();
}

class RoutingState extends State<RoutingScreen> {
  late Place _origin;
  late Place _destination;
  List<ItinerarySummary> _itineraries = [];
  ItineraryDetails? _itineraryDetails;
  ProcessingStatus _processingStatus = ProcessingStatus.idle;
  NavigationStatus _navigationStatus = NavigationStatus.idle;
  AudioStatus _audioStatus = AudioStatus.unmuted;

  @override
  void initState() {
    super.initState();

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
    _fetchItineraries();
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
    setState(() {
      _navigationStatus = _navigationStatus == NavigationStatus.navigating
          ? NavigationStatus.paused
          : NavigationStatus.navigating;
    });

    if (_navigationStatus == NavigationStatus.navigating) {
      // Resume navigation logic here
    } else if (_navigationStatus == NavigationStatus.paused) {
      // Pause navigation logic here
    } else if (_navigationStatus == NavigationStatus.arrived) {
      // Arrival logic here
    }
  }

  void _toggleAudioState() {
    setState(() {
      _audioStatus = _audioStatus == AudioStatus.muted
          ? AudioStatus.unmuted
          : AudioStatus.muted;
    });

    // Mute/unmute audio logic here
  }

  List<ItineraryLegStepTile> get _legSteps {
    if (_itineraryDetails == null || _itineraryDetails!.legs.isEmpty) return [];
    return _itineraryDetails!.legs.first.steps
        .map((step) => ItineraryLegStepTile(step: step))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          RoutingMap(
            parkingSite: widget.parkingSite,
            itineraries: _itineraries,
            navigationStatus: _navigationStatus,
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
                            Column(
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
                            SizedBox(width: 8),
                            Spacer(),
                            IconButton(
                              icon: const Icon(
                                Icons.close,
                                color: SmartRootsColors.maBlueExtraExtraDark,
                              ),
                              onPressed: () {
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
                        SizedBox(height: 8.0),
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

  const ItineraryLegStepTile({required this.step, super.key});

  String? get _streetName {
    return step.bogusName ? null : step.streetName;
  }

  String get _distance {
    if (step.distance >= 1000) {
      return '${(step.distance / 1000).toStringAsFixed(1)} km';
    } else {
      return '${step.distance.toStringAsFixed(0)} m';
    }
  }

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 24),
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
            ],
          ),
        ),
        SizedBox(width: 8),
        Text(
          _distance,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            fontSize: 16,
            color: SmartRootsColors.maBlueExtraExtraDark,
          ),
        ),
      ],
    ),
  );
}
