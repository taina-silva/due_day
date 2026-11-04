import 'package:due_day/core/design_system/theme/theme.dart';
import 'package:due_day/core/l10n/app_localizations.dart';
import 'package:due_day/core/utils/extensions/num_extension.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// Month selector (DSH-001): previous / month and year / next, plus the
/// account filter.
class DashboardMonthHeader extends StatelessWidget {
  final DateTime month;
  final String localeStr;
  final List<String> selectedAccountNames;
  final ValueChanged<DateTime> onMonthChanged;
  final VoidCallback onFilterTap;

  const DashboardMonthHeader({
    required this.month,
    required this.localeStr,
    required this.selectedAccountNames,
    required this.onMonthChanged,
    required this.onFilterTap,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final typography = context.typography;
    final spacing = context.spacing;
    final sizes = context.sizes;
    final radius = context.radius;

    final title = toBeginningOfSentenceCase(
      DateFormat.yMMMM(localeStr).format(month),
      localeStr,
    );
    final minTarget = BoxConstraints(
      minWidth: sizes.buttonMedium.scale,
      minHeight: sizes.buttonMedium.scale,
    );

    return Column(
      children: [
        Row(
          children: [
            IconButton(
              constraints: minTarget,
              tooltip: l10n.dashboardPreviousMonth,
              icon: Icon(
                Icons.chevron_left_rounded,
                size: sizes.iconMedium.scale,
              ),
              onPressed: () =>
                  onMonthChanged(DateTime(month.year, month.month - 1)),
            ),
            Expanded(
              child: Semantics(
                header: true,
                child: Text(
                  title,
                  style: typography.title.medium,
                  textAlign: TextAlign.center,
                ),
              ),
            ),
            IconButton(
              constraints: minTarget,
              tooltip: l10n.dashboardNextMonth,
              icon: Icon(
                Icons.chevron_right_rounded,
                size: sizes.iconMedium.scale,
              ),
              onPressed: () =>
                  onMonthChanged(DateTime(month.year, month.month + 1)),
            ),
          ],
        ),
        SizedBox(height: spacing.small.height),
        InkWell(
          onTap: onFilterTap,
          borderRadius: BorderRadius.circular(radius.large),
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: sizes.buttonMedium.scale),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.filter_list_rounded,
                  size: sizes.iconSmall.scale,
                  color: context.onSurfaceVariantColor,
                ),
                SizedBox(width: spacing.small.width),
                Flexible(
                  child: Text(
                    selectedAccountNames.isEmpty
                        ? l10n.transactionsFilterAll
                        : selectedAccountNames.join(', '),
                    style: typography.body.small.copyWith(
                      color: context.onSurfaceVariantColor,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
