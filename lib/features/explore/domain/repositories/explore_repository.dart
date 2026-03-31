import '../entities/destination.dart';
import '../entities/building.dart';
import '../entities/category.dart';

abstract class ExploreRepository {
  Future<List<Destination>> getDestinations();
  Future<List<Destination>> searchDestinations(String query);
  Future<Destination> getDestinationDetails(String id);
  Future<List<Building>> getBuildings();
  Future<List<Category>> getCategories();
}
