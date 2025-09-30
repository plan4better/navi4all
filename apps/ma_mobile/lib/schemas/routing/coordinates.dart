import 'package:freezed_annotation/freezed_annotation.dart';

part 'coordinates.freezed.dart';
part 'coordinates.g.dart';

@freezed
abstract class Coordinates with _$Coordinates {
  const factory Coordinates({required double lat, required double lon}) =
      _Coordinates;

  factory Coordinates.fromJson(Map<String, Object?> json) =>
      _$CoordinatesFromJson(json);
}
