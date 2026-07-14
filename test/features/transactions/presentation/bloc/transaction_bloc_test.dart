import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart' as dartz;
import 'package:due_day/core/errors/failures.dart';
import 'package:due_day/core/settings/settings_state.dart';
import 'package:due_day/features/notifications/domain/entities/notification_entity.dart';
import 'package:due_day/features/transactions/domain/entities/transaction_entity.dart';
import 'package:due_day/features/transactions/domain/errors/transaction_failures.dart';
import 'package:due_day/features/transactions/presentation/bloc/transaction_bloc.dart';
import 'package:due_day/features/transactions/presentation/bloc/transaction_event.dart';
import 'package:due_day/features/transactions/presentation/bloc/transaction_state.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:mocktail/mocktail.dart';

import '../../helpers/transaction_test_helpers.dart';

void main() {
  late MockAddTransaction mockAddTransaction;
  late MockUpdateTransaction mockUpdateTransaction;
  late MockDeleteTransaction mockDeleteTransaction;
  late MockGetTransactions mockGetTransactions;
  late MockSettingsBloc mockSettingsBloc;
  late MockNotificationService mockNotificationService;
  late MockAddNotification mockAddNotification;
  late TransactionBloc transactionBloc;

  setUpAll(() async {
    await initializeDateFormatting('en');
    registerFallbackValue(tTransactionEntity);
    registerFallbackValue(
      NotificationEntity(
        id: 'fallback',
        userId: 'user-1',
        title: 'fallback',
        description: 'fallback',
        timestamp: tDateTime,
        read: false,
        isUrgent: false,
        type: NotificationType.dueToday,
      ),
    );
  });

  setUp(() {
    mockAddTransaction = MockAddTransaction();
    mockUpdateTransaction = MockUpdateTransaction();
    mockDeleteTransaction = MockDeleteTransaction();
    mockGetTransactions = MockGetTransactions();
    mockSettingsBloc = MockSettingsBloc();
    mockNotificationService = MockNotificationService();
    mockAddNotification = MockAddNotification();

    when(() => mockNotificationService.cancelAll()).thenAnswer((_) async {});
    when(
      () => mockAddNotification(any()),
    ).thenAnswer((_) async => const dartz.Right(null));

    transactionBloc = TransactionBloc(
      addTransaction: mockAddTransaction,
      updateTransaction: mockUpdateTransaction,
      deleteTransaction: mockDeleteTransaction,
      getTransactions: mockGetTransactions,
      settingsBloc: mockSettingsBloc,
      notificationService: mockNotificationService,
      addNotification: mockAddNotification,
    );
  });

  tearDown(() {
    transactionBloc.close();
  });

  test('initial state should be TransactionInitial', () {
    expect(transactionBloc.state, equals(TransactionInitial()));
  });

  group('LoadTransactions Event', () {
    blocTest<TransactionBloc, TransactionState>(
      'should emit [TransactionLoading, TransactionLoaded] on success '
      'when push notifications are disabled',
      build: () {
        when(
          () => mockSettingsBloc.state,
        ).thenReturn(const SettingsState(pushNotificationsEnabled: false));
        when(
          () => mockGetTransactions(
            startDate: any(named: 'startDate'),
            endDate: any(named: 'endDate'),
            categoryId: any(named: 'categoryId'),
            type: any(named: 'type'),
            frequency: any(named: 'frequency'),
          ),
        ).thenAnswer((_) => Stream.value(Right([tTransactionEntity])));
        return transactionBloc;
      },
      act: (bloc) => bloc.add(const LoadTransactions()),
      expect: () => [
        TransactionLoading(),
        TransactionLoaded(transactions: [tTransactionEntity]),
      ],
      verify: (_) {
        verify(() => mockNotificationService.cancelAll()).called(1);
        verifyNever(() => mockAddNotification(any()));
      },
    );

    blocTest<TransactionBloc, TransactionState>(
      'should emit [TransactionLoading, TransactionError] on stream failure',
      build: () {
        when(
          () => mockSettingsBloc.state,
        ).thenReturn(const SettingsState(pushNotificationsEnabled: false));
        when(
          () => mockGetTransactions(
            startDate: any(named: 'startDate'),
            endDate: any(named: 'endDate'),
            categoryId: any(named: 'categoryId'),
            type: any(named: 'type'),
            frequency: any(named: 'frequency'),
          ),
        ).thenAnswer(
          (_) => Stream.value(const Left(ServerFailure('Fetch failed'))),
        );
        return transactionBloc;
      },
      act: (bloc) => bloc.add(const LoadTransactions()),
      expect: () => [
        TransactionLoading(),
        const TransactionError(failure: ServerFailure('Fetch failed')),
      ],
    );

    blocTest<TransactionBloc, TransactionState>(
      'should schedule an overdue notification when push notifications are enabled',
      build: () {
        when(() => mockSettingsBloc.state).thenReturn(
          const SettingsState(
            pushNotificationsEnabled: true,
            languageCode: 'en',
          ),
        );
        final overdueTx = TransactionEntity(
          id: 'overdue-1',
          userId: 'user-1',
          type: TransactionType.expense,
          amount: 30.0,
          dueDate: DateTime.now().subtract(const Duration(days: 2)),
          paid: false,
          isRecurring: false,
          createdAt: tDateTime,
        );
        when(
          () => mockGetTransactions(
            startDate: any(named: 'startDate'),
            endDate: any(named: 'endDate'),
            categoryId: any(named: 'categoryId'),
            type: any(named: 'type'),
            frequency: any(named: 'frequency'),
          ),
        ).thenAnswer((_) => Stream.value(Right([overdueTx])));
        return transactionBloc;
      },
      act: (bloc) => bloc.add(const LoadTransactions()),
      wait: const Duration(milliseconds: 50),
      expect: () => [TransactionLoading(), isA<TransactionLoaded>()],
      verify: (_) {
        verify(() => mockAddNotification(any())).called(1);
      },
    );
  });

  group('AddTransactionEvent', () {
    blocTest<TransactionBloc, TransactionState>(
      'should call AddTransaction usecase and emit nothing on success',
      build: () {
        when(
          () => mockAddTransaction(any()),
        ).thenAnswer((_) async => Right(tTransactionEntity));
        return transactionBloc;
      },
      act: (bloc) => bloc.add(AddTransactionEvent(tTransactionEntity)),
      expect: () => <TransactionState>[],
      verify: (_) {
        verify(() => mockAddTransaction(tTransactionEntity)).called(1);
      },
    );

    blocTest<TransactionBloc, TransactionState>(
      'should emit TransactionError when AddTransaction fails',
      build: () {
        when(
          () => mockAddTransaction(any()),
        ).thenAnswer((_) async => const Left(TransactionOperationFailure()));
        return transactionBloc;
      },
      act: (bloc) => bloc.add(AddTransactionEvent(tTransactionEntity)),
      expect: () => [
        const TransactionError(failure: TransactionOperationFailure()),
      ],
    );
  });

  group('DeleteTransactionEvent', () {
    blocTest<TransactionBloc, TransactionState>(
      'should call DeleteTransaction usecase and emit nothing on success',
      build: () {
        when(
          () => mockDeleteTransaction(any()),
        ).thenAnswer((_) async => const Right(null));
        return transactionBloc;
      },
      act: (bloc) => bloc.add(const DeleteTransactionEvent('transaction-1')),
      expect: () => <TransactionState>[],
      verify: (_) {
        verify(() => mockDeleteTransaction('transaction-1')).called(1);
      },
    );
  });
}
