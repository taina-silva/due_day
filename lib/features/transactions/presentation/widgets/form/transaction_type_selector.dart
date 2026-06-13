import 'package:due_day/core/design_system/theme/theme.dart';
import 'package:due_day/core/l10n/l10n_extension.dart';
import 'package:due_day/core/utils/extensions/num_extension.dart';
import 'package:due_day/features/transactions/domain/entities/transaction_entity.dart';
import 'package:flutter/material.dart';

class TransactionTypeSelector extends StatelessWidget {
  final TransactionType selectedType;
  final ValueChanged<TransactionType> onTypeChanged;

  const TransactionTypeSelector({
    required this.selectedType,
    required this.onTypeChanged,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    const colors = DueDayTheme.colors;
    final spacing = DueDayTheme.dimensions.spacing;
    final l10n = context.l10n;

    return Row(
      children: [
        Expanded(
          child: _TypeItem(
            label: l10n.transactionsTypeExpense,
            icon: Icons.receipt_long_outlined,
            isSelected: selectedType == TransactionType.expense,
            activeColor: colors.system.error,
            onTap: () => onTypeChanged(TransactionType.expense),
          ),
        ),
        SizedBox(width: spacing.medium.width),
        Expanded(
          child: _TypeItem(
            label: l10n.transactionsTypeIncome,
            icon: Icons.account_balance_outlined,
            isSelected: selectedType == TransactionType.income,
            activeColor: Colors.blue, // As per design
            onTap: () => onTypeChanged(TransactionType.income),
          ),
        ),
        SizedBox(width: spacing.medium.width),
        Expanded(
          child: _TypeItem(
            label: l10n.transactionsTypeTransfer,
            icon: Icons.sync_alt_outlined,
            isSelected: selectedType == TransactionType.transfer,
            activeColor: colors.resource.secondary,
            onTap: () => onTypeChanged(TransactionType.transfer),
          ),
        ),
      ],
    );
  }
}

class _TypeItem extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isSelected;
  final Color activeColor;
  final VoidCallback onTap;

  const _TypeItem({
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.activeColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    const colors = DueDayTheme.colors;
    final spacing = DueDayTheme.dimensions.spacing;
    final radius = DueDayTheme.dimensions.radius;
    const typography = DueDayTheme.typography;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(vertical: spacing.mediumLarge.height),
        decoration: BoxDecoration(
          color: isSelected
              ? activeColor.withValues(alpha: 0.1)
              : Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(radius.medium),
          border: Border.all(
            color: isSelected
                ? activeColor
                : colors.resource.secondary.withValues(alpha: 0.1),
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: activeColor.withValues(alpha: 0.2),
                    blurRadius: 10.width,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: isSelected ? activeColor : colors.resource.secondary,
              size: 24.width,
            ),
            SizedBox(height: spacing.small.height),
            Text(
              label,
              style: typography.label.small.copyWith(
                color: isSelected ? activeColor : colors.resource.secondary,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
