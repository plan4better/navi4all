import 'package:flutter/material.dart';
import 'package:navi4all/l10n/app_localizations.dart';
import 'package:navi4all/core/theme/colors.dart';
import 'package:navi4all/view/common/accessible_button.dart';
import 'package:navi4all/core/theme/geometry.dart';

class RouteNavigationScreen extends StatefulWidget {
  final String address;
  final String zipcode;
  final String duration;
  final String startTime;
  final String endTime;
  final List<Map<String, dynamic>> segments;
  const RouteNavigationScreen({
    required this.address,
    this.zipcode = '67655 Kaiserslautern',
    required this.duration,
    required this.startTime,
    required this.endTime,
    required this.segments,
    super.key,
  });

  @override
  State<RouteNavigationScreen> createState() => _RouteNavigationScreenState();
}

class _RouteNavigationScreenState extends State<RouteNavigationScreen> {
  bool isPaused = false;
  bool isMuted = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          child: Column(
            children: [
              const SizedBox(height: 48),
              Semantics(
                label: AppLocalizations.of(context)!
                    .routeNavigationDescriptionSemantic(
                      widget.address,
                      "30 Minuten",
                    ),
                child: Column(
                  children: [
                    Align(
                      alignment: Alignment.topLeft,
                      child: Text(
                        AppLocalizations.of(context)!.routeNavigationTitle,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Align(
                      alignment: Alignment.topLeft,
                      child: Text(
                        widget.address,
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Align(
                      alignment: Alignment.topLeft,
                      child: Text(
                        AppLocalizations.of(
                          context,
                        )!.routeNavigationTimeToArrival("30 min"),
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Expanded(
                child: ListView(
                  shrinkWrap: true,
                  children: [
                    _NavigationStep(
                      index: 1,
                      action: AppLocalizations.of(
                        context,
                      )!.routeNavigationStepContinueStraight,
                      description: AppLocalizations.of(
                        context,
                      )!.routeNavigationStepOntoLocation("Waldstraße"),
                      timeToStep: AppLocalizations.of(
                        context,
                      )!.routeNavigationStepTimeToAction("50 m"),
                      isCurrent: true,
                    ),
                    _NavigationStep(
                      index: 2,
                      action: AppLocalizations.of(
                        context,
                      )!.routeNavigationStepTurnLeft,
                      description: AppLocalizations.of(
                        context,
                      )!.routeNavigationStepOntoLocation("Pariser Straße"),
                      timeToStep: AppLocalizations.of(
                        context,
                      )!.routeNavigationStepTimeToAction("100 m"),
                    ),
                    _NavigationStep(
                      index: 3,
                      action: AppLocalizations.of(context)!
                          .routeNavigationStepAwaitMode(
                            AppLocalizations.of(context)!.commonModeBus,
                          ),
                      description: AppLocalizations.of(
                        context,
                      )!.routeNavigationStepModeDescription("5", "Stadtmitte"),
                      timeToStep: AppLocalizations.of(
                        context,
                      )!.routeNavigationStepTimeToAction("5 min"),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 20),
              AccessibleButton(
                label: !isMuted
                    ? AppLocalizations.of(
                        context,
                      )!.routeNavigationMuteButtonMuteText
                    : AppLocalizations.of(
                        context,
                      )!.routeNavigationMuteButtonUnmuteText,
                style: AccessibleButtonStyle.pink,
                onTap: () {
                  setState(() {
                    isMuted = !isMuted;
                  });
                },
              ),
              SizedBox(height: 20),
              AccessibleButton(
                label: !isPaused
                    ? AppLocalizations.of(
                        context,
                      )!.routeNavigationPauseButtonPauseText
                    : AppLocalizations.of(
                        context,
                      )!.routeNavigationPauseButtonResumeText,
                style: AccessibleButtonStyle.pink,
                onTap: () {
                  setState(() {
                    isPaused = !isPaused;
                  });
                },
              ),
              SizedBox(height: 20),
              AccessibleButton(
                label: AppLocalizations.of(context)!.routeNavigationStopButton,
                style: AccessibleButtonStyle.pink,
                onTap: () => Navigator.of(context).pop(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavigationStep extends StatelessWidget {
  final int index;
  final String action;
  final String description;
  final String timeToStep;
  final bool isCurrent;

  const _NavigationStep({
    required this.index,
    required this.action,
    required this.description,
    required this.timeToStep,
    this.isCurrent = false,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: AppLocalizations.of(
        context,
      )!.routeNavigationStepSemantic(index, action, description, timeToStep),
      child: Semantics(
        excludeSemantics: true,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(Navi4AllGeometry.radiusMedium),
            color: isCurrent ? const Color(0xFFFFEDEB) : Colors.white,
          ),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          action,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          description,
                          style: const TextStyle(
                            fontWeight: FontWeight.w400,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          timeToStep,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 8),
              Divider(height: 1, color: Navi4AllColors.klPink),
            ],
          ),
        ),
      ),
    );
  }
}
