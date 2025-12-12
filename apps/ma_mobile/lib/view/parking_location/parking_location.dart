import 'dart:async';

import 'package:flutter/material.dart';
import 'package:matomo_tracker/matomo_tracker.dart';
import 'package:provider/provider.dart';
import 'package:smartroots/controllers/favorites_controller.dart';
import 'package:smartroots/core/analytics/events.dart';
import 'package:smartroots/core/config.dart';
import 'package:smartroots/core/theme/colors.dart';
import 'package:smartroots/l10n/app_localizations.dart';
import 'package:smartroots/schemas/routing/mode.dart';
import 'package:smartroots/services/poi_parking.dart';
import 'package:smartroots/view/common/accessible_icon_button.dart';
import 'package:smartroots/schemas/routing/place.dart';
import 'package:smartroots/view/common/sliding_bottom_sheet.dart';
import 'package:smartroots/view/common/sheet_button.dart';
import 'package:smartroots/view/parking_location/map.dart';
import 'dart:core';

import 'package:smartroots/services/routing.dart';
import 'package:smartroots/schemas/routing/itinerary.dart';
import 'package:smartroots/core/processing_status.dart';
import 'package:smartroots/core/utils.dart';
import 'package:maps_launcher/maps_launcher.dart';
import 'package:geolocator/geolocator.dart';
import 'package:smartroots/view/routing/routing.dart';

class ParkingLocationScreen extends StatefulWidget {
  final Place parkingLocation;
  final bool showAlternatives;
  const ParkingLocationScreen({
    required this.parkingLocation,
    this.showAlternatives = false,
    super.key,
  });

  @override
  State<StatefulWidget> createState() => _ParkingLocationScreenState();
}

