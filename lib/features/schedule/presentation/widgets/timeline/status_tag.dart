import 'package:due_day/core/design_system/theme/theme.dart';
import 'package:due_day/core/l10n/l10n_extension.dart';
import 'package:due_day/core/utils/extensions/num_extension.dart';
import 'package:flutter/material.dart';

enum ScheduleStatus {
  overdue,
  dueSoon,
  paid,
  scheduled;

  String getLabel(BuildContext context) {
    final l10n = context.l10n;
    return switch (this) {
      ScheduleStatus.overdue => l10n.scheduleStatusOverdue,
      ScheduleStatus.dueSoon => l10n.scheduleStatusDueSoon,
      ScheduleStatus.paid => l10n.scheduleStatusPaid,
      ScheduleStatus.scheduled => l10n.scheduleStatusScheduled,
    };
  }
}

class StatusTag extends StatelessWidget {
  final ScheduleStatus status;

  const StatusTag({required this.status, super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final typography = context.typography;
    final radius = context.radius;

    Color containerColor;
    Color textColor;

    switch (status) {
      case ScheduleStatus.overdue:
        containerColor = colors.system.error.withValues(alpha: 0.1);
        textColor = colors.system.error;
        break;
      case ScheduleStatus.dueSoon:
        containerColor = colors.system.warning.withValues(alpha: 0.1);
        textColor = colors.system.warning;
        break;
      case ScheduleStatus.paid:
        containerColor = colors.resource.secondary.withValues(alpha: 0.1);
        textColor = colors.resource.secondary;
        break;
      case ScheduleStatus.scheduled:
        containerColor = Colors.transparent;
        textColor = colors.resource.secondary.withValues(alpha: 0.5);
        break;
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.width, vertical: 2.height),
      decoration: BoxDecoration(
        color: containerColor,
        borderRadius: BorderRadius.circular(radius.circle),
      ),
      child: Text(
        status.getLabel(context).toUpperCase(),
        style: typography.label.small.copyWith(
          color: textColor,
          fontWeight: FontWeight.bold,
          fontSize: 10.width,
        ),
      ),
    );
  }
}
