import 'waypoint.dart';
import 'ar_marker.dart';

class RoutePath {
  final String id;
  final String destinationId;
  final List<Waypoint> waypoints;
  final List<ArMarker> markers;
  final double totalDistanceMeters;

  const RoutePath({
    required this.id,
    required this.destinationId,
    required this.waypoints,
    required this.markers,
    required this.totalDistanceMeters,
  });
}
