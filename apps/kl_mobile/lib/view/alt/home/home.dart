import 'package:flutter/material.dart';
import 'package:navi4all/controllers/favorites_controller.dart';
import 'package:navi4all/l10n/app_localizations.dart';
import 'package:navi4all/view/favourites/favorites.dart';
import 'package:navi4all/view/search/search.dart';
import 'package:navi4all/view/common/accessible_button.dart';
import 'package:navi4all/view/settings/settings.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Semantics(
          focused: true,
          label: AppLocalizations.of(context)!.homeScreenSemantic,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 32),
                  Spacer(),
                  AccessibleButton(
                    label: AppLocalizations.of(context)!.homeSearchButton,
                    style: AccessibleButtonStyle.pink,
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) =>
                              const SearchScreen(altMode: true),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 32),
                  Consumer<FavoritesController>(
                    builder: (context, favoritesController, _) =>
                        AccessibleButton(
                          label: AppLocalizations.of(context)!.favouritesTitle,
                          style: AccessibleButtonStyle.pink,
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) =>
                                    const FavoritesScreen(altMode: true),
                              ),
                            );
                          },
                        ),
                  ),
                  const SizedBox(height: 32),
                  AccessibleButton(
                    label: AppLocalizations.of(context)!.settingsTitle,
                    style: AccessibleButtonStyle.pink,
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) =>
                              const SettingsScreen(altMode: true),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 32),
                  Spacer(),
                  Semantics(
                    excludeSemantics: true,
                    child: Image.asset("assets/stadt_kl_red.png", width: 100),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
