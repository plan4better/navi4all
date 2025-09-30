import 'package:flutter/material.dart';
import 'package:smartroots/core/theme/colors.dart';
import 'package:smartroots/view/search/search.dart';
import 'package:smartroots/schemas/routing/place.dart';
import 'package:smartroots/view/common/sliding_bottom_sheet.dart';
import 'package:smartroots/view/place/map.dart';
import 'dart:core';
import 'package:smartroots/view/parking_site/parking_site.dart';

import 'package:maplibre_gl/maplibre_gl.dart';
import 'package:smartroots/services/poi_parking.dart';

class PlaceScreen extends StatefulWidget {
  final Place place;
  const PlaceScreen({required this.place, super.key});

  @override
  State<StatefulWidget> createState() => _PlaceScreenState();
}

class _PlaceScreenState extends State<PlaceScreen> {
  List<Widget> _getPlaceListItems() {
    return [
      for (var site in _parkingSites)
        PlaceListItem(place: widget.place, parkingSite: site),
    ];
  }

  List<Map<String, dynamic>> _parkingSites = [];

  Future<void> _fetchParkingSites() async {
    List<Map<String, dynamic>> sites = [];

    POIParkingService parkingService = POIParkingService();
    try {
      final response = await parkingService.parkingSites(
        focusPointLat: widget.place.coordinates.lat,
        focusPointLon: widget.place.coordinates.lon,
        radius: 300,
      );

      if (response.statusCode == 200) {
        final results = response.data['items'] as List;
        sites = results
            .map(
              (item) => {
                "name": item['name'],
                "coordinates": LatLng(
                  double.parse(item['lat']),
                  double.parse(item['lon']),
                ),
                "has_realtime_data": item['has_realtime_data'],
                "total_spaces": item['has_realtime_data']
                    ? item['realtime_capacity']
                    : item['capacity'],
                "occupied_spaces": item['has_realtime_data']
                    ? item['realtime_free_capacity']
                    : 0,
              },
            )
            .toList();
      } else {
        throw Exception('Failed to load parking sites.');
      }
    } catch (e) {
      print('Error fetching parking sites: $e');
      // Handle error appropriately, e.g., show a snackbar or dialog
    }

    setState(() {
      _parkingSites = sites;
    });
  }

  @override
  void initState() {
    _fetchParkingSites();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          PlaceMap(place: widget.place, radius: 300),
          SlidingBottomSheet(
            widget.place.name,
            widget.place.description,
            _getPlaceListItems(),
          ),
          SafeArea(
            child: Align(
              alignment: Alignment.topCenter,
              child: Padding(
                padding: const EdgeInsets.only(top: 32, left: 16, right: 16),
                child: Material(
                  elevation: 4,
                  borderRadius: BorderRadius.circular(28),
                  child: InkWell(
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => const SearchScreen(),
                        ),
                      );
                    },
                    child: Container(
                      height: 56,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(28),
                        color: SmartRootsColors.maWhite,
                      ),
                      child: Row(
                        children: [
                          IconButton(
                            icon: const Icon(
                              Icons.arrow_back,
                              color: SmartRootsColors.maBlueExtraExtraDark,
                            ),
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                          ),
                          Expanded(
                            child: Text(
                              widget.place.name,
                              style: const TextStyle(
                                fontSize: 16,
                                color: SmartRootsColors.maBlueExtraExtraDark,
                              ),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                            ),
                          ),
                          SizedBox(width: 16),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class PlaceListItem extends StatelessWidget {
  final Place place;
  final Map<String, dynamic> parkingSite;
  const PlaceListItem({
    required this.place,
    required this.parkingSite,
    super.key,
  });

  String _getOccupancyText() {
    if (parkingSite["has_realtime_data"]) {
      return '${parkingSite["occupied_spaces"] ?? '?'}/${parkingSite["total_spaces"] ?? '?'}';
    } else {
      return '?/${parkingSite["total_spaces"] ?? '?'}';
    }
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) =>
                ParkingSiteScreen(place: place, parkingSite: parkingSite),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    parkingSite["name"],
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: SmartRootsColors.maBlueExtraExtraDark,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        Icons.directions_car_outlined,
                        color: SmartRootsColors.maBlueExtraExtraDark,
                        size: 20,
                      ),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          '',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: SmartRootsColors.maBlueExtraExtraDark,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(width: 16),
            Text(
              _getOccupancyText(),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: SmartRootsColors.maBlueExtraExtraDark,
                fontSize: 16,
              ),
            ),
            SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: parkingSite['has_realtime_data']
                    ? SmartRootsColors.maBlueExtraExtraDark
                    : SmartRootsColors.maBlue,
                borderRadius: BorderRadius.circular(32),
              ),
              child: Row(
                children: [
                  Icon(
                    parkingSite['has_realtime_data']
                        ? Icons.local_parking
                        : Icons.question_mark,
                    size: 16,
                    color: SmartRootsColors.maWhite,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
