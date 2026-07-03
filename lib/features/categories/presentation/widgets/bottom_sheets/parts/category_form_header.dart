import 'package:due_day/core/design_system/theme/theme.dart';
import 'package:due_day/core/utils/extensions/num_extension.dart';
import 'package:flutter/material.dart';

class CategoryFormHeader extends StatelessWidget {
  final String title;
  final VoidCallback onClose;

  const CategoryFormHeader({
    required this.title,
    required this.onClose,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final typography = context.typography;
    final dimensions = context.dimensions;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Drag Handle
        Center(
          child: Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: colors.resource.neutral.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(dimensions.radius.circle),
            ),
          ),
        ),
        SizedBox(height: dimensions.spacing.large.height),
        // Header Row
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: typography.title.large.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            GestureDetector(
              onTap: onClose,
              child: Icon(Icons.close_rounded, color: colors.resource.neutral),
            ),
          ],
        ),
      ],
    );
  }
}
