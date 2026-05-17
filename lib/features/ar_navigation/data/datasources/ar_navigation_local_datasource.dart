import 'package:geolocator/geolocator.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/services/local_data_service.dart';
import '../models/route_path_model.dart';

// AR routes are computed by Unity (it owns nodes/edges + pathfinding).
// On the Flutter side we just need a minimal RoutePath: destination metadata
// + straight-line distance for the "X meters away" display in ar_info_card.
// Unity computes the actual walkable waypoints once it receives the payload.
class ArNavigationLocalDatasource {
  final LocalDataService _data;
  ArNavigationLocalDatasource({LocalDataService? data})
      : _data = data ?? LocalDataService.instance;

  Future<RoutePathModel> getArRoute({
    required String destinationId,
    required double userLatitude,
    required double userLongitude,
  }) async {
    try {
      final nodesByInfra = await _data.infraNodesByInfraId();
      final node = nodesByInfra[destinationId];
      if (node == null) {
        throw ServerException('Destination $destinationId not found in nodes');
      }
      final destLat = (node['latitude'] as num).toDouble();
      final destLng = (node['longitude'] as num).toDouble();

      final straightLine = Geolocator.distanceBetween(
        userLatitude, userLongitude, destLat, destLng,
      );

      return RoutePathModel(
        id: 'local-${DateTime.now().millisecondsSinceEpoch}',
        destinationId: destinationId,
        waypoints: const [],
        markers: const [],
        totalDistanceMeters: straightLine,
      );
    } catch (e) {
      if (e is ServerException) rethrow;
      throw ServerException(e.toString());
    }
  }
}
