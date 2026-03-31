import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_datasource.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDatasource _datasource;

  AuthRepositoryImpl({AuthRemoteDatasource? datasource})
      : _datasource = datasource ?? AuthRemoteDatasource();

  @override
  Future<AppUser> signIn({required String email, required String password}) =>
      _datasource.signIn(email: email, password: password);

  @override
  Future<void> signOut() => _datasource.signOut();

  @override
  Future<AppUser?> getCurrentUser() => _datasource.getCurrentUser();
}
