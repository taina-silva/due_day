import 'package:due_day/core/design_system/components/avatar/user_avatar.dart';
import 'package:due_day/core/design_system/theme/theme.dart';
import 'package:due_day/core/utils/extensions/num_extension.dart';
import 'package:flutter/material.dart';

class ProfileAvatar extends StatelessWidget {
  final String initials;
  final String? photoUrl;
  final VoidCallback? onTap;

  const ProfileAvatar({
    required this.initials,
    this.photoUrl,
    this.onTap,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final typography = context.typography;
    final spacing = context.spacing;
    final avatarSize = 120.scale;

    final avatarContent = UserAvatar(
      size: avatarSize,
      photoUrl: photoUrl,
      fallback: Text(
        initials,
        style: typography.headline.large.copyWith(
          color: colors.resource.primary,
          fontSize: 48.fontSize,
        ),
      ),
    );

    return GestureDetector(
      onTap: onTap,
      child: Stack(
        children: [
          Container(
            width: avatarSize,
            height: avatarSize,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: colors.resource.primaryWith15Opacity,
              border: Border.all(color: colors.resource.primary, width: 2),
            ),
            alignment: Alignment.center,
            child: avatarContent,
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
      ),
    );
  }
}
