import 'package:due_day/core/design_system/theme/theme.dart';
import 'package:due_day/core/l10n/l10n_extension.dart';
import 'package:due_day/core/utils/extensions/num_extension.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class NextIncomeCard extends StatelessWidget {
  final double amount;
  final DateTime? arrivalDate;

  const NextIncomeCard({required this.amount, super.key, this.arrivalDate});

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

    final dateFormat = DateFormat.MMMMd(context.localeString);

    final onPrimary = Theme.of(context).colorScheme.onPrimary;

    return Container(
      padding: EdgeInsets.all(spacing.extraLarge.width),
      decoration: BoxDecoration(
        color: colors.resource.primary,
        borderRadius: BorderRadius.circular(radius.extraLarge),
        boxShadow: [
          BoxShadow(
            color: colors.resource.primary.withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Decorative circle
          Positioned(
            right: -spacing.extraLarge.width * 2,
            top: -spacing.extraLarge.width * 2,
            child: Container(
              width: 150.width,
              height: 150.width,
              decoration: BoxDecoration(
                color: onPrimary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.payments_outlined,
                    color: onPrimary.withValues(alpha: 0.8),
                    size: 20.width,
                  ),
                  SizedBox(width: spacing.small.width),
                  Text(
                    l10n.scheduleSummaryNextIncome.toUpperCase(),
                    style: typography.label.small.copyWith(
                      letterSpacing: 2,
                      fontWeight: FontWeight.w600,
                      color: onPrimary.withValues(alpha: 0.8),
                    ),
                  ),
                ],
              ),
              SizedBox(height: spacing.medium.height),
              Text(
                currencyFormat.format(amount),
                style: typography.headline.medium.copyWith(
                  fontWeight: FontWeight.bold,
                  color: onPrimary,
                  fontSize: 32.fs,
                ),
              ),
              const Spacer(),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.scheduleSummaryEstimatedArrival,
                    style: typography.label.small.copyWith(
                      color: onPrimary.withValues(alpha: 0.7),
                    ),
                  ),
                  Text(
                    arrivalDate != null
                        ? dateFormat.format(arrivalDate!)
                        : l10n.notAvailable,
                    style: typography.body.large.copyWith(
                      fontWeight: FontWeight.bold,
                      color: onPrimary,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
