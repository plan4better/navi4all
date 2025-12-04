import 'package:flutter/material.dart';
import 'package:matomo_tracker/matomo_tracker.dart';
import 'package:smartroots/core/analytics/events.dart';
import 'package:smartroots/core/config.dart';
import 'package:smartroots/core/theme/colors.dart';
import 'package:smartroots/l10n/app_localizations.dart';
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
  List<Place> _parkingLocations = [];

  @override
  void initState() {
    _fetchParkingSites();
    super.initState();
  }

  Future<void> _fetchParkingSites() async {
    POIParkingService parkingService = POIParkingService();
    try {
      List<Place> result;
      (result, _) = await parkingService.getParkingLocations(
        focusPoint: widget.place.coordinates,
        radius: _selectedRadius,
      );

      setState(() {
        _parkingLocations = result;
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
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Theme.of(context).colorScheme.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(32),
          ),
          child: Semantics(
            label: AppLocalizations.of(context)!.placeScreenChangeRadiusButton,
            focused: true,
            child: Container(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Align(
                    alignment: Alignment.topLeft,
                    child: Semantics(
                      excludeSemantics: true,
                      child: Text(
                        AppLocalizations.of(
                          context,
                        )!.placeScreenChangeRadiusButton,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: SmartRootsColors.maBlueExtraExtraDark,
                        ),
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
                          labelWidget: Semantics(
                            excludeSemantics: true,
                            label: '${value}m',
                            focused: _changedRadius == value,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                SizedBox(width: 16),
                                Expanded(
                                  child: Text(
                                    '${value}m',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      color:
                                          SmartRootsColors.maBlueExtraExtraDark,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
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
                                action: EventAction
                                    .placeScreenSearchRadiusChanged
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          PlaceMap(place: widget.place, radius: _selectedRadius),
          Semantics(
            label: AppLocalizations.of(
              context,
            )!.placeScreenSemantic(_parkingLocations.length, _selectedRadius),
            child: SlidingBottomSheet(
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
                            child: Semantics(
                              excludeSemantics: true,
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
                          ),
                          Align(
                            alignment: Alignment.topLeft,
                            child: Semantics(
                              excludeSemantics: true,
                              child: Text(
                                widget.place.description,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color: SmartRootsColors.maBlueExtraExtraDark,
                                ),
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
                              semanticLabel: AppLocalizations.of(context)!
                                  .placeScreenSearchRadiusButtonSemantic(
                                    _selectedRadius,
                                  ),
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
                for (Place parkingLocation in _parkingLocations)
                  PlaceListItem(
                    place: widget.place,
                    parkingLocation: parkingLocation,
                  ),
              ],
            ),
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
                    )!.placeScreenSearchBarSemantic(widget.place.name),
                    excludeSemantics: true,
                    button: true,
                    focused: true,
                    child: InkWell(
                      onTap: () {
                        Navigator.of(context).pop();
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
          ),
        ],
      ),
    );
  }
}

class PlaceListItem extends StatelessWidget {
  final Place place;
  final Place parkingLocation;
  const PlaceListItem({
    required this.place,
    required this.parkingLocation,
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
              parkingLocation: parkingLocation,
            ),
          ),
        );
      },
      child: Semantics(
        excludeSemantics: true,
        label: AppLocalizations.of(context)!.placeListItemSemantic(
          parkingLocation.name,
          TextFormatter.getOccupancyText(context, parkingLocation),
        ),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      parkingLocation.name,
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
                TextFormatter.getOccupancyText(context, parkingLocation),
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
                  color: (parkingLocation.attributes?['has_realtime_data'])
                      ? (parkingLocation
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
            ],
          ),
        ),
      ),
    );
  }
}
