import 'package:due_day/core/design_system/theme/theme.dart';
import 'package:due_day/core/utils/extensions/num_extension.dart';
import 'package:flutter/material.dart';

class ProfileAvatar extends StatelessWidget {
  final String initials;

  const ProfileAvatar({required this.initials, super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final typography = context.typography;
    final spacing = context.spacing;

    return Stack(
      children: [
        Container(
          width: 120.scale,
          height: 120.scale,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: colors.resource.primaryWith15Opacity,
            border: Border.all(color: colors.resource.primary, width: 2),
          ),
          alignment: Alignment.center,
          child: Text(
            initials,
            style: typography.headline.large.copyWith(
              color: colors.resource.primary,
              fontSize: 48.fontSize,
            ),
          ),
        ),
        Positioned(
          bottom: 0,
          right: 0,
          child: Container(
            padding: EdgeInsets.all(spacing.medium.scale),
            decoration: BoxDecoration(
              color: context.surfaceColor,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: context.onSurfaceColor.withValues(alpha: 0.1),
                  blurRadius: 4,
                ),
              ],
            ),
            child: Icon(
              Icons.edit,
              size: 16.fontSize,
              color: colors.resource.primary,
            ),
          ),
        ),
      ],
    );
  }
}
