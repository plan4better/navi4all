import 'package:flutter/material.dart';
import 'package:navi4all/controllers/canvas_controller.dart';
import 'package:navi4all/controllers/itinerary_controller.dart';
import 'package:navi4all/controllers/place_controller.dart';
import 'package:navi4all/core/theme/values.dart';
import 'package:navi4all/core/utils.dart';
import 'package:navi4all/schemas/routing/coordinates.dart';
import 'package:navi4all/schemas/routing/mode.dart';
// import 'package:matomo_tracker/matomo_tracker.dart';
import 'package:provider/provider.dart';
import 'package:navi4all/controllers/favorites_controller.dart';
// import 'package:navi4all/core/analytics/events.dart';
import 'package:navi4all/core/theme/colors.dart';
import 'package:navi4all/l10n/app_localizations.dart';
import 'package:navi4all/schemas/routing/place.dart';
import 'package:navi4all/view/common/sheet_button.dart';
import 'dart:core';

import 'package:geolocator/geolocator.dart';
// import 'package:navi4all/view/routing/routing.dart';

class PlaceScreen extends StatefulWidget {
  const PlaceScreen({super.key});

  @override
  State<StatefulWidget> createState() => _PlaceScreenState();
}

class _PlaceScreenState extends State<PlaceScreen> {
  bool _isFavorite = false;

  @override
  void initState() {
    _checkIfFavorite(
      Provider.of<PlaceController>(context, listen: false).place!,
    );
    _fetchItineraries();

    super.initState();
  }

  Future<void> _checkIfFavorite(Place place) async {
    _isFavorite = await Provider.of<FavoritesController>(
      context,
      listen: false,
    ).checkIsFavorite(place.id);
    setState(() {});
  }

  Future<void> _toggleFavorite(Place place) async {
    if (_isFavorite) {
      await Provider.of<FavoritesController>(
        context,
        listen: false,
      ).removeFavorite(place.id);
    } else {
      await Provider.of<FavoritesController>(
        context,
        listen: false,
      ).addFavorite(place);

      // Analytics event
      /* MatomoTracker.instance.trackEvent(
        eventInfo: EventInfo(
          category: EventCategory.parkingLocationScreen.toString(),
          action: EventAction.parkingLocationScreenFavouriteAdded.toString(),
        ),
      ); */
    }
    setState(() {
      _isFavorite = !_isFavorite;
    });
  }

  Future<void> _fetchItineraries() async {
    // Check location permission status
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission != LocationPermission.whileInUse &&
        permission != LocationPermission.always) {
      return;
    }

    // Fetch user location
    /* final userLatLng = await Geolocator.getCurrentPosition();
    Place originPlace = Place(
      id: Navi4AllValues.userLocation,
      name: Navi4AllValues.userLocation,
      type: PlaceType.address,
      description: '',
      address: '',
      coordinates: Coordinates(
        lat: userLatLng.latitude,
        lon: userLatLng.longitude,
      ),
    ); */
    // TODO: Remove
    Place originPlace = Place(
      id: Navi4AllValues.userLocation,
      name: Navi4AllValues.userLocation,
      type: PlaceType.address,
      description: '',
      address: '',
      coordinates: Coordinates(lat: 49.4305700521414, lon: 7.726379027294111),
    );

    Place destinationPlace = Provider.of<PlaceController>(
      context,
      listen: false,
    ).place!;

    // Set itinerary parameters
    Provider.of<ItineraryController>(context, listen: false).setParameters(
      originPlace: originPlace,
      destinationPlace: destinationPlace,
      modes: [Mode.TRANSIT],
      time: DateTime.now(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return
    // PlaceMap(place: widget.place),
    Consumer<PlaceController>(
      builder: (context, placeController, _) => Row(
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
                              placeController.place!.name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: Navi4AllColors.klRed,
                              ),
                            ),
                            Text(
                              placeController.place!.description,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(color: Navi4AllColors.klRed),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(width: 16),
                      IconButton(
                        onPressed: () =>
                            _toggleFavorite(placeController.place!),
                        icon: Icon(
                          color: Navi4AllColors.klRed,
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
                          icon: Icons.directions_outlined,
                          label: AppLocalizations.of(
                            context,
                          )!.placeScreenRouteButton,
                          onTap: () {
                            Provider.of<CanvasController>(
                              context,
                              listen: false,
                            ).setState(CanvasControllerState.itinerary);

                            // Analytics event
                            /* MatomoTracker.instance.trackEvent(
                                      eventInfo: EventInfo(
                                        category: EventCategory
                                            .parkingLocationScreen
                                            .toString(),
                                        action: EventAction
                                            .parkingLocationScreenRouteInternalClicked
                                            .toString(),
                                      ),
                                    ); */
                          },
                          shrinkWrap: false,
                        ),
                      ),
                      /* SizedBox(width: 8),
                              Flexible(
                                flex: 1,
                                child: SheetButton(
                                  icon: Icons.directions_transit_filled_outlined,
                                  label: AppLocalizations.of(
                                    context,
                                  )!.placeScreenRouteButton,
                                  onTap: () {
                                    // Analytics event
                                    /* MatomoTracker.instance.trackEvent(
                                      eventInfo: EventInfo(
                                        category: EventCategory
                                            .parkingLocationScreen
                                            .toString(),
                                        action: EventAction
                                            .parkingLocationScreenRouteExternalClicked
                                            .toString(),
                                      ),
                                    ); */
                                  },
                                  shrinkWrap: false,
                                ),
                              ), */
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
                  Consumer(
                    builder: (context, ItineraryController controller, child) =>
                        controller.itineraries.isNotEmpty
                        ? Row(
                            children: [
                              Icon(
                                controller.itineraries.first.legs.length > 1
                                    ? Icons.directions_transit_outlined
                                    : Icons.directions_walk_outlined,
                                color: Navi4AllColors.klRed,
                              ),
                              SizedBox(width: 8.0),
                              Text(
                                '${(controller.itineraries.first.duration / 60).round()} min',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color: Navi4AllColors.klRed,
                                  fontSize: 16,
                                ),
                              ),
                              SizedBox(width: 6.0),
                              Icon(
                                Icons.circle,
                                size: 6,
                                color: Navi4AllColors.klRed,
                              ),
                              SizedBox(width: 6.0),
                              Text(
                                getItineraryDistanceText(
                                  controller.itineraries.first,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color: Navi4AllColors.klRed,
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          )
                        : SizedBox.shrink(),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
    /* SafeArea(
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
                              color: Navi4AllColors.klRed,
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
              ),
            ),
          ), */
  }
}
