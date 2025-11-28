import 'package:flutter/foundation.dart';
import '../../domain/entities/user.dart';
import '../../domain/usecases/login.dart';

class AuthController extends ChangeNotifier {
  final LoginUseCase loginUseCase;

  AuthController({required this.loginUseCase});

  User? currentUser;
  bool loading = false;
  String? error;

  Future<void> login(String email, String password) async {
    loading = true;
    error = null;
    notifyListeners();
    try {
      final user = await loginUseCase(email: email, password: password);
      currentUser = user;
    } catch (e) {
      error = e.toString();
    } finally {
      loading = false;
      notifyListeners();
    }
  }
}
