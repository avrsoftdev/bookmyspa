import '../entities/user.dart';

abstract class AuthRepository {
  Future<User> login({required String email, required String password});
  Future<User> signInWithGoogle();
  Future<void> signOut();
  Future<User?> checkAuthStatus();
}
