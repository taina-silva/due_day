import 'package:due_day/core/design_system/theme/theme.dart';
import 'package:due_day/core/utils/extensions/num_extension.dart';
import 'package:flutter/material.dart';

class AppTextButtonPrimary extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final IconData? prefixIcon;
  final IconData? suffixIcon;
  final bool isLoading;
  final bool isEnabled;

  const AppTextButtonPrimary({
    required this.label,
    super.key,
    this.onPressed,
    this.prefixIcon,
    this.suffixIcon,
    this.isLoading = false,
    this.isEnabled = true,
  });

  @override
  Widget build(BuildContext context) {
    const colors = DueDayTheme.colors;
    const typography = DueDayTheme.typography;
    const dimensions = DueDayTheme.dimensions;

    return ElevatedButton(
      onPressed: (isEnabled && !isLoading) ? onPressed : null,
      style: ElevatedButton.styleFrom(
        backgroundColor: colors.resource.primary,
        disabledBackgroundColor: colors.resource.primaryWith30Opacity,
        foregroundColor: colors.onDarkBackground,
        disabledForegroundColor: colors.onLightBackground.withValues(
          alpha: 0.5,
        ),
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(dimensions.radius.circle),
        ),
        padding: EdgeInsets.symmetric(
          horizontal: dimensions.spacing.largeExtraLarge.width,
          vertical: dimensions.size.mediumLarge.height,
        ),
      ),
      child: isLoading
          ? SizedBox(
              width: dimensions.size.large,
              height: dimensions.size.large,
              child: CircularProgressIndicator(
                color: colors.onDarkBackground,
                strokeWidth: dimensions.stroke.large,
              ),
            )
          : Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (prefixIcon != null) ...[
                  Icon(prefixIcon, size: dimensions.size.largeExtraLarge),
                  SizedBox(width: dimensions.spacing.smallMedium),
                ],
                Text(
                  label,
                  style: typography.label.large.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (suffixIcon != null) ...[
                  SizedBox(width: dimensions.spacing.smallMedium),
                  Icon(suffixIcon, size: dimensions.size.largeExtraLarge),
                ],
              ],
            ),
    );
  }
}

class AppTextButtonSecondary extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final IconData? prefixIcon;
  final Color? foregroundColor;
  final Color? borderColor;

  const AppTextButtonSecondary({
    required this.label,
    super.key,
    this.onPressed,
    this.prefixIcon,
    this.foregroundColor,
    this.borderColor,
  });

  @override
  Widget build(BuildContext context) {
    const colors = DueDayTheme.colors;
    const typography = DueDayTheme.typography;
    const dimensions = DueDayTheme.dimensions;

    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final defaultForegroundColor = isDarkMode ? colors.onDarkBackground : colors.onLightBackground;
    final effectiveForegroundColor = foregroundColor ?? defaultForegroundColor;
    final effectiveBorderColor = borderColor ?? colors.resource.neutral;

    return OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        foregroundColor: effectiveForegroundColor,
        side: dimensions.stroke.asBorderSide(
          color: effectiveBorderColor,
          strokeWidth: dimensions.stroke.small,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(dimensions.radius.circle),
        ),
        padding: EdgeInsets.symmetric(
          horizontal: dimensions.spacing.largeExtraLarge.width,
          vertical: dimensions.size.mediumLarge.height,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (prefixIcon != null) ...[
            Icon(prefixIcon, size: dimensions.size.largeExtraLarge),
            SizedBox(width: dimensions.spacing.smallMedium),
          ],
          Text(
            label,
            style: typography.label.large.copyWith(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}

class AppTextButtonTertiary extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;

  const AppTextButtonTertiary({required this.label, super.key, this.onPressed});

  @override
  Widget build(BuildContext context) {
    const colors = DueDayTheme.colors;
    const typography = DueDayTheme.typography;

    return TextButton(
      onPressed: onPressed,
      style: TextButton.styleFrom(
        foregroundColor: colors.resource.primary,
        padding: DueDayTheme.dimensions.spacing.paddingMedium,
      ),
      child: Text(
        label,
        style: typography.label.large.copyWith(fontWeight: FontWeight.bold),
      ),
    );
  }
}
