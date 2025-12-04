import 'dart:math';
import 'dart:core';

import 'package:flutter/material.dart';
import 'package:maplibre_gl/maplibre_gl.dart';
// import 'package:matomo_tracker/matomo_tracker.dart';
import 'package:provider/provider.dart';
import 'package:navi4all/controllers/theme_controller.dart';
// import 'package:navi4all/core/analytics/events.dart';
import 'package:navi4all/core/config.dart';
import 'package:navi4all/core/persistence/preference_helper.dart';
import 'package:navi4all/core/theme/base_map_style.dart';
import 'package:navi4all/l10n/app_localizations.dart';
import 'package:navi4all/view/common/selection_tile.dart';
import 'package:navi4all/view/common/sheet_button.dart';
import 'package:geolocator/geolocator.dart';

class HomeMap extends StatefulWidget {
  const HomeMap({super.key});

  @override
  State<StatefulWidget> createState() => _HomeMapState();
}

class _HomeMapState extends State<HomeMap> {
  late MapLibreMapController _mapController;
  bool _canInteractWithMap = false;
  final List<Map<String, dynamic>> _parkingSites = [];
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

                            // Analytics event
                            /* MatomoTracker.instance.trackEvent(
                              eventInfo: EventInfo(
                                category: EventCategory.homeMapScreen
                                    .toString(),
                                action: EventAction.homeMapScreenBaseMapChanged
                                    .toString(),
                              ),
                            ); */
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
    /* _fetchParkingSites().then((_) {
      // Add circle tap listener
      _mapController.onCircleTapped.add(_onCircleTapped);

      // Pan to user location by default if location access was granted
      Geolocator.checkPermission().then((permission) {
        if (permission != LocationPermission.denied &&
            permission != LocationPermission.deniedForever) {
          _panToUserLocation();
        }
      });
    }); */

    await Future.delayed(const Duration(milliseconds: 250));
    setState(() => _canInteractWithMap = true);
  }

  /* Future<void> _fetchParkingSites() async {
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
  } */

  void _onCircleTapped(Circle circle) {
    /* final site = _symbolIdToSite[circle.id] ?? {};
    if (site.isNotEmpty) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ParkingLocationScreen(parkingLocation: site),
        ),
      );
    } */

    // Analytics event
    /* MatomoTracker.instance.trackEvent(
      eventInfo: EventInfo(
        category: EventCategory.homeMapScreen.toString(),
        action: EventAction.homeMapScreenParkingLocationMarkerClicked
            .toString(),
      ),
    ); */
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
              target: LatLng(
                Settings.defaultFocalPoint.lat,
                Settings.defaultFocalPoint.lon,
              ),
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
                      color: Theme.of(context).textTheme.displayMedium?.color,
                    ),
                  ),
                  SizedBox(height: 16),
                  FloatingActionButton(
                    shape: CircleBorder(),
                    backgroundColor: Theme.of(context).colorScheme.secondary,
                    onPressed: () => _panToUserLocation(),
                    child: Icon(
                      Icons.my_location,
                      color: Theme.of(context).textTheme.displayMedium?.color,
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
}
