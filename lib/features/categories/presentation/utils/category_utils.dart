import 'package:flutter/material.dart';

/// Predefined icons available for category selection.
class CategoryIconUtils {
  CategoryIconUtils._();

  static const List<IconData> availableIcons = [
    Icons.home_rounded,
    Icons.camera_alt_rounded,
    Icons.fitness_center_rounded,
    Icons.flight_rounded,
    Icons.shopping_bag_rounded,
    Icons.card_giftcard_rounded,
    Icons.directions_car_rounded,
    Icons.terrain_rounded,
    Icons.beach_access_rounded,
    Icons.restaurant_rounded,
    Icons.local_hospital_rounded,
    Icons.school_rounded,
  ];

  /// Encodes an [IconData] to a hex-string of its codePoint.
  static String encode(IconData icon) =>
      '0x${icon.codePoint.toRadixString(16)}';

  /// Decodes a hex-string back to an [IconData].
  static IconData parseIcon(String iconStr) {
    try {
      final codePoint = int.parse(iconStr);
      return availableIcons.firstWhere(
        (icon) => icon.codePoint == codePoint,
        orElse: () => Icons.category_rounded,
      );
    } catch (_) {
      return Icons.category_rounded;
    }
  }
}

/// Predefined colors available for category selection.
class CategoryColorUtils {
  CategoryColorUtils._();

  static const List<Color> availableColors = [
    Color(0xFF4361EE), // Primary blue
    Color(0xFFE63946), // Red
    Color(0xFF2A9D8F), // Teal / green
    Color(0xFFA0522D), // Sienna / brown
    Color(0xFF7B2D8E), // Purple
    Color(0xFF6C757D), // Gray
  ];

  /// Encodes a [Color] to a hex-string (e.g. "#4361EE").
  static String encode(Color color) =>
      '#${color.toARGB32().toRadixString(16).substring(2).toUpperCase()}';

  /// Parses a hex-string back to a [Color], with a [fallback].
  static Color parseColor(String hex, Color fallback) {
    try {
      return Color(int.parse(hex.replaceAll('#', '0xFF')));
    } catch (_) {
      return fallback;
    }
  }
}
