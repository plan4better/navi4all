import 'package:flutter/material.dart';
import 'package:smart_roots/l10n/app_localizations.dart';
import 'package:smart_roots/view/routing/journey_option.dart';
import 'package:smart_roots/view/common/accessible_button.dart';
import 'orig_dest_picker.dart';

class RouteOptionsScreen extends StatelessWidget {
  final String address;
  final String zipcode;
  const RouteOptionsScreen({
    required this.address,
    this.zipcode = '67655 Kaiserslautern',
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            children: [
              SizedBox(height: 50),
              OrigDestPicker(
                origin: AppLocalizations.of(
                  context,
                )!.routeOptionsCurrentLocationText,
                destination: address,
              ),
              const SizedBox(height: 20),
              Expanded(
                child: Column(
                  children: [
                    Expanded(
                      child: ListView(
                        children: [
                          JourneyOption(
                            duration: '25 min',
                            startTime: '10:49',
                            endTime: '12:14',
                            segments: [
                              {
                                'icon': Icons.directions_walk,
                                'mode': AppLocalizations.of(
                                  context,
                                )!.commonModeWalking,
                                'duration': '3 min',
                              },
                              {
                                'icon': Icons.directions_bus,
                                'mode': AppLocalizations.of(
                                  context,
                                )!.commonModeBus,
                                'duration': '20 min',
                              },
                              {
                                'icon': Icons.directions_walk,
                                'mode': AppLocalizations.of(
                                  context,
                                )!.commonModeWalking,
                                'duration': '2 min',
                              },
                            ],
                            address: address,
                            zipcode: zipcode,
                          ),
                          JourneyOption(
                            duration: '32 min',
                            startTime: '10:50',
                            endTime: '11:22',
                            segments: [
                              {
                                'icon': Icons.directions_walk,
                                'mode': AppLocalizations.of(
                                  context,
                                )!.commonModeWalking,
                                'duration': '3 min',
                              },
                              {
                                'icon': Icons.directions_bus,
                                'mode': AppLocalizations.of(
                                  context,
                                )!.commonModeBus,
                                'duration': '25 min',
                              },
                              {
                                'icon': Icons.directions_walk,
                                'mode': AppLocalizations.of(
                                  context,
                                )!.commonModeWalking,
                                'duration': '4 min',
                              },
                            ],
                            address: address,
                            zipcode: zipcode,
                          ),
                          JourneyOption(
                            duration: '40 min',
                            startTime: '10:50',
                            endTime: '11:30',
                            segments: [
                              {
                                'icon': Icons.directions_train,
                                'mode': AppLocalizations.of(
                                  context,
                                )!.commonModeSBahn,
                                'duration': '10 min',
                              },
                              {
                                'icon': Icons.directions_bus,
                                'mode': AppLocalizations.of(
                                  context,
                                )!.commonModeBus,
                                'duration': '15 min',
                              },
                              {
                                'icon': Icons.directions_walk,
                                'mode': AppLocalizations.of(
                                  context,
                                )!.commonModeWalking,
                                'duration': '15 min',
                              },
                            ],
                            address: address,
                            zipcode: zipcode,
                          ),
                          const SizedBox(height: 20),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 20),
              AccessibleButton(
                label: AppLocalizations.of(
                  context,
                )!.routeOptionsRouteSettingsButton,
                style: AccessibleButtonStyle.pink,
                onTap: null,
              ),
              SizedBox(height: 20),
              AccessibleButton(
                label: AppLocalizations.of(
                  context,
                )!.routeOptionsSaveRouteButton,
                style: AccessibleButtonStyle.pink,
                onTap: null,
              ),
              SizedBox(height: 20),
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
}
