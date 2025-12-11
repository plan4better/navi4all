import 'package:dio/dio.dart';
import 'package:intl/intl.dart';
import 'package:smartroots/core/config.dart';
import 'package:smartroots/schemas/routing/itinerary.dart';
import 'package:smartroots/services/api.dart';

class RoutingService extends APIService {
  Future<List<ItinerarySummary>> getItineraries({
    required double originLat,
    required double originLon,
    required double destinationLat,
    required double destinationLon,
    required DateTime time,
    bool timeIsArrival = false,
    required List<String> transportModes,
    double? walkingSpeed,
    bool? walkingAvoid,
    double? bicycleSpeed,
    bool? accessible,
    int numItineraries = 3,
  }) async {
    // Build request body
    Map<String, dynamic> data = {
      'origin': {'lat': originLat, 'lon': originLon},
      'destination': {'lat': destinationLat, 'lon': destinationLon},
      'date': DateFormat('yyyy-MM-dd').format(time),
      'time': DateFormat('HH:mm:ss').format(time),
      'time_is_arrival': timeIsArrival,
      'transport_modes': transportModes,
      'num_itineraries': numItineraries,
    };
    if (walkingSpeed != null && walkingAvoid != null) {
      data['walk'] = {'speed': walkingSpeed, 'avoid': walkingAvoid};
    }
    if (bicycleSpeed != null) {
      data['bicycle'] = {'speed': bicycleSpeed};
    }
    if (accessible != null) {
      data['accessible'] = accessible;
    }

    // Make request
    Response response = await apiClient.post(
      '/routing/plan',
      queryParameters: {'engine': Settings.apiRoutingEngine},
      data: data,
    );

    if (response.statusCode != 200) {
      throw Exception(response.statusMessage);
    }
    return (response.data['itineraries'] as List)
        .map((item) => ItinerarySummary.fromJson(item))
        .toList();
  }

  Future<ItineraryDetails> getItineraryDetails({
    required String itineraryId,
  }) async => ItineraryDetails.fromJson(
    (await apiClient.get(
      '/routing/itinerary/$itineraryId',
      queryParameters: {'engine': Settings.apiRoutingEngine},
    )).data,
  );
}
