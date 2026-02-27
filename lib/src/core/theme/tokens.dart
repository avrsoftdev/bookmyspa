import 'package:flutter/material.dart';

class AppColors {
  static const Color primary = Color(0xFF6A5AE0);
  static const Color secondary = Color(0xFF00BFA6);
  static const Color background = Color(0xFFF7F7F9);
  static const Color surface = Colors.white;
  static const Color textPrimary = Color(0xFF1B1B1F);
  static const Color textSecondary = Color(0xFF5F5F64);
  static const Color error = Color(0xFFB00020);

  // Dark mode colors
  static const Color darkBackground = Color(0xFF1A1A1A);
  static const Color darkSurface = Color(0xFF2A2A2A);
  static const Color darkTextPrimary = Color(0xFFFFFFFF);
  static const Color darkTextSecondary = Color(0xFFB0B0B0);
  static const Color darkCardBackground = Colors.black;
  static const Color darkCardOutline = Color(0xFF404040);
}

class AppSpacing {
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 16;
  static const double lg = 24;
  static const double xl = 32;
}

class AppRadius {
  static const BorderRadius sm = BorderRadius.all(Radius.circular(8));
  static const BorderRadius md = BorderRadius.all(Radius.circular(12));
  static const BorderRadius lg = BorderRadius.all(Radius.circular(16));
}
