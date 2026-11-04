import 'package:due_day/core/errors/failures.dart';
import 'package:due_day/features/categories/domain/entities/category_kind.dart';
import 'package:due_day/features/categories/domain/entities/system_categories.dart';
import 'package:due_day/features/statement_import/domain/entities/import_review_item.dart';
import 'package:due_day/features/statement_import/domain/entities/parsed_statement_transaction.dart';
import 'package:due_day/features/statement_import/domain/entities/statement_format.dart';
import 'package:due_day/features/statement_import/domain/entities/statement_source.dart';
import 'package:due_day/features/statement_import/domain/usecases/build_review_list.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';

import '../../helpers/statement_import_test_helpers.dart';

void main() {
  late MockStatementImportRepository mockRepository;
  late BuildReviewList useCase;

  setUp(() {
    mockRepository = MockStatementImportRepository();
    useCase = BuildReviewList(mockRepository);
  });

  group('BuildReviewList', () {
    test(
      'given no existing externalIds when called then all items are pendingNew and selected',
      () async {
        when(
          () => mockRepository.findExistingExternalIds(any()),
        ).thenAnswer((_) async => const Right(<String>{}));

        final result = await useCase([tParsedDebit, tParsedCredit]);

        result.fold((l) => fail('Should not be left'), (items) {
          expect(items, hasLength(2));
          expect(
            items.every((i) => i.status == ImportReviewStatus.pendingNew),
            isTrue,
          );
          expect(items.every((i) => i.selectedForImport), isTrue);
        });
      },
    );

    test(
      'given an externalId already exists when called then that item is alreadyImported and deselected',
      () async {
        when(
          () => mockRepository.findExistingExternalIds(any()),
        ).thenAnswer((_) async => Right({tParsedDebit.externalId}));

        final result = await useCase([tParsedDebit, tParsedCredit]);

        result.fold((l) => fail('Should not be left'), (items) {
          final duplicate = items.firstWhere(
            (i) => i.parsed.externalId == tParsedDebit.externalId,
          );
          final fresh = items.firstWhere(
            (i) => i.parsed.externalId == tParsedCredit.externalId,
          );

          expect(duplicate.status, ImportReviewStatus.alreadyImported);
          expect(duplicate.selectedForImport, isFalse);
          expect(fresh.status, ImportReviewStatus.pendingNew);
          expect(fresh.selectedForImport, isTrue);
        });
      },
    );

    test(
      'given the repository fails when called then the failure is propagated',
      () async {
        when(
          () => mockRepository.findExistingExternalIds(any()),
        ).thenAnswer((_) async => const Left(ServerFailure()));

        final result = await useCase([tParsedDebit]);

        expect(result, const Left(ServerFailure()));
      },
    );

    test(
      'IMP-008: bill payments arrive in Ignored (checking and card)',
      () async {
        final checkingPayment = ParsedStatementTransaction(
          rawIdentifier: 'id-bill',
          externalId: 'id-bill|-200000',
          date: DateTime(2026, 9, 5),
          amount: -2000,
          memo: 'Pagamento de fatura',
          source: StatementSource.ofx,
          format: StatementFormat.nubankOfx,
          suggestedCategoryKind: CategoryKind.ignored,
        );
        final cardPayment = ParsedStatementTransaction(
          rawIdentifier: 'card-pay',
          externalId: 'card|2026-09-10|Pagamento recebido|-200000|0',
          date: DateTime(2026, 9, 10),
          amount: 2000,
          memo: 'Pagamento recebido',
          source: StatementSource.csv,
          format: StatementFormat.cardBillCsv,
          suggestedCategoryKind: CategoryKind.ignored,
        );
        when(
          () => mockRepository.findExistingExternalIds(any()),
        ).thenAnswer((_) async => const Right(<String>{}));

        final result = await useCase([checkingPayment, cardPayment]);

        final items = result.getOrElse((_) => fail('Should not be left'));
        expect(
          items.map((i) => i.categoryId),
          everyElement(SystemCategories.ignoredId),
        );
      },
    );

    test('IMP-009: a card refund stays uncategorized', () async {
      final refund = ParsedStatementTransaction(
        rawIdentifier: 'card-refund',
        externalId: 'card|2026-09-05|Estorno Loja|-4000|0',
        date: DateTime(2026, 9, 5),
        amount: 40,
        memo: 'Estorno Loja',
        source: StatementSource.csv,
        format: StatementFormat.cardBillCsv,
      );
      when(
        () => mockRepository.findExistingExternalIds(any()),
      ).thenAnswer((_) async => const Right(<String>{}));

      final result = await useCase([refund]);

      expect(
        result.getOrElse((_) => fail('Should not be left')).single.categoryId,
        isNull,
      );
    });
  });
}
