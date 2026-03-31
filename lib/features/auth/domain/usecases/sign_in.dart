import '../entities/user.dart';
import '../repositories/auth_repository.dart';

class SignIn {
  final AuthRepository repository;
  const SignIn(this.repository);

  Future<AppUser> call({required String email, required String password}) =>
      repository.signIn(email: email, password: password);
}
