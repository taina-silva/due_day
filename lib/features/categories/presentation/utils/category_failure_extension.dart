import 'package:due_day/core/errors/failures.dart';
import 'package:due_day/core/l10n/app_localizations.dart';
import 'package:due_day/features/categories/domain/errors/category_failures.dart';
import 'package:flutter/widgets.dart';

extension CategoryFailureExtension on Failure {
  String toLocalizedString(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    if (this is CategoryNotFoundFailure) {
      return l10n.categoriesErrorNotFound;
    }
    if (this is UserNotAuthenticatedFailure) {
      return l10n.categoriesErrorNotAuthenticated;
    }

    return l10n.categoriesErrorFallback;
  }
}
