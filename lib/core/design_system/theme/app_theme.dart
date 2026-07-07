import 'package:due_day/core/design_system/theme/theme.dart';
import 'package:due_day/core/utils/extensions/num_extension.dart';
import 'package:flutter/material.dart';

class AppTheme {
  const AppTheme._();

  static ThemeData get lightTheme {
    const colors = DueDayTheme.colors;
    const dimensions = DueDayTheme.dimensions;

    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: colors.lightBackground,
      colorScheme: ColorScheme.fromSeed(
        seedColor: colors.resource.primary,
        primary: colors.resource.primary,
        onPrimary: colors.onDarkBackground,
        surface: colors.lightSurface,
        onSurface: colors.onLightBackground,
        onSurfaceVariant: colors.resource.secondary,
        error: colors.system.error,
      ),
      cardTheme: CardThemeData(
        color: colors.lightSurface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(dimensions.radius.extraLarge),
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: colors.onLightBackground),
        titleTextStyle: DueDayTheme.typography.headline.small.copyWith(
          color: colors.onLightBackground,
          inherit: false,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: colors.lightSurface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(dimensions.radius.medium),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(dimensions.radius.medium),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(dimensions.radius.medium),
          borderSide: BorderSide(
            color: colors.resource.primary,
            width: dimensions.stroke.large,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(dimensions.radius.medium),
          borderSide: BorderSide(
            color: colors.system.error,
            width: dimensions.stroke.large,
          ),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: colors.resource.primary,
          foregroundColor: colors.onDarkBackground,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(dimensions.radius.circle),
          ),
          padding: EdgeInsets.symmetric(
            horizontal: dimensions.spacing.largeExtraLarge.width,
            vertical: dimensions.size.mediumLarge.height,
          ),
        ),
      ),
      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(foregroundColor: colors.resource.primary),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: colors.lightBackground,
        surfaceTintColor: colors.lightBackground,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(dimensions.radius.extraLarge),
          ),
        ),
      ),
      listTileTheme: ListTileThemeData(
        iconColor: colors.onLightBackground.withValues(alpha: 0.6),
        titleTextStyle: DueDayTheme.typography.body.large.copyWith(
          color: colors.onLightBackground,
          inherit: false,
        ),
        subtitleTextStyle: DueDayTheme.typography.label.medium.copyWith(
          color: colors.resource.secondary,
          inherit: false,
        ),
      ),
    );
  }

  static ThemeData get darkTheme {
    const colors = DueDayTheme.colors;
    const dimensions = DueDayTheme.dimensions;

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: colors.darkBackground,
      colorScheme: ColorScheme.fromSeed(
        seedColor: colors.resource.primary,
        primary: colors.resource.primary,
        onPrimary: colors.onDarkBackground,
        surface: colors.darkSurface,
        onSurface: colors.onDarkBackground,
        onSurfaceVariant: colors.resource.secondary,
        error: colors.system.error,
        brightness: Brightness.dark,
      ),
      cardTheme: CardThemeData(
        color: colors.darkSurface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(dimensions.radius.extraLarge),
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: colors.onDarkBackground),
        titleTextStyle: DueDayTheme.typography.headline.small.copyWith(
          color: colors.onDarkBackground,
          inherit: false,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: colors.darkSurface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(dimensions.radius.medium),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(dimensions.radius.medium),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(dimensions.radius.medium),
          borderSide: BorderSide(
            color: colors.resource.primary,
            width: dimensions.stroke.large,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(dimensions.radius.medium),
          borderSide: BorderSide(
            color: colors.system.error,
            width: dimensions.stroke.large,
          ),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: colors.resource.primary,
          foregroundColor: colors.onDarkBackground,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(dimensions.radius.circle),
          ),
          padding: EdgeInsets.symmetric(
            horizontal: dimensions.spacing.largeExtraLarge.width,
            vertical: dimensions.size.mediumLarge.height,
          ),
        ),
      ),
      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(foregroundColor: colors.resource.primary),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: colors.darkBackground,
        surfaceTintColor: colors.darkBackground,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(dimensions.radius.extraLarge),
          ),
        ),
      ),
      listTileTheme: ListTileThemeData(
        iconColor: colors.onDarkBackground.withValues(alpha: 0.6),
        titleTextStyle: DueDayTheme.typography.body.large.copyWith(
          color: colors.onDarkBackground,
          inherit: false,
        ),
        subtitleTextStyle: DueDayTheme.typography.label.medium.copyWith(
          color: colors.resource.secondary,
          inherit: false,
        ),
      ),
    );
  }
}
