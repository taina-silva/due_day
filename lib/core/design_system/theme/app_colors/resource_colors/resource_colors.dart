import 'package:flutter/material.dart';

class ResourceColors {
  const ResourceColors();

  Color get primary => const Color(0xFF166bd5);
  Color get primaryWith30Opacity => primary.withValues(alpha: 0.3);
  Color get primaryWith15Opacity => primary.withValues(alpha: 0.15);

  Color get secondary =>
      const Color(0xFF9E9E9E); // Placeholder for secondary if needed
  Color get neutral => const Color(0xFFE0E0E0);
}
