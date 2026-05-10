import 'package:flutter/material.dart';

class AppColors {
  // Premium Luxury Ayurvedic Palette
  static const Color primary = Color(0xFF1E392A); // Deep rich Emerald/Forest Green
  static const Color darkGreen = Color(0xFF0F1E16); // Almost black green
  static const Color lightGreen = Color(0xFF3B6B4F); // Soft sage green
  
  static const Color secondary = Color(0xFFD4AF37); // Champagne Gold
  static const Color lightYellow = Color(0xFFF9EBC8); // Very soft gold/cream
  
  static const Color accent = Color(0xFFE07A5F); // Warm terracotta
  
  static const Color background = Color(0xFFF4F6F5); // Ultra clean off-white
  static const Color cardWhite = Color(0xFFFFFFFF); // Pure white for premium cards
  
  static const Color textPrimary = Color(0xFF1A1A1A); // Deep charcoal
  static const Color textSecondary = Color(0xFF6C757D); // Sleek grey
  
  static const Color divider = Color(0xFFEAEAEA); // Subtle divider
  static const Color error = Color(0xFFB00020);
  static const Color success = Color(0xFF2E7D32);

  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF1E392A), Color(0xFF2A5239)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient warmGradient = LinearGradient(
    colors: [Color(0xFFD4AF37), Color(0xFFF3E5AB)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
