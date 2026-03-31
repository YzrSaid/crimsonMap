import '../entities/route_path.dart';

abstract class ArNavigationRepository {
  Future<RoutePath> getArRoute({
    required String destinationId,
    required double userLatitude,
    required double userLongitude,
  });
}
