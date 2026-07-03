import 'package:due_day/core/design_system/theme/theme.dart';
import 'package:due_day/core/utils/extensions/num_extension.dart';
import 'package:flutter/material.dart';

class ProfileInfo extends StatelessWidget {
  final String userName;
  final String userEmail;
  const ProfileInfo({
    required this.userName,
    required this.userEmail,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final typography = context.typography;
    final spacing = context.spacing;

    return Column(
      children: [
        SizedBox(height: spacing.mediumLarge.height),
        Text(userName, style: typography.headline.small),
        SizedBox(height: spacing.small.height),
        Text(
          userEmail,
          style: typography.body.large.copyWith(
            color: colors.resource.secondary,
          ),
        ),
      ],
    );
  }
}
