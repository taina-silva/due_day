import 'package:due_day/core/errors/failures.dart';
import 'package:due_day/core/l10n/app_localizations.dart';
import 'package:due_day/features/statement_import/domain/errors/statement_import_failures.dart';
import 'package:flutter/widgets.dart';

extension StatementImportFailureExtension on Failure {
  String toLocalizedString(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    switch (this) {
      case UnsupportedFileFormatFailure():
        return l10n.statementImportErrorUnsupportedFormat;
      case StatementParseFailure():
        return l10n.statementImportErrorParseFailed;
      case EmptyStatementFailure():
        return l10n.statementImportErrorEmpty;
      case ImportPersistFailure():
        return l10n.statementImportErrorPersistFailed;
      default:
        return l10n.statementImportErrorFallback;
    }
  }
}
