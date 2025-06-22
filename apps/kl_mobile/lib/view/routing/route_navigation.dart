import 'package:flutter/material.dart';
import 'package:navi4all/util/theme/colors.dart';
import 'package:navi4all/view/common/accessible_button.dart';
import 'package:navi4all/util/theme/geometry.dart';

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
                label:
                    'Sie fahren nach ${widget.address}. In 30 Minuten erreichen Sie Ihr Ziel.',
                child: Column(
                  children: [
                    Align(
                      alignment: Alignment.topLeft,
                      child: Text(
                        "Sie fahren nach",
                        style: TextStyle(color: Navi4AllColors.klRed),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Align(
                      alignment: Alignment.topLeft,
                      child: Text(
                        widget.address,
                        style: TextStyle(
                          color: Navi4AllColors.klRed,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Align(
                      alignment: Alignment.topLeft,
                      child: Text(
                        "in 30 Minuten erreichen Sie Ihr Ziel",
                        style: TextStyle(
                          color: Navi4AllColors.klRed,
                          fontWeight: FontWeight.bold,
                        ),
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
                      action: 'Fahren Sie geradeaus',
                      description: 'auf Waldstraße',
                      timeToStep: 'in 50 Metern',
                      isCurrent: true,
                    ),
                    _NavigationStep(
                      index: 2,
                      action: 'Biegen Sie links ab',
                      description: 'auf Pariser Straße',
                      timeToStep: 'in 100 Metern',
                    ),
                    _NavigationStep(
                      index: 3,
                      action: 'Warten Sie auf den Bus',
                      description: 'Buslinie 5 Richtung Stadtmitte',
                      timeToStep: 'in 5 Minuten',
                    ),
                  ],
                ),
              ),
              SizedBox(height: 20),
              AccessibleButton(
                label: 'Stummschalten',
                style: AccessibleButtonStyle.pink,
                onTap: () {},
              ),
              SizedBox(height: 20),
              AccessibleButton(
                label: !isPaused ? 'Pause' : 'Fortsetzen',
                style: AccessibleButtonStyle.pink,
                onTap: () {
                  setState(() {
                    isPaused = !isPaused;
                  });
                },
              ),
              SizedBox(height: 20),
              AccessibleButton(
                label: 'Stop',
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

  String get _widgetSemanticsLabel =>
      'Navigation Schritt $index: $action $description $timeToStep';

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: _widgetSemanticsLabel,
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
                            color: Navi4AllColors.klRed,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          description,
                          style: const TextStyle(
                            fontWeight: FontWeight.w400,
                            fontSize: 16,
                            color: Navi4AllColors.klRed,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          timeToStep,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Navi4AllColors.klRed,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 8),
              Divider(height: 1, color: Navi4AllColors.klRed),
            ],
          ),
        ),
      ),
    );
  }
}
