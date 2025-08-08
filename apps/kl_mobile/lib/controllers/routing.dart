import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:navi4all/schemas/routing/itinerary.dart';
import 'package:navi4all/schemas/routing/place.dart';
import 'package:navi4all/services/routing.dart';
import 'package:navi4all/schemas/routing/mode.dart';

/*
  TODO: WORK IN PROGRESS
 */
class RoutingController extends ChangeNotifier {
  RoutingService routingService = RoutingService();

  // TODO: Use status codes for operation progress tracking
  bool operationInProgress = false;
  // TODO: Use error codes for operation error tracking
  String operationErrorCode = '';

  Place? originPlace;
  Place? destinationPlace;
  Mode? mode;

  // TODO: Use model to manage routing preferences

  List<Itinerary> itineraries = [];

  bool isControllerConfigured() {
    // TODO: Perform addtional validation on origin-destination pair
    return originPlace != null && destinationPlace != null && mode != null;
  }

  void setOriginPlace(Place place) {
    // TODO: Validate the place before setting
    originPlace = place;
    notifyListeners();

    _triggerFetch();
  }

  void setDestinationPlace(Place place) {
    // TODO: Validate the place before setting
    destinationPlace = place;
    notifyListeners();

    _triggerFetch();
  }

  Future<void> _triggerFetch() async {
    // Ensure the controller is configured
    if (!isControllerConfigured()) {
      return;
    }

    // Notify listeners an operation is in progress
    operationInProgress = true;
    notifyListeners();

    // Fetch itineraries
    try {
      final Response response = await routingService.getItineraries(
        originLat: originPlace!.coordinates.lat,
        originLon: originPlace!.coordinates.lon,
        destinationLat: destinationPlace!.coordinates.lat,
        destinationLon: destinationPlace!.coordinates.lon,
        date: '2024-12-05',
        time: '09:00:00',
        timeIsArrival: false,
        transportModes: [mode!.name],
      );
      if (response.statusCode == 200) {
        final data = response.data["itineraries"] as List;
        itineraries = data.map((item) => Itinerary.fromJson(item)).toList();
      } else {
        // TODO: Use appropriate error code
        throw Exception('Failed to fetch itineraries');
      }
    } catch (e) {
      // TODO: Handle error via error codes
    } finally {
      // Notify listeners the operation is complete
      operationInProgress = false;
      notifyListeners();
    }
  }
}
