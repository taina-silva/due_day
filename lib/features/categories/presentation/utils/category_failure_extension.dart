import 'package:due_day/core/errors/failures.dart';
import 'package:due_day/core/l10n/app_localizations.dart';
import 'package:due_day/features/categories/domain/errors/category_failures.dart';
import 'package:flutter/widgets.dart';

extension CategoryFailureExtension on Failure {
  String toLocalizedString(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    switch (this) {
      case CategoryNotFoundFailure():
        return l10n.categoriesErrorNotFound;
      case UserNotAuthenticatedFailure():
        return l10n.categoriesErrorNotAuthenticated;
      case CategorySaveFailure():
        return l10n.categoriesErrorSaveFailed;
      case CategoryDeleteFailure():
        return l10n.categoriesErrorDeleteFailed;
      default:
        return l10n.categoriesErrorFallback;
    }
  }
}
