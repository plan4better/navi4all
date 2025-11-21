import 'package:dio/dio.dart';
import 'package:intl/intl.dart';
import 'package:navi4all/core/config.dart';
import 'package:navi4all/schemas/routing/itinerary.dart';
import 'package:navi4all/services/api.dart';

class RoutingService extends APIService {
  Future<List<ItinerarySummary>> getItineraries({
    required double originLat,
    required double originLon,
    required double destinationLat,
    required double destinationLon,
    required DateTime time,
    bool timeIsArrival = false,
    required List<String> transportModes,
    required double walkingSpeed,
    required bool walkingAvoid,
    required double bicycleSpeed,
    required bool accessible,
    int numItineraries = 3,
  }) async {
    Response response = await apiClient.post(
      '/routing/plan',
      queryParameters: {'engine': Settings.apiRoutingEngine},
      data: {
        'origin': {'lat': originLat, 'lon': originLon},
        'destination': {'lat': destinationLat, 'lon': destinationLon},
        'date': DateFormat('yyyy-MM-dd').format(time),
        'time': DateFormat('HH:mm:ss').format(time),
        'time_is_arrival': timeIsArrival,
        'transport_modes': transportModes,
        'walk': {'speed': walkingSpeed, 'avoid': walkingAvoid},
        'bicycle': {'speed': bicycleSpeed},
        'accessible': accessible,
        'num_itineraries': numItineraries,
      },
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
