import 'package:due_day/core/errors/failures.dart';
import 'package:due_day/features/categories/domain/entities/category_kind.dart';
import 'package:due_day/features/categories/domain/entities/system_categories.dart';
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
          // Bill payments arrive as *Ignored* (IMP-008); everything else,
          // including card refunds, stays uncategorized (IMP-009).
          categoryId: p.suggestedCategoryKind == CategoryKind.ignored
              ? SystemCategories.ignoredId
              : null,
        );
      }).toList();
    });
  }
}
