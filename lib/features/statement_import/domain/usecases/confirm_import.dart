import 'package:due_day/core/errors/failures.dart';
import 'package:due_day/features/statement_import/domain/entities/import_review_item.dart';
import 'package:due_day/features/statement_import/domain/entities/import_summary.dart';
import 'package:due_day/features/statement_import/domain/repositories/statement_import_repository.dart';
import 'package:due_day/features/transactions/domain/entities/transaction_entity.dart';
import 'package:fpdart/fpdart.dart';
import 'package:uuid/uuid.dart';

class ConfirmImport {
  final StatementImportRepository repository;

  ConfirmImport(this.repository);

  Future<Either<Failure, ImportSummary>> call({
    required List<ImportReviewItem> reviewItems,
    required String userId,
    required String destinationAccountId,
  }) async {
    final skippedDuplicates = reviewItems
        .where((item) => item.status == ImportReviewStatus.alreadyImported)
        .length;

    final accepted = reviewItems
        .where(
          (item) =>
              item.selectedForImport &&
              item.status != ImportReviewStatus.alreadyImported,
        )
        .toList();

    final skippedByUser =
        reviewItems.length - accepted.length - skippedDuplicates;

    final entities = accepted.map((item) {
      final parsed = item.parsed;
      final isExpense = parsed.amount < 0;

      return TransactionEntity(
        id: const Uuid().v4(),
        userId: userId,
        type: isExpense ? TransactionType.expense : TransactionType.income,
        amount: parsed.amount.abs(),
        category: item.categoryId,
        accountFrom: isExpense ? destinationAccountId : null,
        accountTo: isExpense ? null : destinationAccountId,
        dueDate: parsed.date,
        paidDate: parsed.date,
        paid: true,
        isRecurring: false,
        frequency: TransactionFrequency.none,
        notes: parsed.memo,
        createdAt: DateTime.now(),
        externalId: parsed.externalId,
        importSource: parsed.source.name,
      );
    }).toList();

    final result = await repository.confirmImport(
      transactionsToCreate: entities,
      destinationAccountId: destinationAccountId,
    );

    return result.map(
      (created) => ImportSummary(
        importedCount: created.length,
        skippedDuplicateCount: skippedDuplicates,
        skippedByUserCount: skippedByUser,
      ),
    );
  }
}
