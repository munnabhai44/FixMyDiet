import 'package:flutter/material.dart';

class AppColors {
  static const Color primary = Color(0xFF6B8E6B);
  static const Color darkGreen = Color(0xFF4A6741);
  static const Color lightGreen = Color(0xFF8FBC8F);
  static const Color secondary = Color(0xFFE8B84B);
  static const Color lightYellow = Color(0xFFF5D88E);
  static const Color accent = Color(0xFFCB7B5B);
  static const Color background = Color(0xFFF9F5F0);
  static const Color cardWhite = Color(0xFFFFFDF8);
  static const Color textPrimary = Color(0xFF2D2D2D);
  static const Color textSecondary = Color(0xFF6B6B6B);
  static const Color divider = Color(0xFFE0D8CE);
  static const Color error = Color(0xFFD32F2F);
  static const Color success = Color(0xFF388E3C);

  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primary, darkGreen],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient warmGradient = LinearGradient(
    colors: [secondary, accent],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
