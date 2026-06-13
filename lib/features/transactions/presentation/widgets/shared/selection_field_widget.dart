import 'package:due_day/core/design_system/theme/theme.dart';
import 'package:due_day/core/utils/extensions/num_extension.dart';
import 'package:flutter/material.dart';

class TransactionSelectionField extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final VoidCallback onTap;

  const TransactionSelectionField({
    required this.label,
    required this.value,
    required this.icon,
    required this.onTap,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    const colors = DueDayTheme.colors;
    final spacing = DueDayTheme.dimensions.spacing;
    const typography = DueDayTheme.typography;
    final radius = DueDayTheme.dimensions.radius;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(spacing.medium.width),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(radius.medium),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: typography.label.small.copyWith(
                color: colors.resource.secondary,
              ),
            ),
            SizedBox(height: spacing.small.height),
            Row(
              children: [
                Icon(icon, color: colors.resource.primary),
                SizedBox(width: spacing.medium.width),
                Expanded(child: Text(value, style: typography.body.medium)),
                Icon(
                  Icons.keyboard_arrow_down_rounded,
                  color: colors.resource.secondary,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
