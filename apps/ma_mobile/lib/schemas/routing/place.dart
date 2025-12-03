import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:smartroots/schemas/routing/coordinates.dart';

part 'place.freezed.dart';
part 'place.g.dart';

@freezed
abstract class Place with _$Place {
  const factory Place({
    required String id,
    required String name,
    required PlaceType type,
    required String description,
    required String address,
    required Coordinates coordinates,
    String? street,
    String? locality,
    String? postcode,
    Map<String, dynamic>? attributes,
  }) = _Place;

  factory Place.fromJson(Map<String, Object?> json) => _$PlaceFromJson(json);
}

enum PlaceType { address, parkingSpot, parkingSite }
