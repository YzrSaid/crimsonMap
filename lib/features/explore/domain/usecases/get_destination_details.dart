import '../entities/destination.dart';
import '../repositories/explore_repository.dart';

class GetDestinationDetails {
  final ExploreRepository repository;
  const GetDestinationDetails(this.repository);

  Future<Destination> call(String id) => repository.getDestinationDetails(id);
}
