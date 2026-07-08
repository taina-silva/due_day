import 'package:collection/collection.dart';
import 'package:due_day/core/design_system/theme/theme.dart';
import 'package:due_day/core/l10n/app_localizations.dart';
import 'package:due_day/core/utils/extensions/num_extension.dart';
import 'package:due_day/features/categories/domain/entities/category_entity.dart';
import 'package:due_day/features/dashboard/domain/entities/dashboard_summary.dart';
import 'package:flutter/material.dart';

class InsightCard extends StatelessWidget {
  final DashboardSummary summary;
  final AppLocalizations l10n;
  final List<CategoryEntity> categories;

  const InsightCard({
    required this.summary,
    required this.l10n,
    required this.categories,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final typography = context.typography;
    final spacing = context.spacing;
    final radius = context.radius;

    String insightText = l10n.dashboardInsightHealthy;
    Color iconColor = colors.system.success;
    IconData icon = Icons.check_circle_outline_rounded;

    if (summary.monthlyExpenses > summary.monthlyIncome &&
        summary.monthlyIncome > 0) {
      insightText = l10n.dashboardInsightBudget(
        ((summary.monthlyExpenses / summary.monthlyIncome) * 100).toInt(),
      );
      iconColor = colors.system.warning;
      icon = Icons.error_outline_rounded;
    }

    // Find the highest spending category
    if (summary.spendingByCategory.isNotEmpty) {
      final highestCategoryEntry = summary.spendingByCategory.entries.reduce(
        (a, b) => a.value > b.value ? a : b,
      );

      final category = categories.firstWhereOrNull(
        (c) => c.id == highestCategoryEntry.key,
      );
      final categoryName = category?.name ?? highestCategoryEntry.key;

      if (highestCategoryEntry.value > (summary.monthlyIncome * 0.3) &&
          summary.monthlyIncome > 0) {
        insightText = l10n.dashboardInsightWarning(categoryName);
        iconColor = colors.system.error;
        icon = Icons.warning_amber_rounded;
      }
    }

    return Container(
      padding: EdgeInsets.all(spacing.mediumLarge.width),
      decoration: BoxDecoration(
        color: iconColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(radius.extraLarge),
        border: Border.all(color: iconColor.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          Icon(icon, color: iconColor, size: 28.scale),
          SizedBox(width: spacing.mediumLarge.width),
          Expanded(
            child: Text(
              insightText,
              style: typography.body.medium.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
