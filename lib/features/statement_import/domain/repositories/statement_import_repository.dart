import 'package:due_day/core/errors/failures.dart';
import 'package:due_day/features/statement_import/domain/entities/parsed_statement_transaction.dart';
import 'package:due_day/features/transactions/domain/entities/transaction_entity.dart';
import 'package:fpdart/fpdart.dart';

abstract class StatementImportRepository {
  /// Pure parsing, no I/O beyond the given content. Detects the format from
  /// the content, never the file name (IMP-003), and delegates to the
  /// matching parser. Unsupported content → `UnsupportedFileFormatFailure`.
  Either<Failure, List<ParsedStatementTransaction>> parseStatement({
    required String content,
  });

  /// Returns which of [externalIds] already exist among the user's
  /// transactions (i.e. were imported before).
  Future<Either<Failure, Set<String>>> findExistingExternalIds(
    Set<String> externalIds,
  );

  /// Persists [transactionsToCreate] in a batch and returns them. Writes
  /// only transactions (and category counters), never accounts (IMP-010).
  Future<Either<Failure, List<TransactionEntity>>> confirmImport({
    required List<TransactionEntity> transactionsToCreate,
  });
}
