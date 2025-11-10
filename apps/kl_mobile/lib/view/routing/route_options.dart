import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:navi4all/core/theme/colors.dart';
import 'package:navi4all/l10n/app_localizations.dart';
import 'package:navi4all/schemas/routing/coordinates.dart';
import 'package:navi4all/view/routing/itinerary_widget.dart';
import 'package:navi4all/view/common/accessible_button.dart';
import 'orig_dest_picker.dart';
import 'package:navi4all/services/routing.dart';
import 'package:navi4all/schemas/routing/itinerary.dart';
import 'package:navi4all/schemas/routing/mode.dart';
import 'package:navi4all/schemas/routing/place.dart';
import 'package:navi4all/core/theme/values.dart';
import 'package:navi4all/core/processing_status.dart';
import 'package:geolocator/geolocator.dart';
import 'package:navi4all/view/search/search.dart';

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
  Place? _origin;
  Place? _destination;
  List<Itinerary> _itineraries = [];
  ProcessingStatus _processingStatus = ProcessingStatus.idle;

  @override
  void initState() {
    super.initState();
    _destination = widget.place;
    _initializeOrigin();
  }

  Future<void> _initializeOrigin() async {
    try {
      Position position = await _determinePosition();
      _origin = Place(
        id: Navi4AllValues.userLocation,
        name: "",
        type: Navi4AllValues.userLocation,
        description: "",
        address: "",
        coordinates: Coordinates(
          lat: position.latitude,
          lon: position.longitude,
        ),
      );
      _fetchItineraries();
    } catch (e) {
      // TODO: Handle error appropriately, e.g., show a snackbar or dialog
      setState(() {
        _processingStatus = ProcessingStatus.error;
      });
    }
  }

  void _swapOriginDestination() {
    setState(() {
      final temp = _origin;
      _origin = _destination;
      _destination = temp;
    });
    _fetchItineraries();
  }

  Future<void> _fetchItineraries() async {
    setState(() {
      _processingStatus = ProcessingStatus.processing;
    });

    List<Itinerary> itineraries = [];
    RoutingService routingService = RoutingService();
    try {
      final response = await routingService.getItineraries(
        originLat: _origin!.coordinates.lat,
        originLon: _origin!.coordinates.lon,
        destinationLat: _destination!.coordinates.lat,
        destinationLon: _destination!.coordinates.lon,
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
      // TODO: Handle error appropriately, e.g., show a snackbar or dialog
      setState(() {
        _processingStatus = ProcessingStatus.error;
      });
      return;
    }

    setState(() {
      _processingStatus = ProcessingStatus.completed;
    });
  }

  Future<Position> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Test if location services are enabled.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Location services are not enabled don't continue
      // accessing the position and request users of the
      // App to enable the location services.
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        // Permissions are denied, next time you could try
        // requesting permissions again (this is also where
        // Android's shouldShowRequestPermissionRationale
        // returned true. According to Android guidelines
        // your App should show an explanatory UI now.
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // Permissions are denied forever, handle appropriately.
      return Future.error(
        'Location permissions are permanently denied, we cannot request permissions.',
      );
    }

    // When we reach here, permissions are granted and we can
    // continue accessing the position of the device.
    return await Geolocator.getCurrentPosition();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: Colors.white,
    body: SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 32),
        child: Column(
          children: [
            OrigDestPicker(
              origin: _origin,
              destination: _destination,
              onOriginTap: () {
                Navigator.of(context)
                    .push(
                      MaterialPageRoute(
                        builder: (context) => SearchScreen(
                          isSecondarySearch: true,
                          isOriginPlaceSearch: true,
                        ),
                      ),
                    )
                    .then((result) {
                      if (result is Place) {
                        setState(() {
                          _origin = result;
                        });
                        _fetchItineraries();
                      }
                    });
              },
              onDestinationTap: () {
                Navigator.of(context)
                    .push(
                      MaterialPageRoute(
                        builder: (context) => SearchScreen(
                          isSecondarySearch: true,
                          isOriginPlaceSearch: false,
                        ),
                      ),
                    )
                    .then((result) {
                      if (result is Place) {
                        setState(() {
                          _destination = result;
                        });
                        _fetchItineraries();
                      }
                    });
              },
              onOriginDestinationSwap: _swapOriginDestination,
            ),
            const SizedBox(height: 20),
            Expanded(
              child: Column(
                children: [
                  Expanded(
                    child: _processingStatus == ProcessingStatus.completed
                        ? _itineraries.isNotEmpty
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
                              : Center(
                                  child: Padding(
                                    padding: const EdgeInsets.all(16.0),
                                    child: Text(
                                      AppLocalizations.of(
                                        context,
                                      )!.errorNoItinerariesFound,
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(
                                        fontSize: 16,
                                        color: Navi4AllColors.klRed,
                                      ),
                                    ),
                                  ),
                                )
                        : _processingStatus == ProcessingStatus.processing
                        ? Center(child: CircularProgressIndicator())
                        : _processingStatus == ProcessingStatus.error
                        ? Center(
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Text(
                                AppLocalizations.of(
                                  context,
                                )!.errorUnableToFetchItineraries,
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontSize: 16,
                                  color: Navi4AllColors.klRed,
                                ),
                              ),
                            ),
                          )
                        : Center(child: CircularProgressIndicator()),
                  ),
                ],
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
              label: AppLocalizations.of(context)!.routeOptionsSaveRouteButton,
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
