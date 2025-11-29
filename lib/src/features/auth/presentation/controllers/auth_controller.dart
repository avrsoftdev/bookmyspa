import 'package:flutter/foundation.dart';
import '../../domain/entities/user.dart';
import '../../domain/usecases/login.dart';

class AuthController extends ChangeNotifier {
  final LoginUseCase loginUseCase;

  AuthController({required this.loginUseCase});

  User? currentUser;
  bool _loading = false;
  String? _error;

  // Public getters
  bool get loading => _loading;
  String? get error => _error;
  bool get isLoggedIn => currentUser != null;

  // Email/Password Login (you can keep this if you add it later)
  Future<void> login(String email, String password) async {
    await _setLoading(true);
    try {
      final user = await loginUseCase(email: email, password: password);
      currentUser = user;
      _setError(null);
    } catch (e) {
      _setError(e.toString().replaceFirst('Exception: ', ''));
    } finally {
      await _setLoading(false);
    }
  }

  // Google Sign-In — This is the one you're using right now
  Future<void> signInWithGoogle() async {
    await _setLoading(true);
    try {
      // This calls your LoginUseCase().signInWithGoogle()
      final user = await loginUseCase.signInWithGoogle();
      currentUser = user;
      _setError(null);
    } catch (e) {
      String message = e.toString();
      if (message.contains('Exception:')) {
        message = message.split('Exception:').last.trim();
      }
      // Common user-friendly messages
      if (message.contains('sign_in_canceled') || message.contains('user canceled')) {
        _setError('Sign in was cancelled.');
      } else if (message.contains('network_error')) {
        _setError('Network error. Please check your internet connection.');
      } else {
        _setError('Google Sign-In failed. Please try again.');
      }
    } finally {
      await _setLoading(false);
    }
  }

  // Logout (optional but recommended)
  Future<void> signOut() async {
    await loginUseCase.signOut();
    currentUser = null;
    _setError(null);
    notifyListeners();
  }

  // Private helpers to avoid code duplication
  Future<void> _setLoading(bool value) async {
    _loading = value;
    notifyListeners();
  }

  void _setError(String? message) {
    _error = message;
    notifyListeners();
  }

  // Clear error manually (e.g., when user taps retry)
  void clearError() {
    _error = null;
    notifyListeners();
  }
}