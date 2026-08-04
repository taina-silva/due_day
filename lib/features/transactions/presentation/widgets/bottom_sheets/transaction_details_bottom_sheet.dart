import 'package:due_day/core/design_system/components/buttons/app_text_button.dart';
import 'package:due_day/core/design_system/components/messenger/app_messenger.dart';
import 'package:due_day/core/design_system/theme/theme.dart';
import 'package:due_day/core/l10n/app_localizations.dart';
import 'package:due_day/core/l10n/l10n_extension.dart';
import 'package:due_day/core/utils/extensions/num_extension.dart';
import 'package:due_day/features/accounts/presentation/bloc/account_load_bloc.dart';
import 'package:due_day/features/accounts/presentation/bloc/account_load_state.dart';
import 'package:due_day/features/categories/presentation/bloc/category_load_bloc.dart';
import 'package:due_day/features/categories/presentation/bloc/category_load_state.dart';
import 'package:due_day/features/categories/presentation/utils/category_utils.dart';
import 'package:due_day/features/transactions/domain/entities/transaction_entity.dart';
import 'package:due_day/features/transactions/presentation/bloc/transaction_action_bloc.dart';
import 'package:due_day/features/transactions/presentation/bloc/transaction_action_event.dart';
import 'package:due_day/features/transactions/presentation/bloc/transaction_action_state.dart';
import 'package:due_day/features/transactions/presentation/utils/transaction_failure_extension.dart';
import 'package:due_day/features/transactions/presentation/widgets/bottom_sheets/add_edit_transaction_bottom_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

class TransactionDetailsBottomSheet extends StatefulWidget {
  final TransactionEntity transaction;

  const TransactionDetailsBottomSheet({required this.transaction, super.key});

  @override
  State<TransactionDetailsBottomSheet> createState() =>
      _TransactionDetailsBottomSheetState();
}

