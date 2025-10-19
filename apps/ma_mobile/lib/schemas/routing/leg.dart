import 'package:freezed_annotation/freezed_annotation.dart';
import 'mode.dart';

part 'leg.freezed.dart';
part 'leg.g.dart';

@freezed
abstract class LegSummary with _$LegSummary {
  const factory LegSummary({
    required Mode mode,
    required int duration,
    required int distance,
    required double ratio,
    required String geometry,
  }) = _LegSummary;

  factory LegSummary.fromJson(Map<String, Object?> json) =>
      _$LegSummaryFromJson(json);
}

@freezed
abstract class LegDetailed with _$LegDetailed {
  const factory LegDetailed({
    required Mode mode,
    required int duration,
    required int distance,
    required String geometry,
    required List<Step> steps,
  }) = _LegDetailed;

  factory LegDetailed.fromJson(Map<String, Object?> json) =>
      _$LegDetailedFromJson(json);
}

@freezed
abstract class Step with _$Step {
  const factory Step({
    required double distance,
    required double lat,
    required double lon,
    @JsonKey(name: "relative_direction")
    required RelativeDirection relativeDirection,
    @JsonKey(name: "absolute_direction")
    required AbsoluteDirection absoluteDirection,
    @JsonKey(name: "street_name") required String streetName,
    @JsonKey(name: "bogus_name") required bool bogusName,
  }) = _Step;

  factory Step.fromJson(Map<String, Object?> json) => _$StepFromJson(json);
}
