import 'package:due_day/core/design_system/theme/theme.dart';
import 'package:due_day/core/l10n/l10n_extension.dart';
import 'package:due_day/core/utils/extensions/num_extension.dart';
import 'package:due_day/features/categories/domain/entities/category_entity.dart';
import 'package:due_day/features/categories/presentation/utils/category_utils.dart';
import 'package:due_day/features/transactions/domain/entities/transaction_entity.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class TransactionItem extends StatelessWidget {
  final TransactionEntity transaction;
  final CategoryEntity? category;
  final VoidCallback? onTap;

  const TransactionItem({
    required this.transaction,
    this.category,
    this.onTap,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    const colors = DueDayTheme.colors;
    const typography = DueDayTheme.typography;
    final spacing = DueDayTheme.dimensions.spacing;
    final l10n = context.l10n;

    final isExpense = transaction.type == TransactionType.expense;
    final categoryName = category?.name;
    final noteText = transaction.notes;

    final String title;
    final String subtitle;

    if (categoryName != null) {
      title = categoryName;
      subtitle = noteText?.isNotEmpty == true
          ? noteText!
          : (isExpense
              ? l10n.transactionsFilterExpense
              : l10n.transactionsFilterIncome);
    } else if (noteText != null && noteText.isNotEmpty) {
      title = noteText;
      subtitle = isExpense
          ? l10n.transactionsFilterExpense
          : l10n.transactionsFilterIncome;
    } else {
      title = l10n.defaultTransaction;
      subtitle = isExpense
          ? l10n.transactionsFilterExpense
          : l10n.transactionsFilterIncome;
    }

    // Determine icon and color
    final iconData = category != null
        ? CategoryIconUtils.parseIcon(category!.icon)
        : (isExpense
            ? Icons.arrow_outward_rounded
            : Icons.call_received_rounded);

    final categoryColor = category != null
        ? CategoryColorUtils.parseColor(
            category!.color,
            isExpense ? colors.system.error : colors.system.success,
          )
        : (isExpense ? colors.system.error : colors.system.success);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(
          DueDayTheme.dimensions.radius.medium,
        ),
        child: Container(
          padding: EdgeInsets.all(spacing.medium.width),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(
              DueDayTheme.dimensions.radius.medium,
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: EdgeInsets.all(spacing.medium.width),
                decoration: BoxDecoration(
                  color: categoryColor.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(iconData, color: categoryColor, size: 20.width),
              ),
              SizedBox(width: spacing.medium.width),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: typography.body.medium.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      subtitle,
                      style: typography.label.small.copyWith(
                        color: colors.resource.secondary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              SizedBox(width: spacing.medium.width),
              Text(
                '${isExpense ? '-' : '+'}${NumberFormat.simpleCurrency(locale: context.localeString).format(transaction.amount.abs())}',
                style: typography.body.large.copyWith(
                  color: isExpense ? colors.system.error : colors.system.success,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
