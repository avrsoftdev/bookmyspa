import 'package:Spaxify/utils/constants/image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../controllers/auth_controller.dart';
import '../widgets/animated_logo.dart';
import '../../../../core/di/di.dart';

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
    controller = sl.get<AuthController>();
    controller.addListener(_onAuthStateChanged);
  }

  @override
  void dispose() {
    controller.removeListener(_onAuthStateChanged);
    super.dispose();
  }

  void _onAuthStateChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Login'), centerTitle: true),
      body: Center(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 24.w),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Beautiful Animated Logo
              AnimatedLogo(size: 130.w),
              SizedBox(height: 32.h),

              Text(
                'Welcome Back',
                style: TextStyle(fontSize: 32.sp, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 8.h),
              Text(
                'Sign in to continue',
                style: TextStyle(fontSize: 16.sp, color: Colors.grey[600]),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 48.h),

              // Google Sign-In Button
              SizedBox(
                width: double.infinity,
                height: 56.h,
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
                      borderRadius: BorderRadius.circular(12.r),
                      side: BorderSide(color: Colors.grey.shade300),
                    ),
                  ),
                  child: controller.loading
                      ? const CircularProgressIndicator(strokeWidth: 2.5)
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Image.asset(Images.google, height: 24.h, width: 24.w),
                            SizedBox(width: 16.w),
                            Text(
                              'Sign in with Google',
                              style: TextStyle(
                                fontSize: 16.sp,
                                fontWeight: FontWeight.w500,
                                color: const Color.fromARGB(255, 0, 0, 0),
                              ),
                            ),
                          ],
                        ),
                ),
              ),

              SizedBox(height: 24.h),

              if (controller.error != null)
                Container(
                  padding: EdgeInsets.all(16.w),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    borderRadius: BorderRadius.circular(12.r),
                    border: Border.all(color: Colors.red.shade300),
                  ),
                  child: Text(
                    controller.error!,
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.red, fontSize: 14.sp),
                  ),
                ),

              SizedBox(height: 40.h),
            ],
          ),
        ),
      ),
    );
  }
}
