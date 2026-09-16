import 'package:due_day/features/statement_import/domain/entities/import_review_item.dart';
import 'package:due_day/features/statement_import/domain/errors/statement_import_failures.dart';
import 'package:due_day/features/statement_import/domain/usecases/confirm_import.dart';
import 'package:due_day/features/transactions/domain/entities/transaction_entity.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';

import '../../helpers/statement_import_test_helpers.dart';

void main() {
  late MockStatementImportRepository mockRepository;
  late ConfirmImport useCase;

  setUpAll(() {
    registerFallbackValue(<TransactionEntity>[]);
  });

  setUp(() {
    mockRepository = MockStatementImportRepository();
    useCase = ConfirmImport(mockRepository);
  });

  final pendingDebit = ImportReviewItem(
    parsed: tParsedDebit,
    status: ImportReviewStatus.pendingNew,
    selectedForImport: true,
    categoryId: 'category-1',
    categoryName: 'Groceries',
  );

  final pendingCredit = ImportReviewItem(
    parsed: tParsedCredit,
    status: ImportReviewStatus.pendingNew,
    selectedForImport: true,
  );

  final deselectedItem = ImportReviewItem(
    parsed: tParsedDebit,
    status: ImportReviewStatus.pendingNew,
    selectedForImport: false,
  );

  final duplicateItem = ImportReviewItem(
    parsed: tParsedCredit,
    status: ImportReviewStatus.alreadyImported,
    selectedForImport: false,
  );

  group('ConfirmImport', () {
    test(
      'filters out deselected and already-imported items before persisting',
      () async {
        when(
          () => mockRepository.confirmImport(
            transactionsToCreate: any(named: 'transactionsToCreate'),
            destinationAccountId: any(named: 'destinationAccountId'),
          ),
        ).thenAnswer((_) async => const Right(<TransactionEntity>[]));

        await useCase(
          reviewItems: [pendingDebit, deselectedItem, duplicateItem],
          userId: 'user-1',
          destinationAccountId: 'acc-import-1',
        );

        final captured = verify(
          () => mockRepository.confirmImport(
            transactionsToCreate: captureAny(named: 'transactionsToCreate'),
            destinationAccountId: 'acc-import-1',
          ),
        ).captured.single as List<TransactionEntity>;

        expect(captured, hasLength(1));
        expect(captured.single.externalId, tParsedDebit.externalId);
      },
    );

    test(
      'maps a negative-amount item to an expense and a positive-amount item to income',
      () async {
        when(
          () => mockRepository.confirmImport(
            transactionsToCreate: any(named: 'transactionsToCreate'),
            destinationAccountId: any(named: 'destinationAccountId'),
          ),
        ).thenAnswer((_) async => const Right(<TransactionEntity>[]));

        await useCase(
          reviewItems: [pendingDebit, pendingCredit],
          userId: 'user-1',
          destinationAccountId: 'acc-import-1',
        );

        final captured = verify(
          () => mockRepository.confirmImport(
            transactionsToCreate: captureAny(named: 'transactionsToCreate'),
            destinationAccountId: 'acc-import-1',
          ),
        ).captured.single as List<TransactionEntity>;

        final expense = captured.firstWhere(
          (t) => t.externalId == tParsedDebit.externalId,
        );
        final income = captured.firstWhere(
          (t) => t.externalId == tParsedCredit.externalId,
        );

        expect(expense.type, TransactionType.expense);
        expect(expense.amount, 19.90);
        expect(expense.accountFrom, 'acc-import-1');
        expect(expense.accountTo, isNull);
        expect(expense.category, 'category-1');
        expect(expense.paid, isTrue);
        expect(expense.importSource, 'ofx');

        expect(income.type, TransactionType.income);
        expect(income.amount, 1000.00);
        expect(income.accountTo, 'acc-import-1');
        expect(income.accountFrom, isNull);
      },
    );

    test(
      'returns an ImportSummary with correct counts on success',
      () async {
        final createdEntity = TransactionEntity(
          id: 'x',
          userId: 'user-1',
          type: TransactionType.expense,
          amount: tParsedDebit.amount.abs(),
          paid: true,
          isRecurring: false,
          createdAt: DateTime(2026, 8, 1),
        );
        when(
          () => mockRepository.confirmImport(
            transactionsToCreate: any(named: 'transactionsToCreate'),
            destinationAccountId: any(named: 'destinationAccountId'),
          ),
        ).thenAnswer((_) async => Right([createdEntity]));

        final result = await useCase(
          reviewItems: [pendingDebit, deselectedItem, duplicateItem],
          userId: 'user-1',
          destinationAccountId: 'acc-import-1',
        );

        result.fold((l) => fail('Should not be left'), (summary) {
          expect(summary.importedCount, 1);
          expect(summary.skippedDuplicateCount, 1);
          expect(summary.skippedByUserCount, 1);
        });
      },
    );

    test('propagates a repository failure', () async {
      when(
        () => mockRepository.confirmImport(
          transactionsToCreate: any(named: 'transactionsToCreate'),
          destinationAccountId: any(named: 'destinationAccountId'),
        ),
      ).thenAnswer((_) async => const Left(ImportPersistFailure()));

      final result = await useCase(
        reviewItems: [pendingDebit],
        userId: 'user-1',
        destinationAccountId: 'acc-import-1',
      );

      expect(result, const Left(ImportPersistFailure()));
    });
  });
}
