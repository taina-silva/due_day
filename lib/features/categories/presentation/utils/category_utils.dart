import 'package:flutter/material.dart';

/// Predefined icons available for category selection.
class CategoryIconUtils {
  CategoryIconUtils._();

  static const List<IconData> availableIcons = [
    // Home & bills
    Icons.home_rounded,
    Icons.apartment_rounded,
    Icons.receipt_long_rounded,
    Icons.bolt_rounded,
    Icons.water_drop_rounded,
    Icons.wifi_rounded,
    Icons.phone_iphone_rounded,
    // Finance
    Icons.attach_money_rounded,
    Icons.account_balance_rounded,
    Icons.account_balance_wallet_rounded,
    Icons.savings_rounded,
    Icons.credit_card_rounded,
    Icons.trending_up_rounded,
    Icons.security_rounded,
    // Food & drink
    Icons.restaurant_rounded,
    Icons.local_cafe_rounded,
    Icons.local_bar_rounded,
    // Shopping
    Icons.shopping_bag_rounded,
    Icons.shopping_cart_rounded,
    Icons.checkroom_rounded,
    Icons.card_giftcard_rounded,
    // Transport
    Icons.directions_car_rounded,
    Icons.local_gas_station_rounded,
    Icons.directions_bus_rounded,
    Icons.local_shipping_rounded,
    Icons.flight_rounded,
    // Leisure & travel
    Icons.terrain_rounded,
    Icons.beach_access_rounded,
    Icons.movie_rounded,
    Icons.sports_esports_rounded,
    Icons.music_note_rounded,
    Icons.celebration_rounded,
    Icons.camera_alt_rounded,
    // Health & wellness
    Icons.local_hospital_rounded,
    Icons.local_pharmacy_rounded,
    Icons.fitness_center_rounded,
    Icons.spa_rounded,
    // Family & education
    Icons.school_rounded,
    Icons.menu_book_rounded,
    Icons.work_rounded,
    Icons.pets_rounded,
    Icons.child_friendly_rounded,
    // Other
    Icons.devices_rounded,
    Icons.build_rounded,
    Icons.volunteer_activism_rounded,
    Icons.category_rounded,
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

  // All colors keep at least a 3:1 contrast ratio against white, so the
  // selection checkmark stays legible (WCAG AA for non-text UI components).
  static const List<Color> availableColors = [
    Color(0xFF4361EE), // Blue
    Color(0xFF3A86FF), // Sky blue
    Color(0xFF3730A3), // Indigo
    Color(0xFF7B2D8E), // Purple
    Color(0xFFC2185B), // Pink
    Color(0xFFE63946), // Red
    Color(0xFFEF6C00), // Orange
    Color(0xFF9C6B00), // Gold
    Color(0xFF558B2F), // Olive
    Color(0xFF06A77D), // Emerald
    Color(0xFF2A9D8F), // Teal
    Color(0xFF00838F), // Cyan
    Color(0xFF5D4037), // Brown
    Color(0xFFA0522D), // Sienna
    Color(0xFF34495E), // Slate blue
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
