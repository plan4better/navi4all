import 'dart:async';
import 'dart:math';
import 'dart:core';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
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
  Map<String, Map<String, dynamic>> _symbolIdToSite = {};

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
    setState(() => _canInteractWithMap = true);

    // Load custom marker icons
    final bytes = await rootBundle.load('assets/parking_avbl_yes.png');
    final list = bytes.buffer.asUint8List();
    _mapController.addImage("parking_avbl_yes.png", list);

    final bytes2 = await rootBundle.load('assets/parking_avbl_no.png');
    final list2 = bytes2.buffer.asUint8List();
    _mapController.addImage("parking_avbl_no.png", list2);

    final bytes3 = await rootBundle.load('assets/parking_avbl_unknown.png');
    final list3 = bytes3.buffer.asUint8List();
    _mapController.addImage("parking_avbl_unknown.png", list3);

    // Fetch and display parking locations
    await _fetchParkingSites();

    // Add symbol tap listener
    _mapController.onSymbolTapped.add(_onSymbolTapped);
  }

  Future<void> _fetchParkingSites() async {
    POIParkingService parkingService = POIParkingService();
    try {
      List<Map<String, dynamic>> result = await parkingService
          .getParkingLocations(
            focusPointLat: 49.487164933378104,
            focusPointLon: 8.46624749208,
            radius: 2500,
          );

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

  void _onSymbolTapped(Symbol symbol) {
    final site = _symbolIdToSite[symbol.id] ?? {};
    if (site.isNotEmpty) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ParkingSiteScreen(parkingSite: site),
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
    for (var site in _parkingSites) {
      bool hasRealtimeData = site["has_realtime_data"];
      int? total = site["capacity_disabled"];
      int? occupied = site["occupied_disabled"];

      String iconName;
      if (!hasRealtimeData || total == null || occupied == null) {
        iconName = "parking_avbl_unknown.png";
      } else if (occupied < total) {
        iconName = "parking_avbl_yes.png";
      } else {
        iconName = "parking_avbl_no.png";
      }

      _mapController
          .addSymbol(
            SymbolOptions(
              geometry: site["coordinates"],
              iconImage: iconName,
              iconSize: 0.85,
            ),
          )
          .then((symbol) {
            _symbolIdToSite[symbol.id] = site;
          });
    }
  }
}
