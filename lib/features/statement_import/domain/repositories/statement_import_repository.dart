import 'package:due_day/core/errors/failures.dart';
import 'package:due_day/features/statement_import/domain/entities/parsed_statement_transaction.dart';
import 'package:due_day/features/transactions/domain/entities/transaction_entity.dart';
import 'package:fpdart/fpdart.dart';

abstract class StatementImportRepository {
  /// Pure parsing, no I/O beyond the given content. Detects format from
  /// [fileName]'s extension and delegates to the OFX or CSV parser.
  Either<Failure, List<ParsedStatementTransaction>> parseStatement({
    required String fileName,
    required String content,
  });

  /// Returns which of [externalIds] already exist among the user's
  /// transactions (i.e. were imported before).
  Future<Either<Failure, Set<String>>> findExistingExternalIds(
    Set<String> externalIds,
  );

  /// Persists [transactionsToCreate] and updates [destinationAccountId]'s
  /// balance by the net delta of the batch. Returns the created entities.
  Future<Either<Failure, List<TransactionEntity>>> confirmImport({
    required List<TransactionEntity> transactionsToCreate,
    required String destinationAccountId,
  });
}
