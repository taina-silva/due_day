import 'package:due_day/core/design_system/theme/theme.dart';
import 'package:due_day/core/utils/extensions/num_extension.dart';
import 'package:flutter/material.dart';

class SettingsRadioOption<T> extends StatelessWidget {
  final String label;
  final T value;
  final T groupValue;
  final ValueChanged<T?> onChanged;

  const SettingsRadioOption({
    required this.label,
    required this.value,
    required this.groupValue,
    required this.onChanged,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final typography = context.typography;
    final radius = context.radius;
    final spacing = context.spacing;
    final isSelected = value == groupValue;

    return GestureDetector(
      onTap: () => onChanged(value),
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: spacing.smallMedium.width,
          vertical: spacing.small.height,
        ),
        decoration: BoxDecoration(
          color: isSelected
              ? colors.resource.primary.withValues(alpha: 0.1)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(radius.large),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: typography.body.medium.copyWith(
                fontWeight: FontWeight.w600,
                color: context.onSurfaceColor,
              ),
            ),
            if (isSelected)
              Icon(
                Icons.check_circle,
                color: colors.resource.primary,
                size: 20.scale,
              )
            else
              Container(
                width: 20.scale,
                height: 20.scale,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: colors.resource.neutral),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
