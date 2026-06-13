import 'package:collection/collection.dart';
import 'package:due_day/core/design_system/theme/theme.dart';
import 'package:due_day/core/utils/extensions/num_extension.dart';
import 'package:due_day/features/categories/domain/entities/category_entity.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class CategorySpendingList extends StatelessWidget {
  final Map<String, double> spending;
  final double total;
  final String localeStr;
  final List<CategoryEntity> categories;

  const CategorySpendingList({
    required this.spending,
    required this.total,
    required this.localeStr,
    required this.categories,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    const colors = DueDayTheme.colors;
    const typography = DueDayTheme.typography;
    final spacing = DueDayTheme.dimensions.spacing;
    final radius = DueDayTheme.dimensions.radius;

    final sortedEntries = spending.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return Column(
      children: sortedEntries.take(4).map((entry) {
        final percent = total > 0 ? entry.value / total : 0.0;
        final category = categories.firstWhereOrNull((c) => c.id == entry.key);
        final categoryName = category?.name ?? entry.key;

        return Padding(
          padding: EdgeInsets.only(bottom: spacing.mediumLarge.height),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    categoryName,
                    style: typography.body.medium.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    NumberFormat.simpleCurrency(
                      locale: localeStr,
                    ).format(entry.value),
                    style: typography.body.medium,
                  ),
                ],
              ),
              SizedBox(height: spacing.small.height),
              ClipRRect(
                borderRadius: BorderRadius.circular(radius.small),
                child: LinearProgressIndicator(
                  value: percent,
                  backgroundColor: colors.resource.neutral.withValues(
                    alpha: 0.2,
                  ),
                  valueColor: AlwaysStoppedAnimation<Color>(
                    colors.resource.primary,
                  ),
                  minHeight: 6,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}
