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
    final size = context.sizes;
    final insight = summary.insight;

    final String insightText;
    final Color iconColor;
    final IconData icon;

    switch (insight.type) {
      case DashboardInsightType.healthy:
        insightText = l10n.dashboardInsightHealthy;
        iconColor = colors.system.success;
        icon = Icons.check_circle_outline_rounded;
      case DashboardInsightType.budgetWarning:
        insightText = l10n.dashboardInsightBudget(insight.budgetPercentage);
        iconColor = colors.system.warning;
        icon = Icons.error_outline_rounded;
      case DashboardInsightType.categoryWarning:
        final category = categories.firstWhereOrNull(
          (c) => c.id == insight.categoryId,
        );
        final categoryName = category?.name ?? insight.categoryId ?? '';
        insightText = l10n.dashboardInsightWarning(categoryName);
        iconColor = colors.system.error;
        icon = Icons.warning_amber_rounded;
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
          Icon(icon, color: iconColor, size: size.extraLarge.scale),
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
