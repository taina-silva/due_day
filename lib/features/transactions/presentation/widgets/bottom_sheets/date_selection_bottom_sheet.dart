import 'package:due_day/core/design_system/theme/theme.dart';
import 'package:due_day/core/l10n/l10n_extension.dart';
import 'package:due_day/core/utils/extensions/num_extension.dart';
import 'package:due_day/features/transactions/presentation/widgets/shared/selection_field_widget.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class DateSelectionBottomSheet extends StatefulWidget {
  final DateTime? initialStartDate;
  final DateTime? initialEndDate;

  const DateSelectionBottomSheet({
    super.key,
    this.initialStartDate,
    this.initialEndDate,
  });

  @override
  State<DateSelectionBottomSheet> createState() =>
      _DateSelectionBottomSheetState();
}

class _DateSelectionBottomSheetState extends State<DateSelectionBottomSheet> {
  DateTime? _startDate;
  DateTime? _endDate;

  @override
  void initState() {
    super.initState();
    _startDate = widget.initialStartDate;
    _endDate = widget.initialEndDate;
  }

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
            l10n.period,
            style: typography.title.medium,
            textAlign: TextAlign.center,
          ),
          SizedBox(height: spacing.medium.height),

          // Shortcuts
          Wrap(
            spacing: spacing.small.width,
            runSpacing: spacing.small.height,
            alignment: WrapAlignment.center,
            children: [
              _DateShortcutChip(
                label: l10n.all,
                isSelected: _startDate == null,
                onTap: () => _setRange(null, null),
              ),
              _DateShortcutChip(
                label: l10n.dateToday,
                isSelected: _isToday(_startDate, _endDate),
                onTap: () {
                  final today = DateTime.now();
                  _setRange(
                    DateTime(today.year, today.month, today.day),
                    DateTime(today.year, today.month, today.day),
                  );
                },
              ),
              _DateShortcutChip(
                label: l10n.dateThisWeek,
                isSelected: _isThisWeek(_startDate, _endDate),
                onTap: () {
                  final now = DateTime.now();
                  final startOfWeek = now.subtract(
                    Duration(days: now.weekday - 1),
                  );
                  final endOfWeek = startOfWeek.add(const Duration(days: 6));
                  _setRange(
                    DateTime(
                      startOfWeek.year,
                      startOfWeek.month,
                      startOfWeek.day,
                    ),
                    DateTime(endOfWeek.year, endOfWeek.month, endOfWeek.day),
                  );
                },
              ),
              _DateShortcutChip(
                label: l10n.dateThisMonth,
                isSelected: _isThisMonth(_startDate, _endDate),
                onTap: () {
                  final now = DateTime.now();
                  _setRange(
                    DateTime(now.year, now.month, 1),
                    DateTime(now.year, now.month + 1, 0),
                  );
                },
              ),
              _DateShortcutChip(
                label: l10n.dateLastMonth,
                isSelected: _isLastMonth(_startDate, _endDate),
                onTap: () {
                  final now = DateTime.now();
                  _setRange(
                    DateTime(now.year, now.month - 1, 1),
                    DateTime(now.year, now.month, 0),
                  );
                },
              ),
            ],
          ),
          SizedBox(height: spacing.large.height),

          // Custom Range Picker Field
          TransactionSelectionField(
            label: l10n.dateCustom,
            value: _getDateRangeLabel(l10n),
            icon: Icons.calendar_today_outlined,
            onTap: () async {
              final result = await showDateRangePicker(
                context: context,
                firstDate: DateTime(2020),
                lastDate: DateTime(2100),
                initialDateRange: _startDate != null && _endDate != null
                    ? DateTimeRange(start: _startDate!, end: _endDate!)
                    : null,
                builder: (context, child) {
                  return Theme(
                    data: Theme.of(context).copyWith(
                      colorScheme: ColorScheme.light(
                        primary: colors.system.info,
                        onPrimary: colors.onDarkBackground,
                        surface: colors.lightSurface,
                        onSurface: colors.onLightBackground,
                      ),
                    ),
                    child: child!,
                  );
                },
              );
              if (result != null) {
                _setRange(result.start, result.end);
              }
            },
          ),
          SizedBox(height: spacing.large.height),

          ElevatedButton(
            onPressed: () {
              Navigator.pop(context, {
                'startDate': _startDate,
                'endDate': _endDate,
              });
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: colors.system.info,
              foregroundColor: colors.onDarkBackground,
              padding: EdgeInsets.all(spacing.medium.scale),
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(radius.large),
              ),
            ),
            child: Text(
              l10n.apply,
              style: typography.body.medium.copyWith(
                fontWeight: FontWeight.bold,
                color: colors.onDarkBackground,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _setRange(DateTime? start, DateTime? end) {
    setState(() {
      _startDate = start;
      _endDate = end;
    });
  }

  String _getDateRangeLabel(dynamic l10n) {
    if (_startDate == null) return l10n.all;
    final df = DateFormat.yMd(context.localeString);
    if (_endDate == null || _endDate == _startDate) {
      return df.format(_startDate!);
    }
    return '${df.format(_startDate!)} - ${df.format(_endDate!)}';
  }

  bool _isSameDay(DateTime? date1, DateTime? date2) {
    if (date1 == null || date2 == null) return false;
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }

  bool _isToday(DateTime? start, DateTime? end) {
    final today = DateTime.now();
    final todayStart = DateTime(today.year, today.month, today.day);
    return _isSameDay(start, todayStart) && _isSameDay(end, todayStart);
  }

  bool _isThisWeek(DateTime? start, DateTime? end) {
    if (start == null || end == null) return false;
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    final endOfWeek = startOfWeek.add(const Duration(days: 6));
    return _isSameDay(
          start,
          DateTime(startOfWeek.year, startOfWeek.month, startOfWeek.day),
        ) &&
        _isSameDay(
          end,
          DateTime(endOfWeek.year, endOfWeek.month, endOfWeek.day),
        );
  }

  bool _isThisMonth(DateTime? start, DateTime? end) {
    if (start == null || end == null) return false;
    final now = DateTime.now();
    final firstDay = DateTime(now.year, now.month, 1);
    final lastDay = DateTime(now.year, now.month + 1, 0);
    return _isSameDay(start, firstDay) && _isSameDay(end, lastDay);
  }

  bool _isLastMonth(DateTime? start, DateTime? end) {
    if (start == null || end == null) return false;
    final now = DateTime.now();
    final firstDay = DateTime(now.year, now.month - 1, 1);
    final lastDay = DateTime(now.year, now.month, 0);
    return _isSameDay(start, firstDay) && _isSameDay(end, lastDay);
  }
}

class _DateShortcutChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _DateShortcutChip({
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
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(
          horizontal: spacing.medium.width,
          vertical: spacing.small.height,
        ),
        decoration: BoxDecoration(
          color: isSelected
              ? colors.system.info.withValues(alpha: 0.1)
              : colors.lightSurface,
          borderRadius: BorderRadius.circular(radius.medium),
          border: Border.all(
            color: isSelected ? colors.system.info : colors.resource.neutral,
            width: stroke.medium,
          ),
        ),
        child: Text(
          label,
          style: typography.body.small.copyWith(
            color: isSelected ? colors.system.info : colors.resource.secondary,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}
