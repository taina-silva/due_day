import 'package:due_day/core/design_system/theme/theme.dart';
import 'package:flutter/material.dart';

/// Extension on [BuildContext] to provide direct, clean access to the DueDay Design System.
/// This avoids declaring local styling variables in build methods and simplifies color theme matching.
extension DueDayThemeExtension on BuildContext {
  /// Direct access to AppColorsSys tokens.
  AppColorsSys get colors => DueDayTheme.colors;

  /// Direct access to AppTypography styles.
  AppTypography get typography => DueDayTheme.typography;

  /// Direct access to AppDimensions tokens.
  AppDimensions get dimensions => DueDayTheme.dimensions;

  /// Shortcut to spacing styles.
  SpacingStyles get spacing => DueDayTheme.dimensions.spacing;

  /// Shortcut to radius styles.
  RadiusStyles get radius => DueDayTheme.dimensions.radius;

  /// Shortcut to sizing styles.
  SizesStyles get sizes => DueDayTheme.dimensions.size;

  /// Shortcut to stroke/border styles.
  StrokeStyles get stroke => DueDayTheme.dimensions.stroke;

  /// Returns true if the device is currently in Dark Mode.
  bool get isDarkMode => Theme.of(this).brightness == Brightness.dark;

  /// Retrieves the scaffold background color corresponding to the active theme.
  Color get scaffoldBackgroundColor => Theme.of(this).scaffoldBackgroundColor;

  /// Retrieves the active surface/container color from the current Material Theme.
  Color get surfaceColor => Theme.of(this).colorScheme.surface;

  /// Retrieves the active text/foreground color on top of surface.
  Color get onSurfaceColor => Theme.of(this).colorScheme.onSurface;

  /// Retrieves the secondary/variant text color on top of surface.
  Color get onSurfaceVariantColor => Theme.of(this).colorScheme.onSurfaceVariant;

  /// Retrieves the main brand primary color.
  Color get primaryColor => Theme.of(this).colorScheme.primary;

  /// Retrieves the active error color.
  Color get errorColor => Theme.of(this).colorScheme.error;
}
