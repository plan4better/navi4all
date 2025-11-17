import 'package:flutter/material.dart';
import 'package:navi4all/controllers/favorites_controller.dart';
import 'package:navi4all/controllers/place_controller.dart';
import 'package:navi4all/l10n/app_localizations.dart';
import 'package:navi4all/schemas/routing/mode.dart';
import 'package:navi4all/schemas/routing/place.dart';
import 'package:provider/provider.dart';
import '../routing/route_options.dart';
import 'package:navi4all/view/common/accessible_button.dart';
import 'package:navi4all/core/theme/colors.dart';

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
                SizedBox(height: 64),
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
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => RouteOptionsScreen(
                              mode: Mode.WALK,
                              place: placeController.place!,
                            ),
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
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => RouteOptionsScreen(
                              mode: Mode.TRANSIT,
                              place: placeController.place!,
                            ),
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
