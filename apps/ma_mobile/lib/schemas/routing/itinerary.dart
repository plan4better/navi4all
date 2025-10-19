import 'package:freezed_annotation/freezed_annotation.dart';
import 'coordinates.dart';
import 'leg.dart';

part 'itinerary.freezed.dart';
part 'itinerary.g.dart';

@freezed
abstract class ItinerarySummary with _$ItinerarySummary {
  const factory ItinerarySummary({
    @JsonKey(name: 'itinerary_id') required String itineraryId,
    required int duration,
    @JsonKey(name: 'start_time') required DateTime startTime,
    @JsonKey(name: 'end_time') required DateTime endTime,
    required Coordinates origin,
    required Coordinates destination,
    required List<LegSummary> legs,
  }) = _ItinerarySummary;

  factory ItinerarySummary.fromJson(Map<String, Object?> json) =>
      _$ItinerarySummaryFromJson(json);
}

@freezed
abstract class ItineraryDetails with _$ItineraryDetails {
  const factory ItineraryDetails({
    @JsonKey(name: 'itinerary_id') required String itineraryId,
    required int duration,
    @JsonKey(name: 'start_time') required DateTime startTime,
    @JsonKey(name: 'end_time') required DateTime endTime,
    required Coordinates origin,
    required Coordinates destination,
    required List<LegDetailed> legs,
  }) = _ItineraryDetails;

  factory ItineraryDetails.fromJson(Map<String, Object?> json) =>
      _$ItineraryDetailsFromJson(json);
}
