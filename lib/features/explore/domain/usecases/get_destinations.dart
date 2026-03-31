import '../entities/destination.dart';
import '../repositories/explore_repository.dart';

class GetDestinations {
  final ExploreRepository repository;
  const GetDestinations(this.repository);

  Future<List<Destination>> call() => repository.getDestinations();
}
