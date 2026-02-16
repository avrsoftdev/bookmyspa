import 'package:flutter/foundation.dart';
import '../../domain/usecases/admin_login_usecase.dart';
import '../../../../features/auth/domain/entities/user.dart';
import '../../../../core/di/di.dart';
import '../../../../core/services/fcm_service.dart';

class AdminAuthController extends ChangeNotifier {
  final AdminLoginUseCase adminLoginUseCase;

  AdminAuthController({required this.adminLoginUseCase});

  User? currentAdminUser;
  bool _loading = false;
  String? _error;

  // Public getters
  bool get loading => _loading;
  String? get error => _error;
  bool get isAdminLoggedIn => currentAdminUser != null;

  /// Sign in with Google (validates admin email)
  Future<void> signInWithGoogle() async {
    await _setLoading(true);
    try {
      final user = await adminLoginUseCase.signInWithGoogle();
      currentAdminUser = user;
      try {
        await sl.get<FcmService>().registerCurrentUserToken();
      } catch (_) {}
      _setError(null);
    } catch (e) {
      String message = e.toString();
      debugPrint('Admin Login Error: $message');
      if (message.contains('Exception:')) {
        message = message.split('Exception:').last.trim();
      }
      // Common user-friendly messages
      if (message.contains('sign_in_canceled') || message.contains('user canceled')) {
        _setError('Sign in was cancelled.');
      } else if (message.contains('network_error')) {
        _setError('Network error. Please check your internet connection.');
      } else if (message.contains('Access denied')) {
        _setError(message);
      } else {
        _setError('Google Sign-In failed: ${message.length > 100 ? message.substring(0, 100) : message}');
      }
    } finally {
      await _setLoading(false);
    }
  }

  /// Check if user is already logged in as admin
  Future<void> checkAdminAuthStatus() async {
    await _setLoading(true);
    try {
      currentAdminUser = await adminLoginUseCase.checkAdminAuthStatus();
      _setError(null);
    } catch (e) {
      _setError(null); // Don't show error on startup
      currentAdminUser = null;
    } finally {
      await _setLoading(false);
    }
  }

  /// Sign out admin
  Future<void> signOut() async {
    await _setLoading(true);
    try {
      await adminLoginUseCase.signOut();
      currentAdminUser = null;
      _setError(null);
    } catch (e) {
      _setError('Failed to sign out. Please try again.');
    } finally {
      await _setLoading(false);
    }
  }

  // Private helpers
  Future<void> _setLoading(bool value) async {
    _loading = value;
    notifyListeners();
  }

  void _setError(String? error) {
    _error = error;
    notifyListeners();
  }
}
