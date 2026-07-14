import 'package:due_day/core/errors/failures.dart';
import 'package:due_day/core/l10n/app_localizations.dart';
import 'package:due_day/features/transactions/domain/errors/transaction_failures.dart';
import 'package:flutter/widgets.dart';

extension TransactionFailureExtension on Failure {
  String toLocalizedString(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    if (this is TransactionNotFoundFailure) {
      return l10n.transactionsErrorNotFound;
    }
    if (this is UserNotAuthenticatedFailure) {
      return l10n.transactionsErrorNotAuthenticated;
    }

    return l10n.transactionsErrorFallback;
  }
}
