import 'package:due_day/core/design_system/theme/theme.dart';
import 'package:due_day/core/l10n/l10n_extension.dart';
import 'package:due_day/core/utils/extensions/num_extension.dart';
import 'package:due_day/features/transactions/domain/entities/transaction_entity.dart';
import 'package:flutter/material.dart';

class FrequencySelectionBottomSheet extends StatelessWidget {
  final TransactionFrequency? selectedFrequency;

  const FrequencySelectionBottomSheet({super.key, this.selectedFrequency});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final spacing = context.spacing;
    final colors = context.colors;
    final radius = context.radius;
    final typography = context.typography;

    return Container(
      padding: EdgeInsets.only(
        top: spacing.medium.height,
        left: spacing.medium.width,
        right: spacing.medium.width,
        bottom: MediaQuery.of(context).padding.bottom + spacing.medium.height,
      ),
      decoration: BoxDecoration(
        color: colors.lightBackground,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(radius.extraLarge),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: Container(
              width: 40.w,
              height: 4.h,
              decoration: BoxDecoration(
                color: colors.resource.neutral.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(radius.circle),
              ),
            ),
          ),
          SizedBox(height: spacing.medium.height),
          Text(
            l10n.frequency,
            style: typography.title.medium,
            textAlign: TextAlign.center,
          ),
          SizedBox(height: spacing.medium.height),

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
    final colors = context.colors;
    final spacing = context.spacing;
    final radius = context.radius;
    final stroke = context.stroke;
    final typography = context.typography;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.only(bottom: spacing.small.height),
        padding: EdgeInsets.symmetric(
          horizontal: spacing.medium.width,
          vertical: spacing.medium.height,
        ),
        decoration: BoxDecoration(
          color: isSelected
              ? colors.system.info.withValues(alpha: 0.1)
              : colors.lightSurface,
          borderRadius: BorderRadius.circular(radius.medium),
          border: Border.all(
            color: isSelected ? colors.system.info : Colors.transparent,
            width: stroke.medium,
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
                size: 20.scale,
              ),
          ],
        ),
      ),
    );
  }
}
