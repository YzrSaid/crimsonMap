import '../../domain/entities/route_path.dart';
import '../../domain/repositories/ar_navigation_repository.dart';
import '../datasources/ar_navigation_remote_datasource.dart';

class ArNavigationRepositoryImpl implements ArNavigationRepository {
  final ArNavigationRemoteDatasource _datasource;

  ArNavigationRepositoryImpl({ArNavigationRemoteDatasource? datasource})
      : _datasource = datasource ?? ArNavigationRemoteDatasource();

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
