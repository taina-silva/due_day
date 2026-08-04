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
    final colors = context.colors;
    final typography = context.typography;
    final spacing = context.spacing;
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
        borderRadius: BorderRadius.circular(context.radius.medium),
        child: Container(
          padding: EdgeInsets.all(spacing.medium.width),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(context.radius.medium),
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
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    DateFormat.MMMd(
                      context.localeString,
                    ).format(transaction.dueDate ?? transaction.createdAt),
                    style: typography.label.small.copyWith(
                      color: colors.resource.secondary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: spacing.extraSmall.height),
                  Text(
                    '${isExpense ? '-' : '+'}${NumberFormat.simpleCurrency(locale: context.localeString).format(transaction.amount.abs())}',
                    style: typography.body.large.copyWith(
                      color: isExpense
                          ? colors.system.error
                          : colors.system.success,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (!transaction.paid) ...[
                    SizedBox(height: spacing.extraSmall.height),
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: spacing.extraSmall.width,
                        vertical: 2.height,
                      ),
                      decoration: BoxDecoration(
                        color: colors.system.warning.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(
                          context.radius.circle,
                        ),
                      ),
                      child: Text(
                        l10n.transactionsPending.toUpperCase(),
                        style: typography.label.small.copyWith(
                          color: colors.system.warning,
                          fontWeight: FontWeight.bold,
                          fontSize: 10.fs,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
