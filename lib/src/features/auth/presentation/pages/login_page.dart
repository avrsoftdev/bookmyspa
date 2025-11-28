import 'package:flutter/material.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/usecases/login.dart';
import '../../data/datasources/google_auth_data_source.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../controllers/auth_controller.dart';
import '../../../../core/shared/primary_button.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  late final AuthController controller;
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final AuthRepository repo = AuthRepositoryImpl(
      google: GoogleAuthDataSource(),
    );
    controller = AuthController(loginUseCase: LoginUseCase(repo));
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Login'),
        centerTitle: true,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Title
              const Text(
                'Welcome Back',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Sign in to continue',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 48),

              // Sign in with Google Button (Perfectly Centered)
              SizedBox(
                width: double.infinity, // Full width button
                child: PrimaryButton(
                  label: controller.loading
                      ? 'Signing in…'
                      : 'Continue with Google',
                  onPressed: controller.loading
                      ? null
                      : () async {
                          final navigator = Navigator.of(context);
                          await controller.login('', '');
                          if (controller.currentUser != null) {
                            navigator.pushReplacementNamed('/home');
                          }
                        },
                ),
              ),

              // Error Message
              if (controller.error != null) ...[
                const SizedBox(height: 20),
                Text(
                  controller.error!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.red,
                    fontSize: 14,
                  ),
                ),
              ],

              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}