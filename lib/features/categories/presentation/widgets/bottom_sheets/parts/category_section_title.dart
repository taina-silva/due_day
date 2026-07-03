import 'package:due_day/core/design_system/theme/theme.dart';
import 'package:flutter/material.dart';

class CategorySectionTitle extends StatelessWidget {
  final String title;

  const CategorySectionTitle({required this.title, super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final typography = context.typography;

    return Text(
      title,
      style: typography.label.large.copyWith(
        color: colors.resource.neutral,
        fontWeight: FontWeight.w600,
      ),
    );
  }
}
