import 'dart:math';
import 'dart:core';

import 'package:flutter/material.dart';
import 'package:maplibre_gl/maplibre_gl.dart';
import 'package:provider/provider.dart';
import 'package:smartroots/controllers/core/theme_controller.dart';
import 'package:smartroots/core/config.dart';
import 'package:smartroots/core/persistence/preference_helper.dart';
import 'package:smartroots/core/theme/base_map_style.dart';
import 'package:smartroots/core/theme/colors.dart';
import 'package:smartroots/l10n/app_localizations.dart';
import 'package:smartroots/services/poi_parking.dart';
import 'package:smartroots/view/common/selection_tile.dart';
import 'package:smartroots/view/common/sheet_button.dart';
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

  void _onLayersButtonPressed() {
    BaseMapStyle selectedBaseMapStyle = Provider.of<ThemeController>(
      context,
      listen: false,
    ).baseMapStyle;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setStateDialog) => Dialog(
            backgroundColor: Theme.of(context).colorScheme.surface,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(32),
            ),
            child: Container(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Align(
                    alignment: Alignment.topLeft,
                    child: Text(
                      AppLocalizations.of(context)!.homeChangeBaseMapTitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: SmartRootsColors.maBlueExtraExtraDark,
                      ),
                    ),
                  ),
                  SizedBox(height: 24),
                  Column(
                    children: [
                      SelectionTile(
                        title: getBaseMapStyleTitle(
                          context,
                          BaseMapStyle.light,
                        ),
                        isSelected: selectedBaseMapStyle == BaseMapStyle.light,
                        leadingImage: 'assets/base_map_light_thumbnail.png',
                        onTap: () {
                          setStateDialog(() {
                            selectedBaseMapStyle = BaseMapStyle.light;
                          });
                        },
                      ),
                      SizedBox(height: 16),
                      SelectionTile(
                        title: getBaseMapStyleTitle(context, BaseMapStyle.dark),
                        isSelected: selectedBaseMapStyle == BaseMapStyle.dark,
                        leadingImage: 'assets/base_map_dark_thumbnail.png',
                        onTap: () {
                          setStateDialog(() {
                            selectedBaseMapStyle = BaseMapStyle.dark;
                          });
                        },
                      ),
                      SizedBox(height: 16),
                      SelectionTile(
                        title: getBaseMapStyleTitle(
                          context,
                          BaseMapStyle.satellite,
                        ),
                        isSelected:
                            selectedBaseMapStyle == BaseMapStyle.satellite,
                        leadingImage: 'assets/base_map_satellite_thumbnail.png',
                        onTap: () {
                          setStateDialog(() {
                            selectedBaseMapStyle = BaseMapStyle.satellite;
                          });
                        },
                      ),
                    ],
                  ),
                  SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: SheetButton(
                          label: AppLocalizations.of(
                            context,
                          )!.placeScreenChangeRadiusCancel,
                          onTap: () {
                            selectedBaseMapStyle = Provider.of<ThemeController>(
                              context,
                              listen: false,
                            ).baseMapStyle;
                            Navigator.of(context).pop();
                          },
                        ),
                      ),
                      SizedBox(width: 8),
                      Expanded(
                        child: SheetButton(
                          label: AppLocalizations.of(
                            context,
                          )!.placeScreenChangeRadiusConfirm,
                          onTap: () {
                            PreferenceHelper.setBaseMapStyle(
                              selectedBaseMapStyle,
                            );
                            setState(() {
                              Provider.of<ThemeController>(
                                context,
                                listen: false,
                              ).setBaseMapStyle(selectedBaseMapStyle);
                              Navigator.of(context).pop();
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> _onStyleLoaded() async {
    // Clear existing markers and listeners
    await _mapController.clearCircles();
    _mapController.onCircleTapped.clear();

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
        Consumer<ThemeController>(
          builder: (context, themeController, _) => MapLibreMap(
            myLocationEnabled: true,
            styleString:
                Settings.baseMapStyleUrls[themeController.baseMapStyle]!,
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
        ),
        // Fill screen with background while map is loading
        !_canInteractWithMap
            ? Container(color: Theme.of(context).colorScheme.surface)
            : SizedBox.shrink(),
        SafeArea(
          child: Align(
            alignment: Alignment.bottomRight,
            child: Padding(
              padding: const EdgeInsets.only(right: 16, bottom: 112),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  FloatingActionButton(
                    shape: CircleBorder(),
                    backgroundColor: Theme.of(context).colorScheme.secondary,
                    onPressed: () => _onLayersButtonPressed(),
                    child: Icon(
                      Icons.layers,
                      color: SmartRootsColors.maBlueExtraExtraDark,
                    ),
                  ),
                  SizedBox(height: 16),
                  FloatingActionButton(
                    shape: CircleBorder(),
                    backgroundColor: Theme.of(context).colorScheme.secondary,
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
