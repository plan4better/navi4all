import 'package:freezed_annotation/freezed_annotation.dart';
import 'coordinates.dart';
import 'leg.dart';

part 'itinerary.freezed.dart';
part 'itinerary.g.dart';

@freezed
abstract class Itinerary with _$Itinerary {
  const factory Itinerary({
    @JsonKey(name: 'journey_id') required String journeyId,
    required int duration,
    @JsonKey(name: 'start_time') required DateTime startTime,
    @JsonKey(name: 'end_time') required DateTime endTime,
    required Coordinates origin,
    required Coordinates destination,
    required List<LegSummary> legs,
  }) = _Itinerary;

  factory Itinerary.fromJson(Map<String, Object?> json) =>
      _$ItineraryFromJson(json);
}