class _ParkingLocationScreenState extends State<ParkingLocationScreen>
    with WidgetsBindingObserver {
  Timer? _refreshTimer;
  late Place _parkingLocation;
  bool _isFavorite = false;
  List<ItinerarySummary> _itineraries = [];
  ProcessingStatus _processingStatus = ProcessingStatus.idle;

  @override
  void initState() {
    super.initState();
    _parkingLocation = widget.parkingLocation;
    WidgetsBinding.instance.addObserver(this);
    _refreshData();
    _checkIfFavorite();
    _fetchItineraries();
  }

  Future<void> _refreshData() async {
    // Schedule periodic data refresh
    if (_refreshTimer == null || !_refreshTimer!.isActive) {
      _refreshTimer = Timer.periodic(
        Duration(seconds: Settings.dataRefreshIntervalSeconds),
        (_) => _refreshData(),
      );
    }

    // Fetch and display primary parking location
    await _fetchPrimaryParkingLocation();
  }

  Future<void> _fetchPrimaryParkingLocation() async {
    POIParkingService parkingService = POIParkingService();
    try {
      Place? parkingLocation;
      parkingLocation = await parkingService.getParkingLocationDetails(
        placeId: _parkingLocation.id,
        placeType: _parkingLocation.type,
      );

      if (parkingLocation != null) {
        setState(() {
          _parkingLocation = parkingLocation!;
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            AppLocalizations.of(context)!.errorUnableToFetchParkingSites,
          ),
        ),
      );
    }
  }

  Future<void> _checkIfFavorite() async {
    _isFavorite = await Provider.of<FavoritesController>(
      context,
      listen: false,
    ).checkIsFavorite(_parkingLocation);
    setState(() {});
  }

  Future<void> _toggleFavorite() async {
    if (_isFavorite) {
      await Provider.of<FavoritesController>(
        context,
        listen: false,
      ).removeFavorite(_parkingLocation);
    } else {
      await Provider.of<FavoritesController>(
        context,
        listen: false,
      ).addFavorite(_parkingLocation);

      // Analytics event
      MatomoTracker.instance.trackEvent(
        eventInfo: EventInfo(
          category: EventCategory.parkingLocationScreen.toString(),
          action: EventAction.parkingLocationScreenFavouriteAdded.toString(),
        ),
      );
    }
    setState(() {
      _isFavorite = !_isFavorite;
    });
  }

  Future<void> _fetchItineraries() async {
    setState(() {
      _processingStatus = ProcessingStatus.processing;
    });

    // Delay allows map to initialize
    await Future.delayed(Duration(milliseconds: 500));

    // Check location permission status
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission != LocationPermission.whileInUse &&
        permission != LocationPermission.always) {
      return;
    }

    // Fetch user location
    final userLatLng = await Geolocator.getCurrentPosition();

    try {
      // Fetch data
      RoutingService routingService = RoutingService();
      List<ItinerarySummary> results = await routingService.getItineraries(
        originLat: userLatLng.latitude,
        originLon: userLatLng.longitude,
        destinationLat: _parkingLocation.coordinates.lat,
        destinationLon: _parkingLocation.coordinates.lon,
        time: DateTime.now(),
        transportModes: [Mode.CAR.name],
        timeIsArrival: false,
      );

      setState(() {
        _itineraries = results;
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

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive) {
      // Cancel periodic data refresh
      _refreshTimer?.cancel();
    } else if (state == AppLifecycleState.resumed) {
      _refreshData();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _refreshTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          ParkingSiteMap(
            parkingLocation: _parkingLocation,
            showAlternatives: widget.showAlternatives,
          ),
          SlidingBottomSheet(
            Row(
              children: <Widget>[
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: 16.0,
                      horizontal: 24.0,
                    ),
                    child: Column(
                      children: <Widget>[
                        Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  ExcludeSemantics(
                                    child: Text(
                                      _parkingLocation.name,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        fontSize: 22,
                                        fontWeight: FontWeight.bold,
                                        color: SmartRootsColors
                                            .maBlueExtraExtraDark,
                                      ),
                                    ),
                                  ),
                                  ExcludeSemantics(
                                    child: Text(
                                      _parkingLocation.address,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        color: SmartRootsColors
                                            .maBlueExtraExtraDark,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(width: 16),
                            AccessibleIconButton(
                              onTap: () => _toggleFavorite(),
                              icon: _isFavorite
                                  ? Icons.star
                                  : Icons.star_border,
                              semanticLabel: _isFavorite
                                  ? AppLocalizations.of(
                                      context,
                                    )!.parkingLocationScreenRemoveFromFavoritesButtonSemantic
                                  : AppLocalizations.of(
                                      context,
                                    )!.parkingLocationScreenAddToFavoritesButtonSemantic,
                            ),
                          ],
                        ),
                        SizedBox(height: 16),
                        Row(
                          children: [
                            Flexible(
                              flex: 1,
                              child: SheetButton(
                                icon: Icons.directions_outlined,
                                label: AppLocalizations.of(
                                  context,
                                )!.parkingLocationButtonRouteExternal,
                                semanticLabel: AppLocalizations.of(
                                  context,
                                )!.parkingLocationScreenRouteExternalButtonSemantic,
                                onTap: () {
                                  MapsLauncher.launchCoordinates(
                                    _parkingLocation.coordinates.lat,
                                    _parkingLocation.coordinates.lon,
                                    _parkingLocation.name,
                                  ).then((value) {
                                    if (!value) {
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        SnackBar(
                                          content: Text(
                                            AppLocalizations.of(
                                              context,
                                            )!.errorUnableToLaunchRouteExternal,
                                          ),
                                        ),
                                      );
                                    }
                                  });

                                  // Analytics event
                                  MatomoTracker.instance.trackEvent(
                                    eventInfo: EventInfo(
                                      category: EventCategory
                                          .parkingLocationScreen
                                          .toString(),
                                      action: EventAction
                                          .parkingLocationScreenRouteExternalClicked
                                          .toString(),
                                    ),
                                  );
                                },
                                shrinkWrap: false,
                              ),
                            ),
                            SizedBox(width: 8),
                            Flexible(
                              flex: 1,
                              child: SheetButton(
                                icon: Icons.directions_car_outlined,
                                label: AppLocalizations.of(
                                  context,
                                )!.parkingLocationButtonStart,
                                semanticLabel: AppLocalizations.of(
                                  context,
                                )!.parkingLocationScreenRouteInternalButtonSemantic,
                                onTap: () {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (context) => RoutingScreen(
                                        parkingLocation: _parkingLocation,
                                      ),
                                    ),
                                  );

                                  // Analytics event
                                  MatomoTracker.instance.trackEvent(
                                    eventInfo: EventInfo(
                                      category: EventCategory
                                          .parkingLocationScreen
                                          .toString(),
                                      action: EventAction
                                          .parkingLocationScreenRouteInternalClicked
                                          .toString(),
                                    ),
                                  );
                                },
                                shrinkWrap: false,
                              ),
                            ),
                            /*SizedBox(width: 8),
                            Flexible(
                              flex: 2,
                              child: SheetButton(
                                icon: _isFavorite
                                    ? Icons.star
                                    : Icons.star_border,
                                label: AppLocalizations.of(
                                  context,
                                )!.parkingLocationButtonFavourite,
                                onTap: () => _toggleFavorite(),
                                shrinkWrap: false,
                              ),
                            ),*/
                          ],
                        ),
                        SizedBox(height: 16),
                        _itineraries.isNotEmpty
                            ? Semantics(
                                excludeSemantics: true,
                                label: AppLocalizations.of(context)!
                                    .parkingLocationScreenEstimatedDrivingTimeSemantic(
                                      TextFormatter.formatDurationText(
                                        _itineraries.first.duration,
                                      ),
                                    ),
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.directions_car_outlined,
                                      color:
                                          SmartRootsColors.maBlueExtraExtraDark,
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
                                      color:
                                          SmartRootsColors.maBlueExtraExtraDark,
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
                                ),
                              )
                            : SizedBox.shrink(),
                        SizedBox(height: 8.0),
                        Semantics(
                          excludeSemantics: true,
                          label: AppLocalizations.of(context)!
                              .parkingLocationScreenOccupancyStatusSemantic(
                                TextFormatter.getOccupancyText(
                                  context,
                                  _parkingLocation,
                                ),
                              ),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(4),
                                decoration: BoxDecoration(
                                  color:
                                      (widget
                                          .parkingLocation
                                          .attributes?['has_realtime_data'])
                                      ? (widget
                                                .parkingLocation
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
                              SizedBox(width: 8),
                              Text(
                                TextFormatter.getOccupancyText(
                                  context,
                                  _parkingLocation,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color: SmartRootsColors.maBlueExtraExtraDark,
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            listItems: [],
            initSize: 0.35,
            maxSize: 0.35,
          ),
          SafeArea(
            child: Align(
              alignment: Alignment.topCenter,
              child: Padding(
                padding: const EdgeInsets.only(top: 32, left: 16, right: 16),
                child: Material(
                  elevation: 4,
                  borderRadius: BorderRadius.circular(28),
                  child: Semantics(
                    label: AppLocalizations.of(
                      context,
                    )!.placeScreenSearchBarSemantic(_parkingLocation.name),
                    excludeSemantics: true,
                    button: true,
                    focused: true,
                    child: InkWell(
                      onTap: () => Navigator.of(context).pop(),
                      child: Container(
                        height: 56,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(32),
                          color: Theme.of(context).colorScheme.secondary,
                        ),
                        child: Row(
                          children: [
                            IconButton(
                              icon: const Icon(
                                Icons.arrow_back,
                                color: SmartRootsColors.maBlueExtraExtraDark,
                              ),
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                            ),
                            Expanded(
                              child: Text(
                                _parkingLocation.name,
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
                    ),
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
