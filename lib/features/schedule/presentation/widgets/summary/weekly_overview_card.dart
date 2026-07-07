import 'package:due_day/core/design_system/theme/theme.dart';
import 'package:due_day/core/l10n/l10n_extension.dart';
import 'package:due_day/core/utils/extensions/num_extension.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class WeeklyOverviewCard extends StatelessWidget {
  final double totalAmount;
  final double totalPaid;
  final double totalToPay;

  const WeeklyOverviewCard({
    required this.totalAmount,
    required this.totalPaid,
    required this.totalToPay,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final typography = context.typography;
    final spacing = context.spacing;
    final radius = context.radius;
    final l10n = context.l10n;

    final currencyFormat = NumberFormat.simpleCurrency(
      locale: context.localeString,
    );

    return Container(
      padding: EdgeInsets.all(spacing.extraLarge.width),
      decoration: BoxDecoration(
        color: colors.lightSurface,
        borderRadius: BorderRadius.circular(radius.extraLarge),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 40,
            offset: const Offset(0, 20),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.scheduleSummaryWeeklyOverview.toUpperCase(),
            style: typography.label.small.copyWith(
              letterSpacing: 2,
              fontWeight: FontWeight.w600,
              color: colors.resource.secondary,
            ),
          ),
          SizedBox(height: spacing.small.height),
          Text(
            currencyFormat.format(totalAmount),
            style: typography.headline.large.copyWith(
              fontWeight: FontWeight.bold,
              fontSize: 36.width,
            ),
          ),
          SizedBox(height: spacing.extraLarge.height),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.scheduleSummaryTotalPaid.toUpperCase(),
                      style: typography.label.small.copyWith(
                        color: colors.resource.secondary.withValues(alpha: 0.5),
                        fontWeight: FontWeight.bold,
                        fontSize: 10.width,
                        letterSpacing: 1,
                      ),
                    ),
                    Text(
                      currencyFormat.format(totalPaid),
                      style: typography.title.medium.copyWith(
                        fontWeight: FontWeight.bold,
                        color: colors.system.success,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                width: 1,
                height: 40.height,
                color: colors.resource.secondary.withValues(alpha: 0.1),
              ),
              SizedBox(width: spacing.large.width),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.scheduleSummaryToPay.toUpperCase(),
                      style: typography.label.small.copyWith(
                        color: colors.resource.secondary.withValues(alpha: 0.5),
                        fontWeight: FontWeight.bold,
                        fontSize: 10.width,
                        letterSpacing: 1,
                      ),
                    ),
                    Text(
                      currencyFormat.format(totalToPay),
                      style: typography.title.medium.copyWith(
                        fontWeight: FontWeight.bold,
                        color: colors.system.error,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
