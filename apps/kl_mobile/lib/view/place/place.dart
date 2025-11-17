import 'package:flutter/material.dart';
import 'package:navi4all/controllers/canvas_controller.dart';
import 'package:navi4all/controllers/itinerary_controller.dart';
import 'package:navi4all/controllers/place_controller.dart';
import 'package:navi4all/core/theme/values.dart';
import 'package:navi4all/core/utils.dart';
import 'package:navi4all/schemas/routing/coordinates.dart';
import 'package:navi4all/schemas/routing/mode.dart';
import 'package:navi4all/view/search/search.dart';
// import 'package:matomo_tracker/matomo_tracker.dart';
import 'package:provider/provider.dart';
import 'package:navi4all/controllers/favorites_controller.dart';
// import 'package:navi4all/core/analytics/events.dart';
import 'package:navi4all/l10n/app_localizations.dart';
import 'package:navi4all/schemas/routing/place.dart';
import 'package:navi4all/view/common/sheet_button.dart';
import 'dart:core';

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
    _initializeItineraries();

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

  Future<void> _initializeItineraries() async {
    // Initialize origin and destination places
    Place originPlace = Place(
      id: Navi4AllValues.userLocation,
      name: '',
      type: PlaceType.address,
      description: '',
      address: '',
      coordinates: Coordinates(lat: 0.0, lon: 0.0),
    );

    Place destinationPlace = Provider.of<PlaceController>(
      context,
      listen: false,
    ).place!;

    // Set itinerary parameters
    Provider.of<ItineraryController>(context, listen: false).setParameters(
      context: context,
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
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: <Widget>[
                  Row(
                    children: [
                      SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              placeController.place != null
                                  ? placeController.place!.name
                                  : '...',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                height: 1.25,
                              ),
                            ),
                            Text(
                              placeController.place != null
                                  ? placeController.place!.description
                                  : '...',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      SizedBox(width: 8),
                      Ink(
                        decoration: ShapeDecoration(
                          shape: CircleBorder(),
                          color: Theme.of(context).colorScheme.tertiary,
                        ),
                        child: IconButton(
                          icon: Icon(
                            _isFavorite ? Icons.star : Icons.star_border,
                            color: Theme.of(
                              context,
                            ).textTheme.displayMedium?.color,
                          ),
                          onPressed: () => placeController.place != null
                              ? _toggleFavorite(placeController.place!)
                              : null,
                        ),
                      ),
                      SizedBox(width: 8),
                      Ink(
                        decoration: ShapeDecoration(
                          shape: CircleBorder(),
                          color: Theme.of(context).colorScheme.tertiary,
                        ),
                        child: IconButton(
                          icon: Icon(
                            Icons.close_rounded,
                            color: Theme.of(
                              context,
                            ).textTheme.displayMedium?.color,
                          ),
                          onPressed: () {
                            placeController.reset();
                            Navigator.of(context).pop();
                          },
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
                    builder:
                        (
                          context,
                          ItineraryController itineraryController,
                          child,
                        ) =>
                            itineraryController.hasParametersSet &&
                                itineraryController.itineraries.isNotEmpty
                            ? Row(
                                children: [
                                  Icon(
                                    itineraryController
                                                .itineraries
                                                .first
                                                .legs
                                                .length >
                                            1
                                        ? Icons.directions_transit_outlined
                                        : Icons.directions_walk_outlined,
                                    color: Theme.of(
                                      context,
                                    ).textTheme.displayMedium?.color,
                                  ),
                                  SizedBox(width: 8.0),
                                  Text(
                                    '${(itineraryController.itineraries.first.duration / 60).round()} min',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(fontSize: 16),
                                  ),
                                  SizedBox(width: 6.0),
                                  Icon(
                                    Icons.circle,
                                    size: 6,
                                    color: Theme.of(
                                      context,
                                    ).textTheme.displayMedium?.color,
                                  ),
                                  SizedBox(width: 6.0),
                                  Text(
                                    getItineraryDistanceText(
                                      itineraryController.itineraries.first,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(fontSize: 16),
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
                              color: Theme.of(
                                      context,
                                    ).textTheme.displayMedium?.color,
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

class PlaceSearchBar extends StatelessWidget {
  const PlaceSearchBar({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
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
                  MaterialPageRoute(builder: (context) => const SearchScreen()),
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
                    SizedBox(width: 24),
                    Icon(
                      Icons.search,
                      color: Theme.of(context).textTheme.displayMedium?.color,
                    ),
                    SizedBox(width: 16),
                    Expanded(
                      child: Consumer<PlaceController>(
                        builder: (context, placeController, _) => Text(
                          placeController.place != null
                              ? placeController.place!.name
                              : AppLocalizations.of(
                                  context,
                                )!.homeSearchButtonHint,
                          style: const TextStyle(fontSize: 16),
                          overflow: TextOverflow.ellipsis,
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
    );
  }
}
