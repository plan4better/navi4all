import 'package:flutter/material.dart';
import 'package:navi4all/l10n/app_localizations.dart';
import 'package:navi4all/view/itinerary/itinerary.dart';
import 'package:navi4all/view/common/accessible_button.dart';

class ItineraryScreen extends StatefulWidget {
  const ItineraryScreen({super.key});

  @override
  State<ItineraryScreen> createState() => _ItineraryScreenState();
}

class _ItineraryScreenState extends State<ItineraryScreen> {
  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: Colors.white,
    body: SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
        child: Column(
          children: [
            OrigDestPicker(),
            const SizedBox(height: 8),
            Expanded(
              child: ItineraryList(
                scrollController: ScrollController(),
                altMode: true,
              ),
            ),
            SizedBox(height: 16),
            AccessibleButton(
              label: AppLocalizations.of(
                context,
              )!.routeOptionsRouteSettingsButton,
              style: AccessibleButtonStyle.pink,
              onTap: null,
            ),
            SizedBox(height: 16),
            AccessibleButton(
              label: AppLocalizations.of(context)!.commonHomeScreenButton,
              style: AccessibleButtonStyle.pink,
              onTap: () =>
                  Navigator.of(context).popUntil((route) => route.isFirst),
            ),
          ],
        ),
      ),
    ),
  );
}
