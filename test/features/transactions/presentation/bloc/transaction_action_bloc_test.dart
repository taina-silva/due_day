import 'package:bloc_test/bloc_test.dart';
import 'package:due_day/features/transactions/domain/errors/transaction_failures.dart';
import 'package:due_day/features/transactions/presentation/bloc/transaction_action_bloc.dart';
import 'package:due_day/features/transactions/presentation/bloc/transaction_action_event.dart';
import 'package:due_day/features/transactions/presentation/bloc/transaction_action_state.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';

import '../../helpers/transaction_test_helpers.dart';

void main() {
  late MockAddTransaction mockAddTransaction;
  late MockUpdateTransaction mockUpdateTransaction;
  late MockDeleteTransaction mockDeleteTransaction;
  late TransactionActionBloc transactionActionBloc;

  setUpAll(() {
    registerFallbackValue(tTransactionEntity);
  });

  setUp(() {
    mockAddTransaction = MockAddTransaction();
    mockUpdateTransaction = MockUpdateTransaction();
    mockDeleteTransaction = MockDeleteTransaction();

    transactionActionBloc = TransactionActionBloc(
      addTransaction: mockAddTransaction,
      updateTransaction: mockUpdateTransaction,
      deleteTransaction: mockDeleteTransaction,
    );
  });

  tearDown(() {
    transactionActionBloc.close();
  });

  test('initial state should be TransactionActionInitial', () {
    expect(transactionActionBloc.state, equals(TransactionActionInitial()));
  });

  group('AddTransactionEvent', () {
    blocTest<TransactionActionBloc, TransactionActionState>(
      'should emit [TransactionActionInProgress, TransactionActionSuccess] '
      'when AddTransaction succeeds',
      build: () {
        when(
          () => mockAddTransaction(any()),
        ).thenAnswer((_) async => Right(tTransactionEntity));
        return transactionActionBloc;
      },
      act: (bloc) => bloc.add(AddTransactionEvent(tTransactionEntity)),
      expect: () => [TransactionActionInProgress(), TransactionActionSuccess()],
      verify: (_) {
        verify(() => mockAddTransaction(tTransactionEntity)).called(1);
      },
    );

    blocTest<TransactionActionBloc, TransactionActionState>(
      'should emit [TransactionActionInProgress, TransactionActionError] '
      'when AddTransaction fails',
      build: () {
        when(() => mockAddTransaction(any())).thenAnswer(
          (_) async => const Left(TransactionSaveFailure('Add failed')),
        );
        return transactionActionBloc;
      },
      act: (bloc) => bloc.add(AddTransactionEvent(tTransactionEntity)),
      expect: () => [
        TransactionActionInProgress(),
        const TransactionActionError(
          failure: TransactionSaveFailure('Add failed'),
        ),
      ],
    );
  });

  group('UpdateTransactionEvent', () {
    blocTest<TransactionActionBloc, TransactionActionState>(
      'should emit [TransactionActionInProgress, TransactionActionSuccess] '
      'when UpdateTransaction succeeds',
      build: () {
        when(
          () => mockUpdateTransaction(any()),
        ).thenAnswer((_) async => Right(tTransactionEntity));
        return transactionActionBloc;
      },
      act: (bloc) => bloc.add(UpdateTransactionEvent(tTransactionEntity)),
      expect: () => [TransactionActionInProgress(), TransactionActionSuccess()],
      verify: (_) {
        verify(() => mockUpdateTransaction(tTransactionEntity)).called(1);
      },
    );

    blocTest<TransactionActionBloc, TransactionActionState>(
      'should emit [TransactionActionInProgress, TransactionActionError] '
      'when UpdateTransaction fails',
      build: () {
        when(() => mockUpdateTransaction(any())).thenAnswer(
          (_) async => const Left(TransactionSaveFailure('Update failed')),
        );
        return transactionActionBloc;
      },
      act: (bloc) => bloc.add(UpdateTransactionEvent(tTransactionEntity)),
      expect: () => [
        TransactionActionInProgress(),
        const TransactionActionError(
          failure: TransactionSaveFailure('Update failed'),
        ),
      ],
    );
  });

  group('DeleteTransactionEvent', () {
    blocTest<TransactionActionBloc, TransactionActionState>(
      'should emit [TransactionActionInProgress, TransactionActionSuccess] '
      'when DeleteTransaction succeeds',
      build: () {
        when(
          () => mockDeleteTransaction(any()),
        ).thenAnswer((_) async => const Right(null));
        return transactionActionBloc;
      },
      act: (bloc) => bloc.add(const DeleteTransactionEvent('transaction-1')),
      expect: () => [TransactionActionInProgress(), TransactionActionSuccess()],
      verify: (_) {
        verify(() => mockDeleteTransaction('transaction-1')).called(1);
      },
    );

    blocTest<TransactionActionBloc, TransactionActionState>(
      'should emit [TransactionActionInProgress, TransactionActionError] '
      'when DeleteTransaction fails',
      build: () {
        when(() => mockDeleteTransaction(any())).thenAnswer(
          (_) async => const Left(TransactionDeleteFailure('Delete failed')),
        );
        return transactionActionBloc;
      },
      act: (bloc) => bloc.add(const DeleteTransactionEvent('transaction-1')),
      expect: () => [
        TransactionActionInProgress(),
        const TransactionActionError(
          failure: TransactionDeleteFailure('Delete failed'),
        ),
      ],
    );
  });
}
