import 'package:due_day/core/design_system/theme/theme.dart';
import 'package:due_day/core/l10n/l10n_extension.dart';
import 'package:due_day/core/utils/extensions/date_extension.dart';
import 'package:due_day/core/utils/extensions/num_extension.dart';
import 'package:due_day/features/categories/domain/entities/category_entity.dart';
import 'package:due_day/features/transactions/domain/entities/transaction_entity.dart';
import 'package:flutter/material.dart';

class TransactionFilterBar extends StatelessWidget {
  final TransactionType? selectedType;
  final String? selectedCategoryId;
  final TransactionFrequency? selectedFrequency;
  final DateTime? startDate;
  final DateTime? endDate;
  final List<CategoryEntity> categories;

  final Function(TransactionType?) onTypeChanged;
  final VoidCallback onCategoryTap;
  final VoidCallback onFrequencyTap;
  final VoidCallback onDateTap;
  final VoidCallback onOpenAdvancedFilters;

  const TransactionFilterBar({
    required this.selectedType,
    required this.selectedCategoryId,
    required this.selectedFrequency,
    required this.startDate,
    required this.endDate,
    required this.categories,
    required this.onTypeChanged,
    required this.onCategoryTap,
    required this.onFrequencyTap,
    required this.onDateTap,
    required this.onOpenAdvancedFilters,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colors = context.colors;
    final spacing = context.spacing;

    final selectedCategory = categories
        .where((c) => c.id == selectedCategoryId)
        .firstOrNull;

    return Container(
      padding: EdgeInsets.symmetric(vertical: spacing.medium.height),
      child: Column(
        children: [
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.symmetric(horizontal: spacing.medium.width),
            child: Row(
              children: [
                // Type Filter (Primary)
                _FilterChip(
                  label: l10n.all,
                  isSelected: selectedType == null,
                  onTap: () => onTypeChanged(null),
                ),
                SizedBox(width: spacing.small.width),
                _FilterChip(
                  label: l10n.income,
                  isSelected: selectedType == TransactionType.income,
                  onTap: () => onTypeChanged(TransactionType.income),
                  activeColor: colors.system.success,
                ),
                SizedBox(width: spacing.small.width),
                _FilterChip(
                  label: l10n.expense,
                  isSelected: selectedType == TransactionType.expense,
                  onTap: () => onTypeChanged(TransactionType.expense),
                  activeColor: colors.system.error,
                ),
                SizedBox(width: spacing.small.width),
                _FilterChip(
                  label: l10n.transfer,
                  isSelected: selectedType == TransactionType.transfer,
                  onTap: () => onTypeChanged(TransactionType.transfer),
                  activeColor: colors.resource.secondary,
                ),

                // Divider
                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: spacing.small.width,
                  ),
                  child: Container(
                    height: 24.height,
                    width: 1.width,
                    color: colors.resource.neutral.withValues(alpha: 0.3),
                  ),
                ),

                // Category Filter
                _FilterChip(
                  label: selectedCategory?.name ?? l10n.category,
                  isSelected: selectedCategoryId != null,
                  onTap: onCategoryTap,
                  icon: Icons.category_outlined,
                ),
                SizedBox(width: spacing.small.width),

                // Frequency Filter
                _FilterChip(
                  label: selectedFrequency != null
                      ? selectedFrequency!.getLabel(context)
                      : l10n.frequency,
                  isSelected: selectedFrequency != null,
                  onTap: onFrequencyTap,
                  icon: Icons.repeat_rounded,
                ),
                SizedBox(width: spacing.small.width),

                // Date Filter
                _FilterChip(
                  label: startDate.toRangeLabel(context, endDate: endDate),
                  isSelected: startDate != null,
                  onTap: onDateTap,
                  icon: Icons.calendar_today_outlined,
                ),

                SizedBox(width: spacing.small.width),

                // Advanced Filters Button
                GestureDetector(
                  onTap: onOpenAdvancedFilters,
                  child: Container(
                    padding: EdgeInsets.all(spacing.small.scale),
                    decoration: BoxDecoration(
                      color: colors.lightSurface,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: colors.resource.neutral,
                        width: context.stroke.medium,
                      ),
                    ),
                    child: Icon(
                      Icons.tune,
                      size: 20.scale,
                      color: colors.system.info,
                    ),
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

class _FilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final Color? activeColor;
  final IconData? icon;

  const _FilterChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
    this.activeColor,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final spacing = context.spacing;
    final radius = context.radius;
    final typography = context.typography;

    final baseColor = activeColor ?? colors.system.info;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(
          horizontal: spacing.medium.width,
          vertical: spacing.small.height,
        ),
        decoration: BoxDecoration(
          color: isSelected
              ? baseColor.withValues(alpha: 0.15)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(radius.medium),
          border: Border.all(
            color: isSelected ? baseColor : colors.resource.neutral,
            width: context.stroke.medium,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(
                icon,
                size: 16.scale,
                color: isSelected ? baseColor : colors.resource.secondary,
              ),
              SizedBox(width: spacing.extraSmall.width),
            ],
            Text(
              label,
              style: typography.body.small.copyWith(
                color: isSelected ? baseColor : colors.resource.secondary,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
