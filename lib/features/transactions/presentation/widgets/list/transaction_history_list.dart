import 'package:collection/collection.dart';
import 'package:due_day/core/design_system/theme/theme.dart';
import 'package:due_day/core/l10n/l10n_extension.dart';
import 'package:due_day/core/utils/extensions/num_extension.dart';
import 'package:due_day/features/categories/domain/entities/category_entity.dart';
import 'package:due_day/features/transactions/domain/entities/transaction_entity.dart';
import 'package:due_day/features/transactions/presentation/widgets/list/transaction_item.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class TransactionHistoryList extends StatelessWidget {
  final List<TransactionEntity> transactions;
  final List<CategoryEntity> categories;
  final Function(TransactionEntity)? onTransactionTap;

  const TransactionHistoryList({
    required this.transactions,
    required this.categories,
    this.onTransactionTap,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    const typography = DueDayTheme.typography;
    final spacing = DueDayTheme.dimensions.spacing;

    // Group transactions by date (ignoring time)
    final groupedTransactions = groupBy(transactions, (tx) {
      final date = tx.createdAt;
      return DateTime(date.year, date.month, date.day);
    }).entries.toList();

    // Sort groups by date descending
    groupedTransactions.sort((a, b) => b.key.compareTo(a.key));

    return ListView.builder(
      padding: EdgeInsets.symmetric(horizontal: spacing.largeExtraLarge.width),
      itemCount: groupedTransactions.length,
      itemBuilder: (context, index) {
        final entry = groupedTransactions[index];
        final date = entry.key;
        final txs = entry.value;

        // Sort transactions within the group by time (descending)
        final sortedTxs = txs
          ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.only(
                top: spacing.medium.height,
                bottom: spacing.small.height,
              ),
              child: Text(
                _formatDateHeader(context, date),
                style: typography.label.small.copyWith(
                  fontWeight: FontWeight.bold,
                  color: DueDayTheme.colors.resource.secondary,
                ),
              ),
            ),
            ...sortedTxs.map((tx) {
              final category = categories.firstWhereOrNull(
                (c) => c.id == tx.category,
              );
              final isLast = sortedTxs.last == tx;

              return Column(
                children: [
                  TransactionItem(
                    transaction: tx,
                    category: category,
                    onTap: onTransactionTap != null
                        ? () => onTransactionTap!(tx)
                        : null,
                  ),
                  if (!isLast) SizedBox(height: spacing.medium.height),
                ],
              );
            }),
          ],
        );
      },
    );
  }

  String _formatDateHeader(BuildContext context, DateTime date) {
    final l10n = context.l10n;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));

    if (date == today) {
      return l10n.dateToday.toUpperCase();
    } else if (date == yesterday) {
      return l10n.dateYesterday.toUpperCase();
    } else {
      // For older dates, use a more complete format
      return DateFormat(
        'dd MMMM yyyy',
        context.localeString,
      ).format(date).toUpperCase();
    }
  }
}
