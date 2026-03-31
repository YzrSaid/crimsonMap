import '../../domain/entities/destination.dart';
import '../../domain/entities/building.dart';
import '../../domain/entities/category.dart';
import '../../domain/repositories/explore_repository.dart';
import '../datasources/explore_remote_datasource.dart';

class ExploreRepositoryImpl implements ExploreRepository {
  final ExploreRemoteDatasource _datasource;

  ExploreRepositoryImpl({ExploreRemoteDatasource? datasource})
      : _datasource = datasource ?? ExploreRemoteDatasource();

  @override
  Future<List<Destination>> getDestinations() => _datasource.getDestinations();

  @override
  Future<List<Destination>> searchDestinations(String query) =>
      _datasource.searchDestinations(query);

  @override
  Future<Destination> getDestinationDetails(String id) =>
      _datasource.getDestinationDetails(id);

  @override
  Future<List<Building>> getBuildings() => _datasource.getBuildings();

  @override
  Future<List<Category>> getCategories() => _datasource.getCategories();
}
