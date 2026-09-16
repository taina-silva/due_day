import 'package:due_day/core/errors/failures.dart';

class UnsupportedFileFormatFailure extends Failure {
  const UnsupportedFileFormatFailure([
    super.message = 'Unsupported file format.',
  ]);
}

class StatementParseFailure extends Failure {
  const StatementParseFailure([
    super.message = 'Could not read the statement file.',
  ]);
}

class EmptyStatementFailure extends Failure {
  const EmptyStatementFailure([
    super.message = 'No transactions found in the statement.',
  ]);
}

class ImportPersistFailure extends Failure {
  const ImportPersistFailure([
    super.message = 'Failed to import transactions.',
  ]);
}
