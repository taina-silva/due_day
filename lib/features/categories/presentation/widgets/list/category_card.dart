import 'package:due_day/core/design_system/theme/theme.dart';
import 'package:due_day/core/utils/extensions/num_extension.dart';
import 'package:due_day/features/categories/domain/entities/category_entity.dart';
import 'package:due_day/features/categories/presentation/utils/category_utils.dart';
import 'package:flutter/material.dart';

/// A list-style row card for displaying a single category.
class CategoryCard extends StatelessWidget {
  final CategoryEntity category;
  final int transactionCount;
  final String transactionLabel;
  final VoidCallback? onTap;

  const CategoryCard({
    required this.category,
    required this.transactionCount,
    required this.transactionLabel,
    super.key,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    const colors = DueDayTheme.colors;
    const typography = DueDayTheme.typography;
    const dimensions = DueDayTheme.dimensions;

    final parsedColor = CategoryColorUtils.parseColor(
      category.color,
      colors.resource.primary,
    );
    final iconData = CategoryIconUtils.parseIcon(category.icon);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: dimensions.spacing.mediumLarge.width,
          vertical: dimensions.spacing.medium.height,
        ),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(dimensions.radius.large),
        ),
        child: Row(
          children: [
            // Icon circle
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: parsedColor.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(iconData, color: parsedColor, size: 22.fontSize),
            ),
            SizedBox(width: dimensions.spacing.medium.width),
            Expanded(
              child: Text(
                category.name,
                style: typography.body.large.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            // Transaction count
            Text(
              transactionLabel,
              style: typography.label.medium.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
