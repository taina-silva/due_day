import 'package:due_day/core/errors/failures.dart';
import 'package:due_day/features/statement_import/domain/entities/import_review_item.dart';
import 'package:due_day/features/statement_import/domain/entities/parsed_statement_transaction.dart';
import 'package:due_day/features/statement_import/domain/repositories/statement_import_repository.dart';
import 'package:fpdart/fpdart.dart';

class BuildReviewList {
  final StatementImportRepository repository;

  BuildReviewList(this.repository);

  Future<Either<Failure, List<ImportReviewItem>>> call(
    List<ParsedStatementTransaction> parsed,
  ) async {
    final ids = parsed.map((p) => p.externalId).toSet();
    final existingResult = await repository.findExistingExternalIds(ids);

    return existingResult.map((existingIds) {
      return parsed.map((p) {
        final isDuplicate = existingIds.contains(p.externalId);
        return ImportReviewItem(
          parsed: p,
          status: isDuplicate
              ? ImportReviewStatus.alreadyImported
              : ImportReviewStatus.pendingNew,
          selectedForImport: !isDuplicate,
        );
      }).toList();
    });
  }
}
