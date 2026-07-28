import 'package:due_day/core/l10n/l10n_extension.dart';
import 'package:due_day/features/transactions/domain/entities/transaction_entity.dart';
import 'package:flutter/widgets.dart';

extension TransactionTypeLabelExtension on TransactionType {
  String getLabel(BuildContext context) {
    return switch (this) {
      TransactionType.income => context.l10n.income,
      TransactionType.expense => context.l10n.expense,
      TransactionType.transfer => context.l10n.transfer,
    };
  }
}

extension TransactionFrequencyLabelExtension on TransactionFrequency {
  String getLabel(BuildContext context) {
    return switch (this) {
      TransactionFrequency.none => context.l10n.transactionsFrequencyNone,
      TransactionFrequency.weekly => context.l10n.transactionsFrequencyWeekly,
      TransactionFrequency.biWeekly =>
        context.l10n.transactionsFrequencyBiWeekly,
      TransactionFrequency.monthly => context.l10n.transactionsFrequencyMonthly,
      TransactionFrequency.yearly => context.l10n.transactionsFrequencyYearly,
    };
  }
}
