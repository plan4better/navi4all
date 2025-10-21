import 'package:flutter/material.dart';
import 'package:smartroots/core/theme/colors.dart';
import 'package:smartroots/l10n/app_localizations.dart';
import 'package:smartroots/view/search/search.dart';
import 'package:smartroots/schemas/routing/place.dart';
import 'package:smartroots/view/common/sliding_bottom_sheet.dart';
import 'package:smartroots/view/common/sheet_button.dart';
import 'package:smartroots/view/parking_site/map.dart';
import 'dart:core';

import 'package:intl/intl.dart';
import 'package:smartroots/services/routing.dart';
import 'package:smartroots/schemas/routing/itinerary.dart';
import 'package:smartroots/core/persistence/processing_status.dart';
import 'package:smartroots/core/utils.dart';
import 'package:maps_launcher/maps_launcher.dart';
import 'package:smartroots/core/persistence/preference_helper.dart';
import 'package:geolocator/geolocator.dart';
import 'package:smartroots/view/routing/routing.dart';

class ParkingSiteScreen extends StatefulWidget {
  final Place? place;
  final Map<String, dynamic> parkingLocation;
  const ParkingSiteScreen({
    this.place,
    required this.parkingLocation,
    super.key,
  });

  @override
  State<StatefulWidget> createState() => _ParkingSiteScreenState();
}

class _ParkingSiteScreenState extends State<ParkingSiteScreen> {
  bool _isFavorite = false;
  List<ItinerarySummary> _itineraries = [];
  ProcessingStatus _processingStatus = ProcessingStatus.idle;

  @override
  void initState() {
    super.initState();
    _checkIfFavorite();
    _fetchItineraries();
  }

  Future<void> _checkIfFavorite() async {
    _isFavorite = await PreferenceHelper.isFavoriteParkingLocation(
      widget.parkingLocation["id"],
      widget.parkingLocation["parking_type"],
    );
    setState(() {});
  }

  Future<void> _toggleFavorite() async {
    if (_isFavorite) {
      await PreferenceHelper.removeFavoriteParkingLocation(
        widget.parkingLocation["id"],
        widget.parkingLocation["parking_type"],
      );
    } else {
      await PreferenceHelper.addFavoriteParkingLocation(
        widget.parkingLocation["id"],
        widget.parkingLocation["parking_type"],
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

    // Check location permission status
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission != LocationPermission.whileInUse &&
        permission != LocationPermission.always) {
      return;
    }

    // Fetch user location
    final userLatLng = await Geolocator.getCurrentPosition();

    List<ItinerarySummary> itineraries = [];
    RoutingService routingService = RoutingService();
    try {
      final response = await routingService.getItineraries(
        originLat: userLatLng.latitude,
        originLon: userLatLng.longitude,
        destinationLat: widget.parkingLocation['coordinates'].latitude,
        destinationLon: widget.parkingLocation['coordinates'].longitude,
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          ParkingSiteMap(parkingSite: widget.parkingLocation),
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
                                  Text(
                                    widget.parkingLocation["name"],
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontSize: 22,
                                      fontWeight: FontWeight.bold,
                                      color:
                                          SmartRootsColors.maBlueExtraExtraDark,
                                    ),
                                  ),
                                  widget.parkingLocation["address"] != null
                                      ? Text(
                                          widget.parkingLocation["address"],
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                            color: SmartRootsColors
                                                .maBlueExtraExtraDark,
                                          ),
                                        )
                                      : SizedBox.shrink(),
                                ],
                              ),
                            ),
                            SizedBox(width: 16),
                            IconButton(
                              onPressed: () => _toggleFavorite(),
                              icon: Icon(
                                color: SmartRootsColors.maBlueExtraExtraDark,
                                size: 28,
                                _isFavorite ? Icons.star : Icons.star_border,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 16),
                        Row(
                          children: [
                            Flexible(
                              flex: 1,
                              child: SheetButton(
                                icon: Icons.directions_car_outlined,
                                label: AppLocalizations.of(
                                  context,
                                )!.parkingLocationButtonStart,
                                onTap: () {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (context) => RoutingScreen(
                                        parkingSite: widget.parkingLocation,
                                      ),
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
                                icon: Icons.directions_outlined,
                                label: AppLocalizations.of(
                                  context,
                                )!.parkingLocationButtonRouteExternal,
                                onTap: () {
                                  MapsLauncher.launchCoordinates(
                                    widget
                                        .parkingLocation['coordinates']
                                        .latitude,
                                    widget
                                        .parkingLocation['coordinates']
                                        .longitude,
                                    widget.parkingLocation['name'],
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
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                color:
                                    widget.parkingLocation['has_realtime_data']
                                    ? widget.parkingLocation['disabled_parking_available']
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
                              getOccupancyText(context, widget.parkingLocation),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: SmartRootsColors.maBlueExtraExtraDark,
                                fontSize: 16,
                              ),
                            ),
                          ],
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
                  child: InkWell(
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => const SearchScreen(),
                        ),
                      );
                    },
                    child: Container(
                      height: 56,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(28),
                        color: SmartRootsColors.maWhite,
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
                              widget.parkingLocation["name"],
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
        ],
      ),
    );
  }
}
