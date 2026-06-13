import 'package:due_day/core/l10n/l10n_extension.dart';
import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';

extension DateExtension on DateTime? {
  /// Returns a formatted date range label.
  /// If this date is null, returns the localized 'period' string.
  /// If [endDate] is null or same as this date, returns the formatted single date.
  /// Otherwise, returns the formatted range 'startDate - endDate'.
  String toRangeLabel(BuildContext context, {DateTime? endDate}) {
    final l10n = context.l10n;
    if (this == null) return l10n.period;

    final df = DateFormat.yMd(context.localeString);
    if (endDate == null || endDate == this) {
      return df.format(this!);
    }
    return '${df.format(this!)} - ${df.format(endDate)}';
  }
}
