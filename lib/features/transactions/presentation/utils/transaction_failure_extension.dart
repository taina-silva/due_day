import 'package:due_day/core/errors/failures.dart';
import 'package:due_day/core/l10n/app_localizations.dart';
import 'package:due_day/features/transactions/domain/errors/transaction_failures.dart';
import 'package:flutter/widgets.dart';

extension TransactionFailureExtension on Failure {
  String toLocalizedString(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    switch (this) {
      case TransactionNotFoundFailure():
        return l10n.transactionsErrorNotFound;
      case UserNotAuthenticatedFailure():
        return l10n.transactionsErrorNotAuthenticated;
      case TransactionSaveFailure():
        return l10n.transactionsErrorSaveFailed;
      case TransactionDeleteFailure():
        return l10n.transactionsErrorDeleteFailed;
      default:
        return l10n.transactionsErrorFallback;
    }
  }
}
