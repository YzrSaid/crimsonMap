import '../../domain/entities/waypoint.dart';

class WaypointModel extends Waypoint {
  const WaypointModel({
    required super.order,
    required super.latitude,
    required super.longitude,
    super.instruction,
  });

  factory WaypointModel.fromJson(Map<String, dynamic> json) => WaypointModel(
        order: json['order'] as int,
        latitude: (json['latitude'] as num).toDouble(),
        longitude: (json['longitude'] as num).toDouble(),
        instruction: json['instruction'] as String?,
      );

  Map<String, dynamic> toJson() => {
        'order': order,
        'latitude': latitude,
        'longitude': longitude,
        'instruction': instruction,
      };
}
