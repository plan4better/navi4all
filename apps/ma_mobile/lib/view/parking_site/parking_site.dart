import 'package:flutter/material.dart';
import 'package:smartroots/core/theme/colors.dart';
import 'package:smartroots/view/search/search.dart';
import 'package:smartroots/schemas/routing/place.dart';
import 'package:smartroots/view/parking_site/sliding_bottom_sheet.dart';
import 'package:smartroots/view/parking_site/map.dart';
import 'dart:core';

import 'package:maplibre_gl/maplibre_gl.dart';
import 'package:smartroots/services/poi_parking.dart';

import 'package:intl/intl.dart';
import 'package:smartroots/schemas/routing/coordinates.dart';
import 'package:smartroots/services/routing.dart';
import 'package:smartroots/schemas/routing/itinerary.dart';
import 'package:smartroots/schemas/routing/mode.dart';
import 'package:smartroots/schemas/routing/place.dart';
import 'package:smartroots/core/theme/values.dart';
import 'package:smartroots/core/persistence/processing_status.dart';
import 'package:smartroots/view/search/search.dart';

class ParkingSiteScreen extends StatefulWidget {
  final Place? place;
  final Map<String, dynamic> parkingSite;
  const ParkingSiteScreen({this.place, required this.parkingSite, super.key});

  @override
  State<StatefulWidget> createState() => _ParkingSiteScreenState();
}

class _ParkingSiteScreenState extends State<ParkingSiteScreen> {
  List<Widget> _getPlaceListItems() {
    return [for (var site in _parkingSites) PlaceListItem(parkingSite: site)];
  }

  List<Map<String, dynamic>> _parkingSites = [];
  List<Itinerary> _itineraries = [];
  ProcessingStatus _processingStatus = ProcessingStatus.idle;

  @override
  void initState() {
    super.initState();
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
        originLat: 49.48874453098431,
        originLon: 8.466156569942742,
        destinationLat: widget.parkingSite['coordinates'].latitude,
        destinationLon: widget.parkingSite['coordinates'].longitude,
        date: DateFormat('yyyy-MM-dd').format(DateTime.now()),
        time: DateFormat('HH:mm:ss').format(DateTime.now()),
        timeIsArrival: false,
        transportModes: ["CAR"],
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          ParkingSiteMap(parkingSite: widget.parkingSite),
          SlidingBottomSheet(
            widget.parkingSite["name"],
            widget.place?.description ?? '',
            _itineraries.isNotEmpty ? _itineraries.first.duration ~/ 60 : null,
            _getPlaceListItems(),
            widget.parkingSite,
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
                              widget.parkingSite["name"],
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
  final Map<String, dynamic> parkingSite;
  const PlaceListItem({required this.parkingSite, super.key});

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
      onTap: () {},
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
