import 'package:flutter/material.dart';
import 'package:navi4all/view/routing/journey_option.dart';
import 'package:navi4all/view/common/accessible_button.dart';
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
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            children: [
              SizedBox(height: 50),
              OrigDestPicker(origin: 'Aktuelle Position', destination: address),
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
                                'mode': 'Zu Fuß',
                                'duration': '3 min',
                              },
                              {
                                'icon': Icons.directions_bus,
                                'mode': 'Bus',
                                'duration': '20 min',
                              },
                              {
                                'icon': Icons.directions_walk,
                                'mode': 'Zu Fuß',
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
                                'mode': 'Zu Fuß',
                                'duration': '3 min',
                              },
                              {
                                'icon': Icons.directions_bus,
                                'mode': 'Bus',
                                'duration': '25 min',
                              },
                              {
                                'icon': Icons.directions_walk,
                                'mode': 'Zu Fuß',
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
                                'mode': 'S-Bahn',
                                'duration': '10 min',
                              },
                              {
                                'icon': Icons.directions_bus,
                                'mode': 'Bus',
                                'duration': '15 min',
                              },
                              {
                                'icon': Icons.directions_walk,
                                'mode': 'Zu Fuß',
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
                label: 'Routeneinstellungen',
                style: AccessibleButtonStyle.pink,
                onTap: () {},
              ),
              SizedBox(height: 20),
              AccessibleButton(
                label: 'Route Speichern',
                style: AccessibleButtonStyle.pink,
                onTap: () {},
              ),
              SizedBox(height: 20),
              AccessibleButton(
                label: 'Startbildschirm',
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
