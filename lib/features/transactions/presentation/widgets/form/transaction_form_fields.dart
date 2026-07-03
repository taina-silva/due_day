import 'package:due_day/core/design_system/components/form_fields/app_text_field.dart';
import 'package:due_day/core/design_system/theme/theme.dart';
import 'package:due_day/core/l10n/app_localizations.dart';
import 'package:due_day/core/l10n/l10n_extension.dart';
import 'package:due_day/core/utils/extensions/num_extension.dart';
import 'package:due_day/features/accounts/domain/entities/account_entity.dart';
import 'package:due_day/features/categories/domain/entities/category_entity.dart';
import 'package:due_day/features/transactions/domain/entities/transaction_entity.dart';
import 'package:due_day/features/transactions/presentation/widgets/form/transaction_frequency_selector.dart';
import 'package:due_day/features/transactions/presentation/widgets/shared/selection_field_widget.dart';
import 'package:due_day/features/transactions/presentation/widgets/shared/toggle_field_widget.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class TransactionFormFields extends StatelessWidget {
  final TransactionType selectedType;
  final DateTime selectedDate;
  final CategoryEntity? selectedCategory;
  final AccountEntity? selectedAccountFrom;
  final AccountEntity? selectedAccountTo;
  final bool isRecurring;
  final bool isPaid;
  final TransactionFrequency selectedFrequency;
  final TextEditingController notesController;
  final AppLocalizations l10n;

  final VoidCallback onSelectDate;
  final VoidCallback onSelectCategory;
  final VoidCallback onSelectAccountFrom;
  final VoidCallback onSelectAccountTo;
  final ValueChanged<bool> onIsRecurringChanged;
  final ValueChanged<bool> onIsPaidChanged;
  final ValueChanged<TransactionFrequency> onFrequencyChanged;

  const TransactionFormFields({
    required this.selectedType,
    required this.selectedDate,
    required this.isRecurring,
    required this.selectedFrequency,
    required this.notesController,
    required this.l10n,
    required this.onSelectDate,
    required this.onSelectCategory,
    required this.onSelectAccountFrom,
    required this.onSelectAccountTo,
    required this.isPaid,
    required this.onIsRecurringChanged,
    required this.onIsPaidChanged,
    required this.onFrequencyChanged,
    super.key,
    this.selectedCategory,
    this.selectedAccountFrom,
    this.selectedAccountTo,
  });

  @override
  Widget build(BuildContext context) {
    final spacing = context.spacing;

    return Column(
      children: [
        TransactionSelectionField(
          label: l10n.transactionsDate,
          value: DateFormat.yMd(context.localeString).format(selectedDate),
          icon: Icons.calendar_today_rounded,
          onTap: onSelectDate,
        ),
        if (selectedType != TransactionType.transfer) ...[
          SizedBox(height: spacing.medium.height),
          TransactionSelectionField(
            label: l10n.transactionsCategory,
            value: selectedCategory?.name ?? l10n.transactionsSelectCategory,
            icon: Icons.category_outlined,
            onTap: onSelectCategory,
          ),
        ],
        SizedBox(height: spacing.medium.height),
        TransactionSelectionField(
          label: selectedType == TransactionType.income
              ? l10n.transactionsAccountTo
              : l10n.transactionsAccountFrom,
          value: _formatAccountName(
            selectedType == TransactionType.income
                ? selectedAccountTo
                : selectedAccountFrom,
            l10n,
          ),
          icon: Icons.account_balance_wallet_outlined,
          onTap: selectedType == TransactionType.income
              ? onSelectAccountTo
              : onSelectAccountFrom,
        ),
        if (selectedType == TransactionType.transfer) ...[
          SizedBox(height: spacing.medium.height),
          TransactionSelectionField(
            label: l10n.transactionsAccountTo,
            value: _formatAccountName(selectedAccountTo, l10n),
            icon: Icons.account_balance_wallet_outlined,
            onTap: onSelectAccountTo,
          ),
        ],
        SizedBox(height: spacing.medium.height),
        TransactionToggleField(
          label: l10n.transactionsRecurrence,
          valueLabel: l10n.transactionsRecurringLabel,
          isOn: isRecurring,
          onChanged: onIsRecurringChanged,
        ),
        SizedBox(height: spacing.medium.height),
        TransactionToggleField(
          label: l10n.transactionsPaidStatus,
          valueLabel: l10n.transactionsPaidLabel,
          isOn: isPaid,
          onChanged: onIsPaidChanged,
        ),
        if (isRecurring) ...[
          SizedBox(height: spacing.medium.height),
          TransactionFrequencySelector(
            selectedFrequency: selectedFrequency,
            onFrequencyChanged: onFrequencyChanged,
          ),
        ],
        SizedBox(height: spacing.medium.height),
        AppTextField(
          controller: notesController,
          label: l10n.transactionsNotesLabel,
          hintText: l10n.transactionsNotesHint,
          maxLines: 3,
        ),
      ],
    );
  }

  String _formatAccountName(AccountEntity? account, AppLocalizations l10n) {
    if (account == null) return l10n.transactionsSelectAccount;
    if (account.deletedAt != null) return '${account.name} ${l10n.accountsDeleted}';
    return account.name;
  }
}
