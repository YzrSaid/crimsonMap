import '../entities/route_path.dart';
import '../repositories/ar_navigation_repository.dart';

class GetArRoute {
  final ArNavigationRepository repository;
  const GetArRoute(this.repository);

  Future<RoutePath> call({
    required String destinationId,
    required double userLatitude,
    required double userLongitude,
  }) =>
      repository.getArRoute(
        destinationId: destinationId,
        userLatitude: userLatitude,
        userLongitude: userLongitude,
      );
}
