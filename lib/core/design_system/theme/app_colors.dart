import 'package:flutter/material.dart';

class AppColors {
  // Brand colors
  static const Color primary = Color(0xFF005BBF);
  static const Color primaryContainer = Color(0xFF1A73E8);

  // Semantic colors
  static const Color success = Color(0xFF00A86B);
  static const Color error = Color(0xFFBA1A1A);
  static const Color warning = Color(0xFF9E4300);

  // Surface layers for elevation mapping (Light Mode defaults from Stitch)
  static const Color background = Color(0xFFF8F9FA); // Level 0
  static const Color surfaceContainerLow = Color(0xFFF3F4F5); // Level 1
  static const Color surfaceContainerLowest = Color(0xFFFFFFFF); // Level 2
  static const Color surfaceContainerHigh = Color(0xFFE7E8E9);

  // Dark mode surface map
  static const Color darkBackground = Color(0xFF1A1A1A);
  static const Color darkSurfaceContainerHigh = Color(0xFF2E3132);
  static const Color darkInverseOnSurface = Color(0xFFF0F1F2);

  // Text colors
  static const Color textPrimary = Color(0xFF191C1D);
  static const Color textSecondary = Color(0xFF414754);

  // Ghost borders & Accents
  static const Color outlineVariant = Color(0xFFC1C6D6);
}
