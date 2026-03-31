import '../entities/user.dart';
import '../repositories/auth_repository.dart';

class GetCurrentUser {
  final AuthRepository repository;
  const GetCurrentUser(this.repository);

  Future<AppUser?> call() => repository.getCurrentUser();
}
