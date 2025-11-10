import 'package:flutter/material.dart';
import 'package:navi4all/l10n/app_localizations.dart';
import 'package:navi4all/view/search/search.dart';
import 'package:navi4all/view/common/accessible_button.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
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
                        builder: (context) => const SearchScreen(),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 32),
                AccessibleButton(
                  label: AppLocalizations.of(context)!.homeSavedButton,
                  style: AccessibleButtonStyle.pink,
                  onTap: null,
                ),
                const SizedBox(height: 32),
                AccessibleButton(
                  label: AppLocalizations.of(context)!.homeRouteButton,
                  style: AccessibleButtonStyle.pink,
                  onTap: null,
                ),
                const SizedBox(height: 32),
                AccessibleButton(
                  label: AppLocalizations.of(context)!.homeSettingsButton,
                  style: AccessibleButtonStyle.pink,
                  onTap: null,
                ),
                const SizedBox(height: 32),
                Spacer(),
                Image.asset("assets/stadt_kl_red.png", width: 100),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
