import 'package:due_day/core/design_system/theme/theme.dart';
import 'package:due_day/core/utils/extensions/num_extension.dart';
import 'package:flutter/material.dart';

class DueItemCard extends StatelessWidget {
  final String title;
  final String date;
  final String amount;
  final IconData icon;
  final bool isWarning;

  const DueItemCard({
    required this.title,
    required this.date,
    required this.amount,
    required this.icon,
    this.isWarning = false,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final typography = context.typography;
    final colors = context.colors;
    final spacing = context.spacing;
    final radius = context.radius;
    final size = context.sizes;

    return Container(
      padding: EdgeInsets.all(spacing.mediumLarge.width),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(radius.extraLarge),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(spacing.medium.width),
            decoration: BoxDecoration(
              color: colorScheme.onSurface.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: colorScheme.onSurface,
              size: size.largeExtraLarge,
            ),
          ),
          SizedBox(width: spacing.mediumLarge.width),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: typography.body.large.copyWith(
                    fontWeight: FontWeight.w600,
                    color: colorScheme.onSurface,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: spacing.small.height),
                Text(
                  date,
                  style: typography.label.medium.copyWith(
                    color: isWarning
                        ? colors.system.warning
                        : colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          Text(
            amount,
            style: typography.body.large.copyWith(
              fontWeight: FontWeight.bold,
              color: colorScheme.onSurface,
            ),
          ),
        ],
      ),
    );
  }
}
