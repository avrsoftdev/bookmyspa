import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/google_auth_data_source.dart';
import '../mappers/user_mapper.dart';

class AuthRepositoryImpl implements AuthRepository {
  final GoogleAuthDataSource google;

  AuthRepositoryImpl({required this.google});

  @override
  Future<User> login({required String email, required String password}) async {
    final dto = await google.signIn();
    return UserMapper.toDomain(dto);
  }

  @override
  Future<User> signInWithGoogle() async {
    final dto = await google.signIn();
    return UserMapper.toDomain(dto);
  }

  @override
  Future<void> signOut() async {
    await google.signOut();
  }
}
