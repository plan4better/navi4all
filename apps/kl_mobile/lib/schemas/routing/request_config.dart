import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:navi4all/schemas/routing/mode.dart';

part 'request_config.freezed.dart';
part 'request_config.g.dart';

@freezed
abstract class RoutingRequestConfig with _$RoutingRequestConfig {
  const factory RoutingRequestConfig({
    required double walkingSpeed,
    required bool walkingAvoid,
    required List<Mode> transitModes,
    required double bicycleSpeed,
    required bool accessible,
  }) = _RoutingRequestConfig;

  factory RoutingRequestConfig.fromJson(Map<String, dynamic> json) =>
      _$RoutingRequestConfigFromJson(json);
}
