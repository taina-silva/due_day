import 'package:due_day/core/errors/failures.dart';
import 'package:due_day/core/l10n/app_localizations.dart';
import 'package:due_day/features/notifications/domain/errors/notification_failures.dart';
import 'package:flutter/widgets.dart';

extension NotificationFailureExtension on Failure {
  String toLocalizedString(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    switch (this) {
      case NotificationSaveFailure():
        return l10n.notificationsErrorSaveFailed;
      case NotificationDeleteFailure():
        return l10n.notificationsErrorDeleteFailed;
      default:
        return l10n.notificationsErrorLoading;
    }
  }
}
