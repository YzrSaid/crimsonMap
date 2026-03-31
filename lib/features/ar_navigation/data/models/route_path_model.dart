import '../../domain/entities/route_path.dart';
import 'ar_marker_model.dart';
import 'waypoint_model.dart';

class RoutePathModel extends RoutePath {
  const RoutePathModel({
    required super.id,
    required super.destinationId,
    required super.waypoints,
    required super.markers,
    required super.totalDistanceMeters,
  });

  factory RoutePathModel.fromJson(Map<String, dynamic> json) => RoutePathModel(
        id: json['id'] as String,
        destinationId: json['destination_id'] as String,
        waypoints: (json['waypoints'] as List)
            .map((e) => WaypointModel.fromJson(e as Map<String, dynamic>))
            .toList(),
        markers: (json['markers'] as List)
            .map((e) => ArMarkerModel.fromJson(e as Map<String, dynamic>))
            .toList(),
        totalDistanceMeters: (json['total_distance_meters'] as num).toDouble(),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'destination_id': destinationId,
        'waypoints': waypoints.map((w) => (w as WaypointModel).toJson()).toList(),
        'markers': markers.map((m) => (m as ArMarkerModel).toJson()).toList(),
        'total_distance_meters': totalDistanceMeters,
      };
}
