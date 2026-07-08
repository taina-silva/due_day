import 'package:due_day/core/design_system/theme/theme.dart';
import 'package:due_day/core/utils/extensions/num_extension.dart';
import 'package:flutter/material.dart';

class SummaryCard extends StatelessWidget {
  final String title;
  final String amount;
  final IconData icon;
  final Color color;

  const SummaryCard({
    required this.title,
    required this.amount,
    required this.icon,
    required this.color,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final typography = context.typography;
    final spacing = context.spacing;
    final radius = context.radius;
    final size = context.sizes;

    return Container(
      padding: EdgeInsets.all(spacing.mediumLarge.width),
      decoration: BoxDecoration(
        color: context.surfaceColor,
        borderRadius: BorderRadius.circular(radius.extraLarge),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.all(spacing.smallMedium.width),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: size.large.scale),
          ),
          SizedBox(height: spacing.mediumLarge.height),
          Text(
            title,
            style: typography.label.medium.copyWith(
              color: context.onSurfaceVariantColor,
            ),
          ),
          SizedBox(height: spacing.small.height),
          Text(
            amount,
            style: typography.body.medium.copyWith(fontWeight: FontWeight.bold),
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
