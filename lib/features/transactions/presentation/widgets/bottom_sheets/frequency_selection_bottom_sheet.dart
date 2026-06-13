import 'package:due_day/core/design_system/theme/theme.dart';
import 'package:due_day/core/l10n/l10n_extension.dart';
import 'package:due_day/features/transactions/domain/entities/transaction_entity.dart';
import 'package:flutter/material.dart';

class FrequencySelectionBottomSheet extends StatelessWidget {
  final TransactionFrequency? selectedFrequency;

  const FrequencySelectionBottomSheet({super.key, this.selectedFrequency});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final spacing = DueDayTheme.dimensions.spacing;
    const colors = DueDayTheme.colors;
    const typography = DueDayTheme.typography;

    return Container(
      padding: EdgeInsets.only(
        top: spacing.medium,
        left: spacing.medium,
        right: spacing.medium,
        bottom: MediaQuery.of(context).padding.bottom + spacing.medium,
      ),
      decoration: BoxDecoration(
        color: colors.lightBackground,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: colors.resource.neutral.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          SizedBox(height: spacing.medium),
          Text(
            l10n.frequency,
            style: typography.title.medium,
            textAlign: TextAlign.center,
          ),
          SizedBox(height: spacing.medium),

          // "All" or "None" option
          _FrequencyItem(
            label: l10n.all,
            isSelected: selectedFrequency == null,
            onTap: () => Navigator.pop(context, null),
          ),

          ...TransactionFrequency.values.map(
            (f) => _FrequencyItem(
              label: _getFrequencyLabel(f, l10n),
              isSelected: selectedFrequency == f,
              onTap: () => Navigator.pop(context, f),
            ),
          ),
        ],
      ),
    );
  }

  String _getFrequencyLabel(TransactionFrequency frequency, dynamic l10n) {
    switch (frequency) {
      case TransactionFrequency.none:
        return l10n.transactionsFrequencyNone;
      case TransactionFrequency.weekly:
        return l10n.transactionsFrequencyWeekly;
      case TransactionFrequency.biWeekly:
        return l10n.transactionsFrequencyBiWeekly;
      case TransactionFrequency.monthly:
        return l10n.transactionsFrequencyMonthly;
      case TransactionFrequency.yearly:
        return l10n.transactionsFrequencyYearly;
    }
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
    const colors = DueDayTheme.colors;
    final spacing = DueDayTheme.dimensions.spacing;
    final radius = DueDayTheme.dimensions.radius;
    const typography = DueDayTheme.typography;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.only(bottom: spacing.small),
        padding: EdgeInsets.symmetric(
          horizontal: spacing.medium,
          vertical: spacing.medium,
        ),
        decoration: BoxDecoration(
          color: isSelected
              ? colors.system.info.withValues(alpha: 0.1)
              : colors.lightSurface,
          borderRadius: BorderRadius.circular(radius.medium),
          border: Border.all(
            color: isSelected ? colors.system.info : Colors.transparent,
            width: 1.5,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: typography.body.medium.copyWith(
                color: isSelected
                    ? colors.system.info
                    : colors.onLightBackground,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
            if (isSelected)
              Icon(
                Icons.check_circle_rounded,
                color: colors.system.info,
                size: 20,
              ),
          ],
        ),
      ),
    );
  }
}
