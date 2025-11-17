import 'package:flutter/material.dart';
import 'package:navi4all/controllers/favorites_controller.dart';
import 'package:navi4all/controllers/itinerary_controller.dart';
import 'package:navi4all/controllers/place_controller.dart';
import 'package:navi4all/core/theme/values.dart';
import 'package:navi4all/l10n/app_localizations.dart';
import 'package:navi4all/schemas/routing/coordinates.dart';
import 'package:navi4all/schemas/routing/mode.dart';
import 'package:navi4all/schemas/routing/place.dart';
import 'package:provider/provider.dart';
import '../itinerary/itinerary.dart';
import 'package:navi4all/view/common/accessible_button.dart';

class PlaceScreen extends StatefulWidget {
  const PlaceScreen({super.key});

  @override
  State<PlaceScreen> createState() => _PlaceScreenState();
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
    }
    setState(() {
      _isFavorite = !_isFavorite;
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Consumer<PlaceController>(
        builder: (context, placeController, _) => Padding(
          padding: const EdgeInsets.all(16),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              children: [
                SizedBox(height: 128),
                Semantics(
                  label: placeController.place!.name,
                  excludeSemantics: true,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          placeController.place!.name,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 24,
                          ),
                        ),
                      ),
                      Text(
                        placeController.place!.description,
                        style: const TextStyle(fontSize: 16),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 64),
                Column(
                  children: [
                    AccessibleButton(
                      label: AppLocalizations.of(
                        context,
                      )!.addressInfoWalkingRoutesButton,
                      semanticLabel: AppLocalizations.of(
                        context,
                      )!.addressInfoWalkingRoutesButtonSemantic,
                      style: AccessibleButtonStyle.red,
                      onTap: () {
                        final itineraryController =
                            Provider.of<ItineraryController>(
                              context,
                              listen: false,
                            );
                        itineraryController.setParameters(
                          context: context,
                          originPlace: itineraryController.originPlace!,
                          destinationPlace:
                              itineraryController.destinationPlace!,
                          modes: [Mode.WALK],
                          time: itineraryController.time!,
                          isArrivalTime: itineraryController.isArrivalTime!,
                        );
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => ItineraryScreen(),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 16),
                    AccessibleButton(
                      label: AppLocalizations.of(
                        context,
                      )!.addressInfoPublicTransportRoutesButton,
                      semanticLabel: AppLocalizations.of(
                        context,
                      )!.addressInfoPublicTransportRoutesButtonSemantic,
                      style: AccessibleButtonStyle.red,
                      onTap: () {
                        final itineraryController =
                            Provider.of<ItineraryController>(
                              context,
                              listen: false,
                            );
                        itineraryController.setParameters(
                          context: context,
                          originPlace: itineraryController.originPlace!,
                          destinationPlace:
                              itineraryController.destinationPlace!,
                          modes: [Mode.TRANSIT],
                          time: itineraryController.time!,
                          isArrivalTime: itineraryController.isArrivalTime!,
                        );
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => ItineraryScreen(),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 16),
                    AccessibleButton(
                      label: !_isFavorite
                          ? AppLocalizations.of(
                              context,
                            )!.addressInfoSaveAddressButton
                          : AppLocalizations.of(
                              context,
                            )!.addressInfoRemoveAddressButton,
                      style: AccessibleButtonStyle.pink,
                      onTap: () => _toggleFavorite(placeController.place!),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
