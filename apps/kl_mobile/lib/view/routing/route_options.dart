import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:navi4all/l10n/app_localizations.dart';
import 'package:navi4all/view/routing/itinerary_widget.dart';
import 'package:navi4all/view/common/accessible_button.dart';
import 'orig_dest_picker.dart';
import 'package:navi4all/services/routing.dart';
import 'package:navi4all/schemas/routing/itinerary.dart';
import 'package:navi4all/schemas/routing/mode.dart';
import 'package:navi4all/schemas/routing/place.dart';

class RouteOptionsScreen extends StatefulWidget {
  final Mode mode;
  final Place place;
  const RouteOptionsScreen({
    required this.mode,
    required this.place,
    super.key,
  });

  @override
  State<RouteOptionsScreen> createState() => _RouteOptionsScreenState();
}

class _RouteOptionsScreenState extends State<RouteOptionsScreen> {
  List<Itinerary> _itineraries = [];

  Future<void> _fetchItineraries() async {
    List<Itinerary> itineraries = [];
    RoutingService routingService = RoutingService();
    try {
      final response = await routingService.getItineraries(
        originLat: 49.43578102534064,
        originLon: 7.768523468558005,
        destinationLat: widget.place.coordinates.lat,
        destinationLon: widget.place.coordinates.lon,
        date: DateFormat('yyyy-MM-dd').format(DateTime.now()),
        time: DateFormat('HH:mm:ss').format(DateTime.now()),
        timeIsArrival: false,
        transportModes: [widget.mode.name],
      );
      if (response.statusCode == 200) {
        final data = response.data["itineraries"] as List;
        itineraries = data.map((item) => Itinerary.fromJson(item)).toList();
        setState(() {
          _itineraries = itineraries;
        });
      } else {
        throw Exception('Failed to load itineraries');
      }
    } catch (e) {
      print('Error fetching itineraries: $e');
      // Handle error appropriately, e.g., show a snackbar or dialog
    }
  }

  @override
  Widget build(BuildContext context) {
    // TODO: Handle cases where itineraries are not available
    if (_itineraries.isEmpty) {
      _fetchItineraries();
    }

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            children: [
              // SizedBox(height: 50),
              OrigDestPicker(
                origin: AppLocalizations.of(
                  context,
                )!.routeOptionsCurrentLocationText,
                destination: widget.place.name,
              ),
              const SizedBox(height: 20),
              Expanded(
                child: Column(
                  children: [
                    Expanded(
                      child: _itineraries.isNotEmpty
                          ? ListView.builder(
                              itemCount: _itineraries.length,
                              itemBuilder: (context, index) {
                                final itinerary = _itineraries[index];
                                return ItineraryWidget(
                                  itinerary: itinerary,
                                  onTap: () {},
                                );
                              },
                            )
                          : Center(child: CircularProgressIndicator()),
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
