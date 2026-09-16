import 'package:due_day/core/errors/failures.dart';
import 'package:due_day/features/statement_import/domain/entities/parsed_statement_transaction.dart';
import 'package:due_day/features/statement_import/domain/repositories/statement_import_repository.dart';
import 'package:fpdart/fpdart.dart';

class ParseStatement {
  final StatementImportRepository repository;

  ParseStatement(this.repository);

  Either<Failure, List<ParsedStatementTransaction>> call({
    required String fileName,
    required String content,
  }) {
    return repository.parseStatement(fileName: fileName, content: content);
  }
}
