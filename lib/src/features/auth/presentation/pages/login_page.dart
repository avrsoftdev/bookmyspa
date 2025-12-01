import 'package:flutter/material.dart';
import '../../domain/usecases/login.dart';
import '../../data/datasources/google_auth_data_source.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../controllers/auth_controller.dart';
import '../widgets/animated_logo.dart'; // Import the new widget
import 'package:bookmyspa/utils/constants/image.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  late final AuthController controller;

  @override
  void initState() {
    super.initState();
    final repo = AuthRepositoryImpl(google: GoogleAuthDataSource());
    controller = AuthController(loginUseCase: LoginUseCase(repo));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Login'), centerTitle: true),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Beautiful Animated Logo
              const AnimatedLogo(size: 130),
              const SizedBox(height: 32),

              const Text(
                'Welcome Back',
                style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'Sign in to continue',
                style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 48),

              // Google Sign-In Button
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: controller.loading
                      ? null
                      : () async {
                          final navigator = Navigator.of(context);
                          await controller.signInWithGoogle();
                          if (controller.currentUser != null) {
                            navigator.pushReplacementNamed('/home');
                          }
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    elevation: 3,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(color: Colors.grey.shade300),
                    ),
                  ),
                  child: controller.loading
                      ? const CircularProgressIndicator(strokeWidth: 2.5)
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Image.asset(Images.google, height: 24, width: 24),
                            const SizedBox(width: 16),
                            const Text(
                              'Sign in with Google',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                color: Color.fromARGB(255, 0, 0, 0),
                              ),
                            ),
                          ],
                        ),
                ),
              ),

              const SizedBox(height: 24),

              if (controller.error != null)
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.red.shade300),
                  ),
                  child: Text(
                    controller.error!,
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.red),
                  ),
                ),

              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}
