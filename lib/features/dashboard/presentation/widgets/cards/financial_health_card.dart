import 'package:due_day/core/design_system/theme/theme.dart';
import 'package:due_day/core/l10n/app_localizations.dart';
import 'package:due_day/core/l10n/l10n_extension.dart';
import 'package:due_day/core/utils/extensions/num_extension.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class FinancialHealthCard extends StatelessWidget {
  final double currentBalance;
  final double projectedBalance;
  final List<String> selectedAccountNames;
  final VoidCallback? onFilterTap;

  const FinancialHealthCard({
    required this.currentBalance,
    required this.projectedBalance,
    required this.selectedAccountNames,
    this.onFilterTap,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final typography = context.typography;
    final spacing = context.spacing;
    final radius = context.radius;

    final l10n = AppLocalizations.of(context);
    final localeStr = context.localeString;

    final formattedBalance = NumberFormat.simpleCurrency(
      locale: localeStr,
    ).format(currentBalance);

    final formattedProjected = NumberFormat.simpleCurrency(
      locale: localeStr,
    ).format(projectedBalance);

    return InkWell(
      onTap: onFilterTap,
      borderRadius: BorderRadius.circular(radius.extraLarge),
      child: Container(
        padding: EdgeInsets.all(spacing.largeExtraLarge.width),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              colors.resource.primary,
              colors.resource.primaryWith30Opacity,
            ],
          ),
          borderRadius: BorderRadius.circular(radius.extraLarge),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  l10n.dashboardGeneralBalance,
                  style: typography.body.large.copyWith(
                    color: colors.onDarkBackground.withValues(alpha: 0.8),
                  ),
                ),
                Icon(
                  Icons.filter_list_rounded,
                  color: colors.onDarkBackground.withValues(alpha: 0.8),
                  size: 20.scale,
                ),
              ],
            ),
            SizedBox(height: spacing.smallMedium.height),
            Text(
              formattedBalance,
              style: typography.headline.large.copyWith(
                color: colors.onDarkBackground,
                fontSize: 40.fontSize,
              ),
            ),
            SizedBox(height: spacing.medium.height),
            Text(
              selectedAccountNames.isEmpty
                  ? l10n.transactionsFilterAll
                  : selectedAccountNames.join(', '),
              style: typography.body.small.copyWith(
                color: colors.onDarkBackground.withValues(alpha: 0.7),
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            SizedBox(height: spacing.large.height),
            Row(
              children: [
                Icon(
                  Icons.analytics_outlined,
                  color: colors.onDarkBackground.withValues(alpha: 0.6),
                  size: 20.scale,
                ),
                SizedBox(width: spacing.small.width),
                Text(
                  '${l10n.dashboardProjectedBalance}: $formattedProjected',
                  style: typography.body.medium.copyWith(
                    color: colors.onDarkBackground.withValues(alpha: 0.9),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
