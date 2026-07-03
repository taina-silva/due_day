import 'package:due_day/core/design_system/theme/theme.dart';
import 'package:due_day/core/l10n/app_localizations.dart';
import 'package:due_day/core/l10n/l10n_extension.dart';
import 'package:due_day/core/utils/extensions/num_extension.dart';
import 'package:due_day/features/accounts/domain/entities/account_entity.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class AccountCard extends StatelessWidget {
  final AccountEntity account;
  final VoidCallback onTap;

  const AccountCard({required this.account, required this.onTap, super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final typography = context.typography;
    final dimensions = context.dimensions;
    final l10n = AppLocalizations.of(context);
    final formatCurrency = NumberFormat.simpleCurrency(
      locale: context.localeString,
    );

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: dimensions.spacing.paddingMedium,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(dimensions.radius.large),
          boxShadow: [
            BoxShadow(
              color: colors.resource.neutral.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: dimensions.spacing.paddingSmall,
              decoration: BoxDecoration(
                color: colors.resource.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(dimensions.radius.medium),
              ),
              child: Icon(
                account.category.icon,
                color: colors.resource.primary,
                size: 28,
              ),
            ),
            SizedBox(width: dimensions.spacing.medium.width),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    account.name,
                    style: typography.body.large.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: dimensions.spacing.smallMedium.height),
                  Text(
                    account.category.localizedName(l10n).toUpperCase(),
                    style: typography.label.medium.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  formatCurrency.format(account.balance),
                  style: typography.title.medium.copyWith(
                    fontWeight: FontWeight.bold,
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
