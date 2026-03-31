import '../entities/destination.dart';
import '../repositories/explore_repository.dart';

class SearchDestinations {
  final ExploreRepository repository;
  const SearchDestinations(this.repository);

  Future<List<Destination>> call(String query) =>
      repository.searchDestinations(query);
}
