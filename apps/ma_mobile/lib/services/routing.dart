import 'package:dio/dio.dart';
import 'package:smartroots/services/api.dart';

class RoutingService extends APIService {
  Future<Response> getItineraries({
    required double originLat,
    required double originLon,
    required double destinationLat,
    required double destinationLon,
    required String date,
    required String time,
    bool timeIsArrival = false,
    required List<String> transportModes,
    bool accessible = false,
    int numItineraries = 3,
  }) async => apiClient.post(
    '/routing/plan',
    data: {
      'origin': {'lat': originLat, 'lon': originLon},
      'destination': {'lat': destinationLat, 'lon': destinationLon},
      'date': date,
      'time': time,
      'time_is_arrival': timeIsArrival,
      'transport_modes': transportModes,
      'accessible': accessible,
      'num_itineraries': numItineraries,
    },
  );

  Future<Response> getItineraryDetails({required String itineraryId}) async =>
      apiClient.get('/routing/itinerary/$itineraryId');
}
