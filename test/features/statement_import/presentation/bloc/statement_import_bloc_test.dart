import 'package:bloc_test/bloc_test.dart';
import 'package:due_day/features/statement_import/domain/entities/import_review_item.dart';
import 'package:due_day/features/statement_import/domain/entities/import_summary.dart';
import 'package:due_day/features/statement_import/domain/entities/picked_statement_file.dart';
import 'package:due_day/features/statement_import/domain/errors/statement_import_failures.dart';
import 'package:due_day/features/statement_import/presentation/bloc/statement_import_bloc.dart';
import 'package:due_day/features/statement_import/presentation/bloc/statement_import_event.dart';
import 'package:due_day/features/statement_import/presentation/bloc/statement_import_state.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';

import '../../../transactions/helpers/transaction_test_helpers.dart';
import '../../helpers/statement_import_test_helpers.dart';

void main() {
  late MockPickStatementFile mockPickStatementFile;
  late MockParseStatement mockParseStatement;
  late MockBuildReviewList mockBuildReviewList;
  late MockConfirmImport mockConfirmImport;
  late MockGetCurrentUser mockGetCurrentUser;
  late StatementImportBloc bloc;

  const pickedFile = PickedStatementFile(
    fileName: 'statement.ofx',
    content: 'raw-content',
  );

  final reviewItem = ImportReviewItem(
    parsed: tParsedDebit,
    status: ImportReviewStatus.pendingNew,
    selectedForImport: true,
  );

  setUpAll(() {
    registerFallbackValue(<ImportReviewItem>[]);
  });

  setUp(() {
    mockPickStatementFile = MockPickStatementFile();
    mockParseStatement = MockParseStatement();
    mockBuildReviewList = MockBuildReviewList();
    mockConfirmImport = MockConfirmImport();
    mockGetCurrentUser = MockGetCurrentUser();

    bloc = StatementImportBloc(
      pickStatementFile: mockPickStatementFile,
      parseStatement: mockParseStatement,
      buildReviewList: mockBuildReviewList,
      confirmImport: mockConfirmImport,
      getCurrentUser: mockGetCurrentUser,
    );
  });

  tearDown(() => bloc.close());

  test('initial state is StatementImportInitial', () {
    expect(bloc.state, const StatementImportInitial());
  });

  group('PickFileRequested', () {
    blocTest<StatementImportBloc, StatementImportState>(
      'emits [Picking, Parsing, AwaitingAccount] when pick and parse succeed',
      build: () {
        when(
          () => mockPickStatementFile(),
        ).thenAnswer((_) async => const Right(pickedFile));
        when(
          () => mockParseStatement(fileName: any(named: 'fileName'), content: any(named: 'content')),
        ).thenReturn(Right([tParsedDebit]));
        return bloc;
      },
      act: (bloc) => bloc.add(const PickFileRequested()),
      expect: () => [
        const StatementImportPicking(),
        const StatementImportParsing(),
        StatementImportAwaitingAccount([tParsedDebit]),
      ],
    );

    blocTest<StatementImportBloc, StatementImportState>(
      'emits [Picking, Initial] when the user cancels the file picker',
      build: () {
        when(
          () => mockPickStatementFile(),
        ).thenAnswer((_) async => const Right(null));
        return bloc;
      },
      act: (bloc) => bloc.add(const PickFileRequested()),
      expect: () => [
        const StatementImportPicking(),
        const StatementImportInitial(),
      ],
    );

    blocTest<StatementImportBloc, StatementImportState>(
      'emits [Picking, Error] when the file picker fails',
      build: () {
        when(() => mockPickStatementFile()).thenAnswer(
          (_) async => const Left(StatementParseFailure()),
        );
        return bloc;
      },
      act: (bloc) => bloc.add(const PickFileRequested()),
      expect: () => [
        const StatementImportPicking(),
        const StatementImportError(StatementParseFailure()),
      ],
    );

    blocTest<StatementImportBloc, StatementImportState>(
      'emits [Picking, Parsing, Error] when parsing fails',
      build: () {
        when(
          () => mockPickStatementFile(),
        ).thenAnswer((_) async => const Right(pickedFile));
        when(
          () => mockParseStatement(fileName: any(named: 'fileName'), content: any(named: 'content')),
        ).thenReturn(const Left(EmptyStatementFailure()));
        return bloc;
      },
      act: (bloc) => bloc.add(const PickFileRequested()),
      expect: () => [
        const StatementImportPicking(),
        const StatementImportParsing(),
        const StatementImportError(EmptyStatementFailure()),
      ],
    );
  });

  group('AccountSelected', () {
    blocTest<StatementImportBloc, StatementImportState>(
      'emits [Parsing, Reviewing] when dedup succeeds, after a file was already parsed',
      build: () {
        when(
          () => mockPickStatementFile(),
        ).thenAnswer((_) async => const Right(pickedFile));
        when(
          () => mockParseStatement(fileName: any(named: 'fileName'), content: any(named: 'content')),
        ).thenReturn(Right([tParsedDebit]));
        when(
          () => mockBuildReviewList(any()),
        ).thenAnswer((_) async => Right([reviewItem]));
        return bloc;
      },
      act: (bloc) async {
        bloc.add(const PickFileRequested());
        await Future.delayed(Duration.zero);
        bloc.add(AccountSelected(tImportAccountEntity));
      },
      skip: 3, // Picking, Parsing, AwaitingAccount from the pick step above
      expect: () => [
        const StatementImportParsing(),
        StatementImportReviewing(
          account: tImportAccountEntity,
          items: [reviewItem],
        ),
      ],
    );
  });

  group('ItemSelectionToggled', () {
    blocTest<StatementImportBloc, StatementImportState>(
      'flips selectedForImport for the targeted item only',
      build: () => bloc,
      seed: () => StatementImportReviewing(
        account: tImportAccountEntity,
        items: [reviewItem],
      ),
      act: (bloc) => bloc.add(const ItemSelectionToggled(0)),
      expect: () => [
        StatementImportReviewing(
          account: tImportAccountEntity,
          items: [reviewItem.copyWith(selectedForImport: false)],
        ),
      ],
    );
  });

  group('ItemCategoryAssigned', () {
    blocTest<StatementImportBloc, StatementImportState>(
      'sets categoryId and categoryName for the targeted item only',
      build: () => bloc,
      seed: () => StatementImportReviewing(
        account: tImportAccountEntity,
        items: [reviewItem],
      ),
      act: (bloc) => bloc.add(ItemCategoryAssigned(0, tCategoryExpense)),
      expect: () => [
        StatementImportReviewing(
          account: tImportAccountEntity,
          items: [
            ImportReviewItem(
              parsed: reviewItem.parsed,
              status: reviewItem.status,
              selectedForImport: reviewItem.selectedForImport,
              categoryId: tCategoryExpense.id,
              categoryName: tCategoryExpense.name,
            ),
          ],
        ),
      ],
    );
  });

  group('ConfirmImportRequested', () {
    blocTest<StatementImportBloc, StatementImportState>(
      'emits [Confirming, Success] when the current user is resolved and confirm succeeds',
      build: () {
        when(
          () => mockGetCurrentUser(),
        ).thenAnswer((_) async => Right(tUserEntity));
        when(
          () => mockConfirmImport(
            reviewItems: any(named: 'reviewItems'),
            userId: any(named: 'userId'),
            destinationAccountId: any(named: 'destinationAccountId'),
          ),
        ).thenAnswer(
          (_) async => const Right(
            ImportSummary(
              importedCount: 1,
              skippedDuplicateCount: 0,
              skippedByUserCount: 0,
            ),
          ),
        );
        return bloc;
      },
      seed: () => StatementImportReviewing(
        account: tImportAccountEntity,
        items: [reviewItem],
      ),
      act: (bloc) => bloc.add(const ConfirmImportRequested()),
      expect: () => [
        StatementImportConfirming(
          account: tImportAccountEntity,
          items: [reviewItem],
        ),
        const StatementImportSuccess(
          ImportSummary(
            importedCount: 1,
            skippedDuplicateCount: 0,
            skippedByUserCount: 0,
          ),
        ),
      ],
      verify: (_) {
        verify(
          () => mockConfirmImport(
            reviewItems: [reviewItem],
            userId: tUserEntity.uid,
            destinationAccountId: tImportAccountEntity.id,
          ),
        ).called(1);
      },
    );

    blocTest<StatementImportBloc, StatementImportState>(
      'emits [Confirming, Error] when there is no current user',
      build: () {
        when(
          () => mockGetCurrentUser(),
        ).thenAnswer((_) async => const Right(null));
        return bloc;
      },
      seed: () => StatementImportReviewing(
        account: tImportAccountEntity,
        items: [reviewItem],
      ),
      act: (bloc) => bloc.add(const ConfirmImportRequested()),
      expect: () => [
        StatementImportConfirming(
          account: tImportAccountEntity,
          items: [reviewItem],
        ),
        const StatementImportError(ImportPersistFailure()),
      ],
      verify: (_) {
        verifyNever(
          () => mockConfirmImport(
            reviewItems: any(named: 'reviewItems'),
            userId: any(named: 'userId'),
            destinationAccountId: any(named: 'destinationAccountId'),
          ),
        );
      },
    );

    blocTest<StatementImportBloc, StatementImportState>(
      'emits [Confirming, Error] when confirmImport fails',
      build: () {
        when(
          () => mockGetCurrentUser(),
        ).thenAnswer((_) async => Right(tUserEntity));
        when(
          () => mockConfirmImport(
            reviewItems: any(named: 'reviewItems'),
            userId: any(named: 'userId'),
            destinationAccountId: any(named: 'destinationAccountId'),
          ),
        ).thenAnswer((_) async => const Left(ImportPersistFailure()));
        return bloc;
      },
      seed: () => StatementImportReviewing(
        account: tImportAccountEntity,
        items: [reviewItem],
      ),
      act: (bloc) => bloc.add(const ConfirmImportRequested()),
      expect: () => [
        StatementImportConfirming(
          account: tImportAccountEntity,
          items: [reviewItem],
        ),
        const StatementImportError(ImportPersistFailure()),
      ],
    );
  });
}
