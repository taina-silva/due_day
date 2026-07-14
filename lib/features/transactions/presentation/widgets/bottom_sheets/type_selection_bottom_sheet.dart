import 'package:due_day/core/design_system/theme/theme.dart';
import 'package:due_day/core/l10n/l10n_extension.dart';
import 'package:due_day/core/utils/extensions/num_extension.dart';
import 'package:due_day/features/transactions/domain/entities/transaction_entity.dart';
import 'package:flutter/material.dart';

class TypeSelectionBottomSheet extends StatelessWidget {
  final TransactionType? selectedType;

  const TypeSelectionBottomSheet({super.key, this.selectedType});

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
            l10n.type,
            style: typography.title.medium,
            textAlign: TextAlign.center,
          ),
          SizedBox(height: spacing.medium.height),

          _TypeItem(
            label: l10n.all,
            isSelected: selectedType == null,
            onTap: () => Navigator.pop(context, null),
            icon: Icons.list_alt_rounded,
            color: colors.resource.secondary,
          ),

          _TypeItem(
            label: l10n.income,
            isSelected: selectedType == TransactionType.income,
            onTap: () => Navigator.pop(context, TransactionType.income),
            icon: Icons.arrow_upward_rounded,
            color: colors.system.success,
          ),

          _TypeItem(
            label: l10n.expense,
            isSelected: selectedType == TransactionType.expense,
            onTap: () => Navigator.pop(context, TransactionType.expense),
            icon: Icons.arrow_downward_rounded,
            color: colors.system.error,
          ),
        ],
      ),
    );
  }
}

class _TypeItem extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final IconData icon;
  final Color color;

  const _TypeItem({
    required this.label,
    required this.isSelected,
    required this.onTap,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final spacing = context.spacing;
    final radius = context.radius;
    final typography = context.typography;

    final stroke = context.stroke;

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
              ? color.withValues(alpha: 0.1)
              : colors.lightSurface,
          borderRadius: BorderRadius.circular(radius.medium),
          border: Border.all(
            color: isSelected ? color : Colors.transparent,
            width: stroke.medium,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(spacing.small.scale),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 20.scale),
            ),
            SizedBox(width: spacing.medium.width),
            Expanded(
              child: Text(
                label,
                style: typography.body.medium.copyWith(
                  color: colors.onLightBackground,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ),
            if (isSelected)
              Icon(Icons.check_circle_rounded, color: color, size: 20.scale),
          ],
        ),
      ),
    );
  }
}
