import 'package:flutter/material.dart';
import 'package:matomo_tracker/matomo_tracker.dart';
import 'package:smartroots/core/analytics/events.dart';
import 'package:smartroots/core/config.dart';
import 'package:smartroots/core/theme/colors.dart';
import 'package:smartroots/l10n/app_localizations.dart';
import 'package:smartroots/view/search/search.dart';
import 'package:smartroots/schemas/routing/place.dart';
import 'package:smartroots/view/common/sliding_bottom_sheet.dart';
import 'package:smartroots/view/place/map.dart';
import 'dart:core';
import 'package:smartroots/view/parking_location/parking_location.dart';

import 'package:smartroots/services/poi_parking.dart';
import 'package:smartroots/view/common/sheet_button.dart';
import 'package:smartroots/core/utils.dart';

class PlaceScreen extends StatefulWidget {
  final Place place;
  const PlaceScreen({required this.place, super.key});

  @override
  State<StatefulWidget> createState() => _PlaceScreenState();
}

class _PlaceScreenState extends State<PlaceScreen> {
  int _selectedRadius = Settings.defaultRadius;
  int _changedRadius = Settings.defaultRadius;
  List<Map<String, dynamic>> _parkingSites = [];

  @override
  void initState() {
    _fetchParkingSites();
    super.initState();
  }

  Future<void> _fetchParkingSites() async {
    POIParkingService parkingService = POIParkingService();
    try {
      List<Map<String, dynamic>> result = await parkingService
          .getParkingLocations(
            focusPointLat: widget.place.coordinates.lat,
            focusPointLon: widget.place.coordinates.lon,
            radius: _selectedRadius,
          );

      setState(() {
        _parkingSites = result;
      });
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

  void _changeRadiusOnTap() {
    showDialog(
      context: context,
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
                    AppLocalizations.of(context)!.placeScreenChangeRadiusButton,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: SmartRootsColors.maBlueExtraExtraDark,
                    ),
                  ),
                ),
                SizedBox(height: 32),
                DropdownMenu(
                  inputDecorationTheme: InputDecorationTheme(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  textStyle: TextStyle(
                    color: SmartRootsColors.maBlueExtraExtraDark,
                    fontWeight: FontWeight.bold,
                  ),
                  dropdownMenuEntries: [
                    for (var value in Settings.radiusOptions)
                      DropdownMenuEntry(
                        value: value,
                        label: '${value}m',
                        labelWidget: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            SizedBox(width: 16),
                            Expanded(
                              child: Text(
                                '${value}m',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color: SmartRootsColors.maBlueExtraExtraDark,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                  initialSelection: _selectedRadius,
                  onSelected: (value) {
                    setState(() {
                      _changedRadius = value as int;
                    });
                  },
                ),
                SizedBox(height: 32),
                Row(
                  children: [
                    Expanded(
                      child: SheetButton(
                        label: AppLocalizations.of(
                          context,
                        )!.placeScreenChangeRadiusCancel,
                        onTap: () {
                          _changedRadius = _selectedRadius;
                          Navigator.of(context).pop();
                        },
                      ),
                    ),
                    SizedBox(width: 8),
                    Expanded(
                      child: SheetButton(
                        label: AppLocalizations.of(
                          context,
                        )!.placeScreenChangeRadiusConfirm,
                        onTap: () {
                          setState(() {
                            _selectedRadius = _changedRadius;
                            _fetchParkingSites();
                            Navigator.of(context).pop();
                          });

                          // Analytics event
                          MatomoTracker.instance.trackEvent(
                            eventInfo: EventInfo(
                              category: EventCategory.placeScreen.toString(),
                              action: EventAction.placeScreenSearchRadiusChanged
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          PlaceMap(place: widget.place, radius: _selectedRadius),
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
                        Align(
                          alignment: Alignment.topLeft,
                          child: Text(
                            widget.place.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: SmartRootsColors.maBlueExtraExtraDark,
                            ),
                          ),
                        ),
                        Align(
                          alignment: Alignment.topLeft,
                          child: Text(
                            widget.place.description,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: SmartRootsColors.maBlueExtraExtraDark,
                            ),
                          ),
                        ),
                        SizedBox(height: 16),
                        Align(
                          alignment: Alignment.topLeft,
                          child: SheetButton(
                            label: AppLocalizations.of(
                              context,
                            )!.placeScreenChangeRadiusButton,
                            onTap: () => _changeRadiusOnTap(),
                            shrinkWrap: true,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            listItems: [
              for (var site in _parkingSites)
                PlaceListItem(place: widget.place, parkingSite: site),
            ],
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
                              widget.place.name,
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

class PlaceListItem extends StatelessWidget {
  final Place place;
  final Map<String, dynamic> parkingSite;
  const PlaceListItem({
    required this.place,
    required this.parkingSite,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => ParkingLocationScreen(
              place: place,
              parkingLocation: parkingSite,
            ),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    parkingSite["name"],
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: SmartRootsColors.maBlueExtraExtraDark,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        Icons.directions_car_outlined,
                        color: SmartRootsColors.maBlueExtraExtraDark,
                        size: 20,
                      ),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          '',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: SmartRootsColors.maBlueExtraExtraDark,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(width: 16),
            Text(
              TextFormatter.getOccupancyText(context, parkingSite),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: SmartRootsColors.maBlueExtraExtraDark,
                fontSize: 16,
              ),
            ),
            SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: parkingSite['has_realtime_data']
                    ? parkingSite['disabled_parking_available']
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
          ],
        ),
      ),
    );
  }
}
