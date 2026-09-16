import 'package:due_day/core/errors/failures.dart';
import 'package:due_day/features/statement_import/domain/entities/import_review_item.dart';
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
        when(() => mockRepository.findExistingExternalIds(any())).thenAnswer(
          (_) async => Right({tParsedDebit.externalId}),
        );

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
  });
}
