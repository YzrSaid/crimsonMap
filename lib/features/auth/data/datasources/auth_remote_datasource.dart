import '../../../../core/errors/exceptions.dart';
import '../../../../core/services/supabase_service.dart';
import '../models/user_model.dart';

class AuthRemoteDatasource {
  Future<UserModel> signIn({required String email, required String password}) async {
    try {
      final response = await SupabaseService.auth.signInWithPassword(
        email: email,
        password: password,
      );
      final user = response.user;
      if (user == null) throw const AuthException('Sign in failed.');
      return UserModel(id: user.id, email: user.email ?? '');
    } catch (e) {
      throw AuthException(e.toString());
    }
  }

  Future<void> signOut() async {
    try {
      await SupabaseService.auth.signOut();
    } catch (e) {
      throw AuthException(e.toString());
    }
  }

  Future<UserModel?> getCurrentUser() async {
    final user = SupabaseService.auth.currentUser;
    if (user == null) return null;
    return UserModel(id: user.id, email: user.email ?? '');
  }
}
