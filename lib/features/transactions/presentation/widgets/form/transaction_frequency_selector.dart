import 'package:due_day/core/design_system/theme/theme.dart';
import 'package:due_day/core/l10n/l10n_extension.dart';
import 'package:due_day/core/utils/extensions/num_extension.dart';
import 'package:due_day/features/transactions/domain/entities/transaction_entity.dart';
import 'package:flutter/material.dart';

class TransactionFrequencySelector extends StatelessWidget {
  final TransactionFrequency selectedFrequency;
  final ValueChanged<TransactionFrequency> onFrequencyChanged;

  const TransactionFrequencySelector({
    required this.selectedFrequency,
    required this.onFrequencyChanged,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final spacing = context.spacing;
    final l10n = context.l10n;

    return Row(
      children: [
        _FrequencyItem(
          label: l10n.transactionsFrequencyWeekly,
          isSelected: selectedFrequency == TransactionFrequency.weekly,
          onTap: () => onFrequencyChanged(TransactionFrequency.weekly),
        ),
        SizedBox(width: spacing.small.width),
        _FrequencyItem(
          label: l10n.transactionsFrequencyBiWeekly,
          isSelected: selectedFrequency == TransactionFrequency.biWeekly,
          onTap: () => onFrequencyChanged(TransactionFrequency.biWeekly),
        ),
        SizedBox(width: spacing.small.width),
        _FrequencyItem(
          label: l10n.transactionsFrequencyMonthly,
          isSelected: selectedFrequency == TransactionFrequency.monthly,
          onTap: () => onFrequencyChanged(TransactionFrequency.monthly),
        ),
        SizedBox(width: spacing.small.width),
        _FrequencyItem(
          label: l10n.transactionsFrequencyYearly,
          isSelected: selectedFrequency == TransactionFrequency.yearly,
          onTap: () => onFrequencyChanged(TransactionFrequency.yearly),
        ),
      ],
    );
  }
}

class _FrequencyItem extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _FrequencyItem({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final spacing = context.spacing;
    final typography = context.typography;
    final radius = context.radius;

    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: EdgeInsets.symmetric(vertical: spacing.medium.height),
          decoration: BoxDecoration(
            color: isSelected
                ? colors.resource.primary.withValues(alpha: 0.1)
                : colors.lightSurface,
            borderRadius: BorderRadius.circular(radius.medium),
            border: Border.all(
              color: isSelected
                  ? colors.resource.primary
                  : colors.resource.secondary.withValues(alpha: 0.1),
              width: context.stroke.small,
            ),
          ),
          child: Center(
            child: Text(
              label,
              style: typography.label.small.copyWith(
                color: isSelected
                    ? colors.resource.primary
                    : colors.resource.secondary,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
