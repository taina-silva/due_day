import 'package:due_day/core/design_system/theme/app_colors/resource_colors.dart';
import 'package:due_day/core/design_system/theme/app_colors/system_colors.dart';
import 'package:flutter/material.dart';

class AppColorsSys {
  final ResourceColors resource;
  final SystemColors system;

  const AppColorsSys()
    : resource = const ResourceColors(),
      system = const SystemColors();

  // Backgrounds
  Color get lightBackground => const Color(0xFFFAFAFA);
  Color get darkBackground => const Color(0xFF0F1014);

  Color get lightSurface => const Color(0xFFFFFFFF);
  Color get darkSurface => const Color(0xFF1A1C22);

  // Text
  Color get onLightBackground => const Color(0xFF131313);
  Color get onDarkBackground => const Color(0xFFFAFAFA);
}
