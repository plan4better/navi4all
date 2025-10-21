import 'dart:math';
import 'dart:core';

import 'package:flutter/material.dart';
import 'package:maplibre_gl/maplibre_gl.dart';
import 'package:smartroots/core/config.dart';
import 'package:smartroots/core/theme/colors.dart';
import 'package:smartroots/l10n/app_localizations.dart';
import 'package:smartroots/services/poi_parking.dart';
import 'package:smartroots/view/parking_site/parking_site.dart';
import 'package:geolocator/geolocator.dart';

class HomeMap extends StatefulWidget {
  const HomeMap({super.key});

  @override
  State<StatefulWidget> createState() => _HomeMapState();
}

class _HomeMapState extends State<HomeMap> {
  late MapLibreMapController _mapController;
  bool _canInteractWithMap = false;
  List<Map<String, dynamic>> _parkingSites = [];
  final Map<String, Map<String, dynamic>> _symbolIdToSite = {};

  Future<void> _panToUserLocation() async {
    // Check location permission status
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      // User will need to enable permissions from app settings
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            AppLocalizations.of(context)!.userLocationDeniedSnackbarText,
          ),
        ),
      );
      return;
    }

    // Fetch user location and pan map
    final latLng = await Geolocator.getCurrentPosition();
    _mapController.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(
          target: LatLng(latLng.latitude, latLng.longitude),
          zoom: 14,
        ),
      ),
      duration: const Duration(seconds: 2),
    );
  }

  Future<void> _onStyleLoaded() async {
    // Fetch and display parking locations
    _fetchParkingSites().then((_) {
      // Add circle tap listener
      _mapController.onCircleTapped.add(_onCircleTapped);

      // Pan to user location by default if location access was granted
      Geolocator.checkPermission().then((permission) {
        if (permission != LocationPermission.denied &&
            permission != LocationPermission.deniedForever) {
          _panToUserLocation();
        }
      });
    });

    await Future.delayed(const Duration(milliseconds: 250));
    setState(() => _canInteractWithMap = true);
  }

  Future<void> _fetchParkingSites() async {
    POIParkingService parkingService = POIParkingService();
    try {
      List<Map<String, dynamic>> result = await parkingService
          .getParkingLocations();

      setState(() {
        _parkingSites = result;
      });
      _updateMarkers();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            AppLocalizations.of(context)!.errorUnableToFetchParkingSites,
          ),
        ),
      );
    }
  }

  void _onCircleTapped(Circle circle) {
    final site = _symbolIdToSite[circle.id] ?? {};
    if (site.isNotEmpty) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ParkingSiteScreen(parkingLocation: site),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        MapLibreMap(
          myLocationEnabled: true,
          styleString: Settings.mapStyleUrl,
          onMapCreated: (controller) => _mapController = controller,
          minMaxZoomPreference: MinMaxZoomPreference(5.0, null),
          cameraTargetBounds: CameraTargetBounds(
            LatLngBounds(
              southwest: LatLng(47.2701, 5.8663),
              northeast: LatLng(55.0581, 15.0419),
            ),
          ),
          initialCameraPosition: CameraPosition(
            target: LatLng(49.487164933378104, 8.46624749208),
            zoom: 13.0,
          ),
          onStyleLoadedCallback: _onStyleLoaded,
          compassViewMargins: const Point(16, 160),
          compassViewPosition: CompassViewPosition.topRight,
        ),
        // Fill screen with grey background while map is loading
        !_canInteractWithMap
            ? Container(color: Colors.grey[200])
            : SizedBox.shrink(),
        SafeArea(
          child: Align(
            alignment: Alignment.bottomRight,
            child: Padding(
              padding: const EdgeInsets.only(right: 16, bottom: 112),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  /*FloatingActionButton(
                    onPressed: () {},
                    child: Icon(Icons.layers),
                  ),*/
                  SizedBox(height: 16),
                  FloatingActionButton(
                    shape: CircleBorder(),
                    backgroundColor: SmartRootsColors.maWhite,
                    onPressed: () => _panToUserLocation(),
                    child: Icon(
                      Icons.my_location,
                      color: SmartRootsColors.maBlueExtraExtraDark,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _updateMarkers() {
    _mapController.clearCircles();

    List<CircleOptions> circles = [];
    for (var site in _parkingSites) {
      String markerColor = "#3685E2";
      if (!site["has_realtime_data"]) {
        markerColor = "#3685E2";
      } else if (site["disabled_parking_available"]) {
        markerColor = "#089161";
      } else {
        markerColor = "#F4B1A4";
      }

      circles.add(
        CircleOptions(
          geometry: site["coordinates"],
          circleColor: markerColor,
          circleRadius: 5.5,
          circleStrokeWidth: 1.0,
          circleStrokeColor: "#FFFFFF",
        ),
      );
    }

    _mapController.addCircles(circles).then((symbols) {
      for (int i = 0; i < symbols.length; i++) {
        _symbolIdToSite[symbols[i].id] = _parkingSites[i];
      }
    });
  }
}
