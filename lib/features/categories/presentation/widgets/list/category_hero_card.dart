import 'package:due_day/core/design_system/theme/theme.dart';
import 'package:due_day/core/utils/extensions/num_extension.dart';
import 'package:due_day/features/categories/domain/entities/category_entity.dart';
import 'package:due_day/features/categories/presentation/utils/category_utils.dart';
import 'package:flutter/material.dart';

/// Highlighted hero card for the "Most Active" category.
class CategoryHeroCard extends StatelessWidget {
  final CategoryEntity category;
  final int transactionCount;
  final String mostActiveLabel;
  final String transactionLabel;

  const CategoryHeroCard({
    required this.category,
    required this.transactionCount,
    required this.mostActiveLabel,
    required this.transactionLabel,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final typography = context.typography;
    final dimensions = context.dimensions;

    final parsedColor = CategoryColorUtils.parseColor(
      category.color,
      colors.resource.primary,
    );
    final iconData = CategoryIconUtils.parseIcon(category.icon);

    return Container(
      padding: EdgeInsets.all(dimensions.spacing.largeExtraLarge.width),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            parsedColor.withValues(alpha: 0.15),
            parsedColor.withValues(alpha: 0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(dimensions.radius.extraLarge),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  mostActiveLabel,
                  style: typography.label.small.copyWith(
                    color: parsedColor,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.2,
                  ),
                ),
                SizedBox(height: dimensions.spacing.smallMedium.height),
                Text(
                  category.name,
                  style: typography.title.large.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: dimensions.spacing.small.height),
                Text(
                  transactionLabel,
                  style: typography.label.medium.copyWith(
                    color: context.onSurfaceVariantColor,
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: 56.scale,
            height: 56.scale,
            decoration: BoxDecoration(
              color: parsedColor.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(dimensions.radius.large),
            ),
            child: Icon(iconData, color: parsedColor, size: 28.scale),
          ),
        ],
      ),
    );
  }
}
