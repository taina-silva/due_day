import 'package:due_day/core/errors/failures.dart';
import 'package:due_day/core/l10n/app_localizations.dart';
import 'package:flutter/widgets.dart';

extension DashboardFailureExtension on Failure {
  String toLocalizedString(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return l10n.dashboardErrorFallback;
  }
}
