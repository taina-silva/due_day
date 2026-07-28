import 'package:due_day/core/errors/failures.dart';
import 'package:due_day/core/l10n/app_localizations.dart';
import 'package:due_day/features/transactions/domain/errors/transaction_failures.dart';
import 'package:flutter/widgets.dart';

enum ScheduleFailureContext { load, action }

extension ScheduleFailureExtension on Failure {
  String toLocalizedString(
    BuildContext context, {
    ScheduleFailureContext failureContext = ScheduleFailureContext.load,
  }) {
    final l10n = AppLocalizations.of(context);

    switch (this) {
      case UserNotAuthenticatedFailure():
        return l10n.scheduleErrorNotAuthenticated;
      default:
        return failureContext == ScheduleFailureContext.action
            ? l10n.scheduleActionErrorFallback
            : l10n.scheduleErrorFallback;
    }
  }
}
