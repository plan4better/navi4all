import 'package:flutter/material.dart';
import 'package:navi4all/controllers/canvas_controller.dart';
import 'package:navi4all/controllers/place_controller.dart';
import 'package:navi4all/schemas/routing/place.dart';
import 'package:navi4all/view/canvas/canvas_screen.dart';
import 'package:navi4all/view/common/accessible_button.dart';
import 'package:provider/provider.dart';
import 'package:navi4all/controllers/favorites_controller.dart';
import 'package:navi4all/core/theme/colors.dart';
import 'package:navi4all/l10n/app_localizations.dart';

class FavoritesScreen extends StatefulWidget {
  final bool altMode;

  const FavoritesScreen({super.key, this.altMode = false});

  @override
  State<StatefulWidget> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 64),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  AppLocalizations.of(context)!.favouritesTitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Navi4AllColors.klRed,
                  ),
                ),
              ),
              SizedBox(height: 16),
              Consumer<FavoritesController>(
                builder: (context, favoritesController, _) => Expanded(
                  child: favoritesController.favorites.isNotEmpty
                      ? ListView.builder(
                          shrinkWrap: true,
                          itemCount: favoritesController.favorites.length,
                          itemBuilder: (context, index) => _FavoritesListItem(
                            place: favoritesController.favorites[index],
                            onTap: () {
                              Provider.of<CanvasController>(
                                context,
                                listen: false,
                              ).setState(CanvasControllerState.place);
                              Provider.of<PlaceController>(
                                context,
                                listen: false,
                              ).setPlace(favoritesController.favorites[index]);
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) =>
                                      CanvasScreen(altMode: widget.altMode),
                                ),
                              );
                            },
                          ),
                        )
                      : Expanded(
                          child: Align(
                            alignment: Alignment.center,
                            child: Semantics(
                              excludeSemantics: true,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.star,
                                    size: 72,
                                    color: Navi4AllColors.klPink,
                                  ),
                                  SizedBox(height: 16),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 32,
                                    ),
                                    child: Text(
                                      AppLocalizations.of(
                                        context,
                                      )!.favouritesScreenPrompt,
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Navi4AllColors.klPink,
                                      ),
                                    ),
                                  ),
                                  SizedBox(height: 32),
                                ],
                              ),
                            ),
                          ),
                        ),
                ),
              ),
              SizedBox(height: 96),
              widget.altMode
                  ? Align(
                      alignment: Alignment.bottomCenter,
                      child: AccessibleButton(
                        label: AppLocalizations.of(
                          context,
                        )!.commonHomeScreenButton,
                        style: AccessibleButtonStyle.pink,
                        onTap: () => Navigator.of(
                          context,
                        ).popUntil((route) => route.isFirst),
                      ),
                    )
                  : SizedBox.shrink(),
              widget.altMode ? SizedBox(height: 32) : SizedBox.shrink(),
            ],
          ),
        ),
      ),
    );
  }
}

class _FavoritesListItem extends StatelessWidget {
  final Place place;
  final Function onTap;

  const _FavoritesListItem({required this.place, required this.onTap});

  @override
  Widget build(BuildContext context) => InkWell(
    onTap: () => onTap(),
    child: Semantics(
      label: place.name,
      excludeSemantics: true,
      child: Column(
        children: [
          SizedBox(height: 4),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 12),
            child: Row(
              children: [
                SizedBox(width: 4),
                Icon(Icons.place_rounded, color: Navi4AllColors.klRed),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        place.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: Navi4AllColors.klRed,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        place.description,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(color: Navi4AllColors.klRed),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 4),
          Divider(color: Navi4AllColors.klPink, height: 0),
        ],
      ),
    ),
  );
}
