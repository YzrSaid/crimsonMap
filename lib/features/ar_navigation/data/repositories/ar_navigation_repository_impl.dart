import '../../domain/entities/route_path.dart';
import '../../domain/repositories/ar_navigation_repository.dart';
import '../datasources/ar_navigation_local_datasource.dart';

class ArNavigationRepositoryImpl implements ArNavigationRepository {
  final ArNavigationLocalDatasource _datasource;

  ArNavigationRepositoryImpl({ArNavigationLocalDatasource? datasource})
      : _datasource = datasource ?? ArNavigationLocalDatasource();

  @override
  Future<RoutePath> getArRoute({
    required String destinationId,
    required double userLatitude,
    required double userLongitude,
  }) =>
      _datasource.getArRoute(
        destinationId: destinationId,
        userLatitude: userLatitude,
        userLongitude: userLongitude,
      );
}
