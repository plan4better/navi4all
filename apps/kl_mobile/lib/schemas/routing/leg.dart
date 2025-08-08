import 'package:freezed_annotation/freezed_annotation.dart';
import 'mode.dart';

part 'leg.freezed.dart';
part 'leg.g.dart';

@freezed
abstract class LegSummary with _$LegSummary {
  const factory LegSummary({
    required Mode mode,
    required int duration,
    required double ratio,
  }) = _LegSummary;

  factory LegSummary.fromJson(Map<String, Object?> json) =>
      _$LegSummaryFromJson(json);
}
