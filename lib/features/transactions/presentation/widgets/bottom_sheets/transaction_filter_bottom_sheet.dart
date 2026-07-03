import 'package:due_day/core/design_system/theme/theme.dart';
import 'package:due_day/core/l10n/l10n_extension.dart';
import 'package:due_day/features/categories/domain/entities/category_entity.dart';
import 'package:due_day/features/transactions/domain/entities/transaction_entity.dart';
import 'package:due_day/features/transactions/presentation/widgets/bottom_sheets/category_selection_bottom_sheet.dart';
import 'package:due_day/features/transactions/presentation/widgets/bottom_sheets/date_selection_bottom_sheet.dart';
import 'package:due_day/features/transactions/presentation/widgets/bottom_sheets/frequency_selection_bottom_sheet.dart';
import 'package:due_day/features/transactions/presentation/widgets/bottom_sheets/type_selection_bottom_sheet.dart';
import 'package:due_day/features/transactions/presentation/widgets/shared/selection_field_widget.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class TransactionFilterBottomSheet extends StatefulWidget {
  final TransactionType? initialType;
  final String? initialCategoryId;
  final TransactionFrequency? initialFrequency;
  final DateTime? initialStartDate;
  final DateTime? initialEndDate;
  final List<CategoryEntity> categories;

  const TransactionFilterBottomSheet({
    required this.categories,
    super.key,
    this.initialType,
    this.initialCategoryId,
    this.initialFrequency,
    this.initialStartDate,
    this.initialEndDate,
  });

  @override
  State<TransactionFilterBottomSheet> createState() =>
      _TransactionFilterBottomSheetState();
}

class _TransactionFilterBottomSheetState
    extends State<TransactionFilterBottomSheet> {
  TransactionType? _selectedType;
  String? _selectedCategoryId;
  TransactionFrequency? _selectedFrequency;

  DateTime? _startDate;
  DateTime? _endDate;

  @override
  void initState() {
    super.initState();

    _selectedType = widget.initialType;
    _selectedCategoryId = widget.initialCategoryId;
    _selectedFrequency = widget.initialFrequency;
    _startDate = widget.initialStartDate;
    _endDate = widget.initialEndDate;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final spacing = context.spacing;
    final colors = context.colors;
    final typography = context.typography;

    final selectedCategory = widget.categories
        .where((c) => c.id == _selectedCategoryId)
        .firstOrNull;

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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(l10n.filters, style: typography.title.medium),
              TextButton(
                onPressed: () {
                  setState(() {
                    _selectedType = null;
                    _selectedCategoryId = null;
                    _selectedFrequency = null;
                    _startDate = null;
                    _endDate = null;
                  });
                },
                child: Text(l10n.clear),
              ),
            ],
          ),
          SizedBox(height: spacing.medium),

          // Transaction Type Filter
          TransactionSelectionField(
            label: l10n.type,
            value: _selectedType?.getLabel(context) ?? l10n.all,
            icon: Icons.swap_vert_rounded,
            onTap: () async {
              final result = await showModalBottomSheet<TransactionType?>(
                context: context,
                isScrollControlled: true,
                useRootNavigator: true,
                backgroundColor: Colors.transparent,
                builder: (context) =>
                    TypeSelectionBottomSheet(selectedType: _selectedType),
              );
              if (mounted) {
                setState(() => _selectedType = result);
              }
            },
          ),
          SizedBox(height: spacing.medium),

          // Category Filter
          TransactionSelectionField(
            label: l10n.category,
            value: selectedCategory?.name ?? l10n.all,
            icon: Icons.category_outlined,
            onTap: () async {
              final result = await showModalBottomSheet<dynamic>(
                context: context,
                isScrollControlled: true,
                useRootNavigator: true,
                backgroundColor: Colors.transparent,
                builder: (context) => CategorySelectionBottomSheet(
                  selectedCategoryId: _selectedCategoryId,
                  showAllOption: true,
                ),
              );
              if (mounted) {
                if (result == null) {
                  setState(() => _selectedCategoryId = null);
                } else if (result is CategoryEntity) {
                  setState(() => _selectedCategoryId = result.id);
                }
              }
            },
          ),
          SizedBox(height: spacing.medium),

          // Frequency Filter
          TransactionSelectionField(
            label: l10n.frequency,
            value: _selectedFrequency?.getLabel(context) ?? l10n.all,
            icon: Icons.repeat_rounded,
            onTap: () async {
              final result = await showModalBottomSheet<TransactionFrequency?>(
                context: context,
                isScrollControlled: true,
                useRootNavigator: true,
                backgroundColor: Colors.transparent,
                builder: (context) => FrequencySelectionBottomSheet(
                  selectedFrequency: _selectedFrequency,
                ),
              );
              if (mounted) {
                setState(() => _selectedFrequency = result);
              }
            },
          ),
          SizedBox(height: spacing.medium),

          // Date Range Filter
          TransactionSelectionField(
            label: l10n.period,
            value: _getDateRangeLabel(l10n),
            icon: Icons.calendar_today_outlined,
            onTap: () async {
              final result = await showModalBottomSheet<Map<String, dynamic>>(
                context: context,
                isScrollControlled: true,
                useRootNavigator: true,
                backgroundColor: Colors.transparent,
                builder: (context) => DateSelectionBottomSheet(
                  initialStartDate: _startDate,
                  initialEndDate: _endDate,
                ),
              );
              if (mounted && result != null) {
                setState(() {
                  _startDate = result['startDate'];
                  _endDate = result['endDate'];
                });
              }
            },
          ),
          SizedBox(height: spacing.large),

          ElevatedButton(
            onPressed: () {
              Navigator.pop(context, {
                'type': _selectedType,
                'categoryId': _selectedCategoryId,
                'frequency': _selectedFrequency,
                'startDate': _startDate,
                'endDate': _endDate,
              });
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: colors.system.info,
              foregroundColor: Colors.white,
              padding: EdgeInsets.all(spacing.medium),
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            child: Text(
              l10n.apply,
              style: typography.body.medium.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _getDateRangeLabel(dynamic l10n) {
    if (_startDate == null) return l10n.all;

    final df = DateFormat.yMd(context.localeString);

    if (_endDate == null || _endDate == _startDate) {
      return df.format(_startDate!);
    }

    return '${df.format(_startDate!)} - ${df.format(_endDate!)}';
  }
}
