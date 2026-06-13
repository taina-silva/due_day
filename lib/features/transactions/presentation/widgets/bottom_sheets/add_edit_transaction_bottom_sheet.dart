import 'package:due_day/core/design_system/theme/theme.dart';
import 'package:due_day/core/l10n/app_localizations.dart';
import 'package:due_day/core/utils/extensions/num_extension.dart';
import 'package:due_day/features/transactions/domain/entities/transaction_entity.dart';
import 'package:due_day/features/transactions/presentation/widgets/form/transaction_create_form.dart';
import 'package:flutter/material.dart';

class AddEditTransactionBottomSheet extends StatelessWidget {
  final TransactionEntity? transaction;

  const AddEditTransactionBottomSheet({this.transaction, super.key});

  @override
  Widget build(BuildContext context) {
    const typography = DueDayTheme.typography;
    const dimensions = DueDayTheme.dimensions;
    final l10n = AppLocalizations.of(context);

    final isEditing = transaction != null;

    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.85,
      child: Column(
        children: [
          SizedBox(height: dimensions.spacing.medium.height),
          Center(
            child: Container(
              width: 40.width,
              height: 4.height,
              decoration: BoxDecoration(
                color: Theme.of(
                  context,
                ).colorScheme.onSurfaceVariant.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(dimensions.radius.circle),
              ),
            ),
          ),
          SizedBox(height: dimensions.spacing.large.height),
          Text(
            isEditing
                ? l10n.transactionsEditTransaction
                : l10n.transactionsAddTransaction,
            style: typography.title.large.copyWith(fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          Expanded(
            child: TransactionCreateForm(
              transaction: transaction,
              onSave: () => Navigator.of(context).pop(),
            ),
          ),
        ],
      ),
    );
  }
}