class _TransactionDetailsBottomSheetState
    extends State<TransactionDetailsBottomSheet> {
  bool _isSubmitting = false;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final typography = context.typography;
    final dimensions = context.dimensions;
    final l10n = AppLocalizations.of(context);
    final transaction = widget.transaction;

    final isExpense = transaction.type == TransactionType.expense;
    final isIncome = transaction.type == TransactionType.income;
    final amountColor = isExpense
        ? colors.system.error
        : (isIncome ? colors.system.success : colors.resource.secondary);
    final sign = isExpense ? '-' : (isIncome ? '+' : '');

    final formattedAmount = NumberFormat.currency(
      locale: context.localeString,
      symbol: '\$',
      decimalDigits: 2,
    ).format(transaction.amount);

    final formattedDate = DateFormat.yMMMMd(
      context.localeString,
    ).format(transaction.dueDate ?? transaction.createdAt);

    return BlocListener<TransactionActionBloc, TransactionActionState>(
      listener: (context, state) {
        if (!_isSubmitting) return;

        if (state is TransactionActionError) {
          setState(() => _isSubmitting = false);
          AppMessenger.showError(
            context,
            state.failure.toLocalizedString(context),
          );
        } else if (state is TransactionActionSuccess) {
          _isSubmitting = false;
          Navigator.of(context).pop();
        }
      },
      child: Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
          left: dimensions.spacing.medium.width,
          right: dimensions.spacing.medium.width,
          top: dimensions.spacing.large.height,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
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
            Stack(
              alignment: Alignment.center,
              children: [
                Text(
                  l10n.transactionsDetailTitle,
                  style: typography.title.large.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                Positioned(
                  right: 0,
                  child: IconButton(
                    icon: Icon(
                      Icons.edit_outlined,
                      color: colors.resource.secondary,
                    ),
                    onPressed: () => _onEdit(context),
                  ),
                ),
              ],
            ),
            SizedBox(height: dimensions.spacing.extraLarge.height),
            Center(
              child: Column(
                children: [
                  Text(
                    '$sign$formattedAmount',
                    style: typography.headline.large.copyWith(
                      color: amountColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: dimensions.spacing.small.height),
                  Text(
                    formattedDate,
                    style: typography.body.medium.copyWith(
                      color: colors.resource.secondary,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: dimensions.spacing.twoExtraLarge.height),
            _DetailRow(
              label: l10n.type,
              value: _getTypeLabel(l10n, transaction.type),
              icon: _getTypeIcon(transaction.type),
            ),
            if (transaction.category != null)
              BlocBuilder<CategoryLoadBloc, CategoryLoadState>(
                builder: (context, state) {
                  String categoryName = l10n.notAvailable;
                  IconData categoryIcon = Icons.category_outlined;
                  if (state is CategoryLoaded) {
                    try {
                      final cat = state.categories.firstWhere(
                        (c) => c.id == transaction.category,
                      );
                      categoryName = cat.name;
                      categoryIcon = CategoryIconUtils.parseIcon(cat.icon);
                    } catch (_) {}
                  }
                  return _DetailRow(
                    label: l10n.category,
                    value: categoryName,
                    icon: categoryIcon,
                  );
                },
              ),
            BlocBuilder<AccountLoadBloc, AccountLoadState>(
              builder: (context, state) {
                String fromAccount = l10n.notAvailable;
                String? toAccount;

                if (state is AccountLoaded) {
                  if (transaction.accountFrom != null) {
                    try {
                      final acc = state.accounts.firstWhere(
                        (a) => a.id == transaction.accountFrom,
                      );
                      fromAccount = acc.deletedAt != null
                          ? '${acc.name} ${l10n.accountsDeleted}'
                          : acc.name;
                    } catch (_) {}
                  }
                  if (transaction.accountTo != null) {
                    try {
                      final acc = state.accounts.firstWhere(
                        (a) => a.id == transaction.accountTo,
                      );
                      toAccount = acc.deletedAt != null
                          ? '${acc.name} ${l10n.accountsDeleted}'
                          : acc.name;
                    } catch (_) {}
                  }
                }

                return Column(
                  children: [
                    _DetailRow(
                      label: transaction.type == TransactionType.transfer
                          ? l10n.transactionsAccountFrom
                          : l10n.navAccount,
                      value: fromAccount,
                      icon: Icons.account_balance_wallet_outlined,
                    ),
                    if (toAccount != null)
                      _DetailRow(
                        label: l10n.transactionsAccountTo,
                        value: toAccount,
                        icon: Icons.account_balance_wallet_outlined,
                      ),
                  ],
                );
              },
            ),
            if (transaction.notes != null && transaction.notes!.isNotEmpty)
              _DetailRow(
                label: l10n.transactionsNotesLabel,
                value: transaction.notes!,
                icon: Icons.notes_rounded,
              ),
            _DetailRow(
              label: l10n.transactionsPaidStatus,
              value: transaction.paid
                  ? l10n.transactionsPaid
                  : l10n.transactionsPending,
              icon: transaction.paid
                  ? Icons.check_circle_outline
                  : Icons.pending_outlined,
              valueColor: transaction.paid
                  ? colors.system.success
                  : colors.system.warning,
            ),
            if (transaction.isRecurring)
              _DetailRow(
                label: l10n.transactionsRecurrence,
                value: _getFrequencyLabel(l10n, transaction.frequency),
                icon: Icons.repeat_rounded,
              ),
            SizedBox(height: dimensions.spacing.twoExtraLarge.height),
            if (!transaction.paid) ...[
              AppTextButtonPrimary(
                label: l10n.transactionsMarkAsPaid,
                onPressed: () => _onMarkAsPaid(context),
                prefixIcon: Icons.check_circle_outline,
                isLoading: _isSubmitting,
              ),
              SizedBox(height: dimensions.spacing.medium.height),
            ],
            AppTextButtonSecondary(
              label: l10n.transactionsDeleteTransaction,
              onPressed: () => _onDelete(context),
              prefixIcon: Icons.delete_outline,
              foregroundColor: colors.system.error,
              borderColor: colors.system.error.withValues(alpha: 0.3),
            ),
            SizedBox(height: dimensions.spacing.large.height),
          ],
        ),
      ),
    );
  }

  String _getTypeLabel(AppLocalizations l10n, TransactionType type) {
    switch (type) {
      case TransactionType.expense:
        return l10n.transactionsTypeExpense;
      case TransactionType.income:
        return l10n.transactionsTypeIncome;
      case TransactionType.transfer:
        return l10n.transactionsTypeTransfer;
    }
  }

  IconData _getTypeIcon(TransactionType type) {
    switch (type) {
      case TransactionType.expense:
        return Icons.arrow_downward_rounded;
      case TransactionType.income:
        return Icons.arrow_upward_rounded;
      case TransactionType.transfer:
        return Icons.sync_alt_rounded;
    }
  }

  String _getFrequencyLabel(AppLocalizations l10n, TransactionFrequency freq) {
    switch (freq) {
      case TransactionFrequency.weekly:
        return l10n.transactionsFrequencyWeekly;
      case TransactionFrequency.biWeekly:
        return l10n.transactionsFrequencyBiWeekly;
      case TransactionFrequency.monthly:
        return l10n.transactionsFrequencyMonthly;
      case TransactionFrequency.yearly:
        return l10n.transactionsFrequencyYearly;
      case TransactionFrequency.none:
        return l10n.transactionsFrequencyNone;
    }
  }

  void _onEdit(BuildContext context) {
    Navigator.of(context).pop();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useRootNavigator: true,
      builder: (context) =>
          AddEditTransactionBottomSheet(transaction: widget.transaction),
    );
  }

  void _onMarkAsPaid(BuildContext context) {
    setState(() => _isSubmitting = true);
    context.read<TransactionActionBloc>().add(
      UpdateTransactionEvent(
        widget.transaction.copyWith(paid: true, paidDate: DateTime.now()),
      ),
    );
  }

  void _onDelete(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.transactionsDeleteTransaction),
        content: Text(l10n.transactionsConfirmDelete),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: Text(l10n.profileCancel),
          ),
          TextButton(
            onPressed: () {
              setState(() => _isSubmitting = true);
              context.read<TransactionActionBloc>().add(
                DeleteTransactionEvent(widget.transaction.id),
              );
              Navigator.of(
                dialogContext,
              ).pop(); // Close confirmation dialog only
            },
            child: Text(
              l10n.profileExclude,
              style: TextStyle(color: context.colors.system.error),
            ),
          ),
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color? valueColor;

  const _DetailRow({
    required this.label,
    required this.value,
    required this.icon,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final typography = context.typography;
    final spacing = context.spacing;
    final radius = context.radius;

    return Padding(
      padding: EdgeInsets.symmetric(vertical: spacing.small.height),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(spacing.extraSmall.scale),
            decoration: BoxDecoration(
              color: colors.resource.secondary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(radius.small),
            ),
            child: Icon(icon, size: 20.scale, color: colors.resource.secondary),
          ),
          SizedBox(width: spacing.medium.width),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label.toUpperCase(),
                  style: typography.label.small.copyWith(
                    color: colors.resource.secondary,
                    letterSpacing: 1.2,
                  ),
                ),
                Text(
                  value,
                  style: typography.body.medium.copyWith(
                    fontWeight: FontWeight.w600,
                    color:
                        valueColor ?? Theme.of(context).colorScheme.onSurface,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
