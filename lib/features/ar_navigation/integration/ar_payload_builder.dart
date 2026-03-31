import '../domain/entities/route_path.dart';

/// Converts a [RoutePath] into the JSON payload expected by the Unity AR module.
/// The Unity side reads this map via the [UnityBridgeService] method channel.
class ArPayloadBuilder {
  ArPayloadBuilder._();

  static Map<String, dynamic> build(RoutePath route) {
    return {
      'routeId': route.id,
      'destinationId': route.destinationId,
      'totalDistanceMeters': route.totalDistanceMeters,
      'waypoints': route.waypoints
          .map((w) => {
                'order': w.order,
                'lat': w.latitude,
                'lon': w.longitude,
                'instruction': w.instruction,
              })
          .toList(),
      'markers': route.markers
          .map((m) => {
                'id': m.id,
                'lat': m.latitude,
                'lon': m.longitude,
                'label': m.label,
                'altitude': m.altitude,
              })
          .toList(),
    };
  }
}
