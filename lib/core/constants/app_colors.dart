import 'package:flutter/material.dart';

class AppColors {
  // ── Premium Sage & Gold Palette ──
  static const Color primary = Color(0xFF2D4A3E);       // Deep sage green
  static const Color primaryLight = Color(0xFF3B6B54);   // Medium sage
  static const Color darkGreen = Color(0xFF1A2F25);      // Near-black green
  static const Color lightGreen = Color(0xFF4A7C5F);     // Soft sage

  static const Color secondary = Color(0xFFBFA162);      // Muted champagne gold
  static const Color secondaryLight = Color(0xFFF5ECD7); // Cream gold tint
  static const Color lightYellow = Color(0xFFFAF6ED);    // Warm ivory

  static const Color accent = Color(0xFFD18B6A);         // Warm terracotta

  static const Color background = Color(0xFFF7F8F7);    // Off-white with green tint
  static const Color surface = Color(0xFFFFFFFE);        // Near-white (not stark)
  static const Color cardWhite = Color(0xFFFFFFFE);

  static const Color textPrimary = Color(0xFF1C2B22);    // Deep forest charcoal
  static const Color textSecondary = Color(0xFF7A8A7E);  // Sage grey
  static const Color textTertiary = Color(0xFFA3B0A6);   // Light sage

  static const Color divider = Color(0xFFE8ECE9);        // Subtle green-grey
  static const Color error = Color(0xFFBF3B30);
  static const Color success = Color(0xFF3A7D44);

  // Soft shadows
  static const Color shadowLight = Color(0x0A2D4A3E);
  static const Color shadowMedium = Color(0x142D4A3E);

  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF2D4A3E), Color(0xFF3B6B54)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient warmGradient = LinearGradient(
    colors: [Color(0xFFBFA162), Color(0xFFF5ECD7)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient surfaceGradient = LinearGradient(
    colors: [Color(0xFFF7F8F7), Color(0xFFEFF2F0)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );
}
