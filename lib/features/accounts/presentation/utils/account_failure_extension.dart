import 'package:due_day/core/errors/failures.dart';
import 'package:due_day/core/l10n/app_localizations.dart';
import 'package:due_day/features/accounts/domain/errors/account_failures.dart';
import 'package:flutter/widgets.dart';

extension AccountFailureExtension on Failure {
  String toLocalizedString(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    if (this is AccountNotFoundFailure) {
      return l10n.accountsErrorNotFound;
    }
    if (this is UserNotAuthenticatedFailure) {
      return l10n.accountsErrorNotAuthenticated;
    }

    return l10n.accountsErrorFallback;
  }
}
