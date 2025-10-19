import 'dart:math';
import 'dart:core';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:maplibre_gl/maplibre_gl.dart';
import 'package:smartroots/core/config.dart';

class ParkingSiteMap extends StatefulWidget {
  final Map<String, dynamic> parkingSite;
  const ParkingSiteMap({required this.parkingSite, super.key});

  @override
  State<StatefulWidget> createState() => _ParkingSiteMapState();
}

class _ParkingSiteMapState extends State<ParkingSiteMap> {
  late MapLibreMapController _mapController;

  Future<void> _onStyleLoaded() async {
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

    await Future.delayed(const Duration(milliseconds: 500));
    _drawPlace();
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
            target: LatLng(
              widget.parkingSite['coordinates'].latitude - 0.003,
              widget.parkingSite['coordinates'].longitude,
            ),
            zoom: 14,
          ),
          onStyleLoadedCallback: _onStyleLoaded,
          compassViewMargins: const Point(16, 160),
          compassViewPosition: CompassViewPosition.topRight,
        ),
        /*SafeArea(
          child: Align(
            alignment: Alignment.bottomRight,
            child: Padding(
              padding: const EdgeInsets.only(right: 16, bottom: 128),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  FloatingActionButton(
                    onPressed: () {},
                    child: Icon(Icons.layers),
                  ),
                  SizedBox(height: 16),
                  FloatingActionButton(
                    onPressed: () {
                      _mapController.requestMyLocationLatLng().then((latLng) {
                        if (latLng != null) {
                          _mapController.animateCamera(
                            CameraUpdate.newCameraPosition(
                              CameraPosition(target: latLng, zoom: 14.0),
                            ),
                            duration: const Duration(seconds: 2),
                          );
                        }
                      });
                    },
                    child: Icon(Icons.my_location),
                  ),
                ],
              ),
            ),
          ),
        ),*/
      ],
    );
  }

  void _drawPlace() {
    bool hasRealtimeData = widget.parkingSite["has_realtime_data"];
    int? total = widget.parkingSite["capacity_disabled"];
    int? occupied = widget.parkingSite["occupied_disabled"];

    String iconName;
    if (!hasRealtimeData || total == null || occupied == null) {
      iconName = "parking_avbl_unknown.png";
    } else if (occupied < total) {
      iconName = "parking_avbl_yes.png";
    } else {
      iconName = "parking_avbl_no.png";
    }

    _mapController.addSymbol(
      SymbolOptions(
        geometry: widget.parkingSite["coordinates"],
        iconImage: iconName,
        iconSize: 0.85,
      ),
    );
  }
}
