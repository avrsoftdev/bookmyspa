import '../../../../../../src/features/auth/domain/entities/user.dart';
import '../../../../../../src/features/auth/domain/repositories/auth_repository.dart';

/// Admin login use case that validates admin emails
class AdminLoginUseCase {
  final AuthRepository authRepository;

  /// List of allowed admin emails
  static const List<String> adminEmails = [
    'avrsoftdev@gmail.com',
    'pratham.chitransh@gmail.com',
  ];

  AdminLoginUseCase(this.authRepository);

  /// Signs in with Google and validates that the user is an admin
  Future<User> signInWithGoogle() async {
    try {
      final user = await authRepository.signInWithGoogle();

      final email = user.email.toLowerCase();

      // Validate admin email
      if (!adminEmails.map((e) => e.toLowerCase()).contains(email)) {
        await authRepository.signOut();
        throw Exception(
          'Access denied. You are not authorized to use the admin panel.'
        );
      }

      return user;
    } catch (e) {
      rethrow;
    }
  }

  /// Check if current user is admin
  Future<bool> isCurrentUserAdmin() async {
    final user = await authRepository.checkAuthStatus();
    if (user == null) return false;

    return adminEmails
        .map((e) => e.toLowerCase())
        .contains(user.email.toLowerCase());
  }

  /// Check current user and validate admin email
  Future<User?> checkAdminAuthStatus() async {
    final user = await authRepository.checkAuthStatus();
    if (user == null) return null;

    final email = user.email.toLowerCase();

    if (!adminEmails.map((e) => e.toLowerCase()).contains(email)) {
      await authRepository.signOut();
      return null;
    }

    return user;
  }

  /// Sign out admin
  Future<void> signOut() async {
    await authRepository.signOut();
  }
}
