import 'package:due_day/core/design_system/theme/theme.dart';
import 'package:due_day/core/utils/extensions/num_extension.dart';
import 'package:flutter/material.dart';

class SettingsSection extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final List<Widget> children;
  final EdgeInsetsGeometry? padding;

  const SettingsSection({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.children,
    super.key,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    final typography = context.typography;
    final spacing = context.spacing;
    final radius = context.radius;

    return Container(
      padding: padding ?? EdgeInsets.all(spacing.mediumLarge.width),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(radius.extraLarge),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(spacing.small.width),
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(radius.medium),
                ),
                child: Icon(icon, color: iconColor),
              ),
              SizedBox(width: spacing.smallMedium.width),
              Text(title, style: typography.title.small),
            ],
          ),
          SizedBox(height: spacing.mediumLarge.height),
          ...children,
        ],
      ),
    );
  }
}
