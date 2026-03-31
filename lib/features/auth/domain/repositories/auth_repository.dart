import '../entities/user.dart';

abstract class AuthRepository {
  Future<AppUser> signIn({required String email, required String password});
  Future<void> signOut();
  Future<AppUser?> getCurrentUser();
}
