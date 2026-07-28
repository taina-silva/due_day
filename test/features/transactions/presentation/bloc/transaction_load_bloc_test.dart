import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart' as dartz;
import 'package:due_day/core/errors/failures.dart';
import 'package:due_day/core/settings/settings_state.dart';
import 'package:due_day/features/notifications/domain/entities/notification_entity.dart';
import 'package:due_day/features/transactions/domain/entities/transaction_entity.dart';
import 'package:due_day/features/transactions/domain/usecases/classify_transaction_reminders.dart';
import 'package:due_day/features/transactions/presentation/bloc/transaction_load_bloc.dart';
import 'package:due_day/features/transactions/presentation/bloc/transaction_load_event.dart';
import 'package:due_day/features/transactions/presentation/bloc/transaction_load_state.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:mocktail/mocktail.dart';

import '../../helpers/transaction_test_helpers.dart';

void main() {
  late MockGetTransactions mockGetTransactions;
  late MockSettingsBloc mockSettingsBloc;
  late MockNotificationService mockNotificationService;
  late MockAddNotification mockAddNotification;
  late MockClassifyTransactionReminders mockClassifyTransactionReminders;
  late MockSyncRecurringTransactions mockSyncRecurringTransactions;
  late MockGetCurrentUser mockGetCurrentUser;
  late TransactionLoadBloc transactionLoadBloc;

  setUpAll(() async {
    await initializeDateFormatting('en');
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
    mockGetTransactions = MockGetTransactions();
    mockSettingsBloc = MockSettingsBloc();
    mockNotificationService = MockNotificationService();
    mockAddNotification = MockAddNotification();
    mockClassifyTransactionReminders = MockClassifyTransactionReminders();
    mockSyncRecurringTransactions = MockSyncRecurringTransactions();
    mockGetCurrentUser = MockGetCurrentUser();

    when(() => mockNotificationService.cancelAll()).thenAnswer((_) async {});
    when(
      () => mockAddNotification(any()),
    ).thenAnswer((_) async => const dartz.Right(null));
    when(() => mockClassifyTransactionReminders(any())).thenReturn(const []);

    transactionLoadBloc = TransactionLoadBloc(
      getTransactions: mockGetTransactions,
      settingsBloc: mockSettingsBloc,
      notificationService: mockNotificationService,
      addNotification: mockAddNotification,
      classifyTransactionReminders: mockClassifyTransactionReminders,
      syncRecurringTransactions: mockSyncRecurringTransactions,
      getCurrentUser: mockGetCurrentUser,
    );
  });

  tearDown(() {
    transactionLoadBloc.close();
  });

  test('initial state should be TransactionInitial', () {
    expect(transactionLoadBloc.state, equals(TransactionInitial()));
  });

  group('LoadTransactions Event', () {
    blocTest<TransactionLoadBloc, TransactionLoadState>(
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
        return transactionLoadBloc;
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

    blocTest<TransactionLoadBloc, TransactionLoadState>(
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
        return transactionLoadBloc;
      },
      act: (bloc) => bloc.add(const LoadTransactions()),
      expect: () => [
        TransactionLoading(),
        const TransactionError(failure: ServerFailure('Fetch failed')),
      ],
    );

    blocTest<TransactionLoadBloc, TransactionLoadState>(
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
        when(() => mockClassifyTransactionReminders(any())).thenReturn([
          TransactionReminder(
            transaction: overdueTx,
            urgency: ReminderUrgency.overdue,
            notifyAt: overdueTx.dueDate!,
          ),
        ]);
        when(
          () => mockGetTransactions(
            startDate: any(named: 'startDate'),
            endDate: any(named: 'endDate'),
            categoryId: any(named: 'categoryId'),
            type: any(named: 'type'),
            frequency: any(named: 'frequency'),
          ),
        ).thenAnswer((_) => Stream.value(Right([overdueTx])));
        return transactionLoadBloc;
      },
      act: (bloc) => bloc.add(const LoadTransactions()),
      wait: const Duration(milliseconds: 50),
      expect: () => [TransactionLoading(), isA<TransactionLoaded>()],
      verify: (_) {
        verify(() => mockAddNotification(any())).called(1);
      },
    );

    blocTest<TransactionLoadBloc, TransactionLoadState>(
      'should not call cancelAll or addNotification again when the same '
      'transactions are emitted twice in a row',
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
        when(() => mockClassifyTransactionReminders(any())).thenReturn([
          TransactionReminder(
            transaction: overdueTx,
            urgency: ReminderUrgency.overdue,
            notifyAt: overdueTx.dueDate!,
          ),
        ]);
        when(
          () => mockGetTransactions(
            startDate: any(named: 'startDate'),
            endDate: any(named: 'endDate'),
            categoryId: any(named: 'categoryId'),
            type: any(named: 'type'),
            frequency: any(named: 'frequency'),
          ),
        ).thenAnswer(
          (_) => Stream.fromIterable([
            Right([overdueTx]),
            Right([overdueTx]),
          ]),
        );
        return transactionLoadBloc;
      },
      act: (bloc) => bloc.add(const LoadTransactions()),
      wait: const Duration(milliseconds: 50),
      // Bloc only notifies listeners once for the two stream emissions since
      // both TransactionLoaded states are equal (Bloc skips emitting
      // duplicate states) — the real assertion here is that cancelAll/
      // addNotification aren't repeated for the second, identical emission.
      expect: () => [TransactionLoading(), isA<TransactionLoaded>()],
      verify: (_) {
        verify(() => mockNotificationService.cancelAll()).called(1);
        verify(() => mockAddNotification(any())).called(1);
      },
    );
  });

  group('SyncRecurringTransactionsRequested', () {
    blocTest<TransactionLoadBloc, TransactionLoadState>(
      'should call SyncRecurringTransactions when user is authenticated',
      build: () {
        when(
          () => mockGetCurrentUser(),
        ).thenAnswer((_) async => Right(tUserEntity));
        when(
          () => mockSyncRecurringTransactions(any()),
        ).thenAnswer((_) async => <TransactionEntity>[]);
        return transactionLoadBloc;
      },
      act: (bloc) => bloc.add(SyncRecurringTransactionsRequested()),
      expect: () => <TransactionLoadState>[],
      verify: (_) {
        verify(() => mockGetCurrentUser()).called(1);
        verify(() => mockSyncRecurringTransactions('user-1')).called(1);
      },
    );

    blocTest<TransactionLoadBloc, TransactionLoadState>(
      'should not call SyncRecurringTransactions when user is not authenticated',
      build: () {
        when(
          () => mockGetCurrentUser(),
        ).thenAnswer((_) async => const Right(null));
        return transactionLoadBloc;
      },
      act: (bloc) => bloc.add(SyncRecurringTransactionsRequested()),
      expect: () => <TransactionLoadState>[],
      verify: (_) {
        verify(() => mockGetCurrentUser()).called(1);
        verifyNever(() => mockSyncRecurringTransactions(any()));
      },
    );

    blocTest<TransactionLoadBloc, TransactionLoadState>(
      'should notify recurring debited instances when sync creates paid instances',
      build: () {
        when(
          () => mockSettingsBloc.state,
        ).thenReturn(const SettingsState(languageCode: 'en'));
        when(
          () => mockGetCurrentUser(),
        ).thenAnswer((_) async => Right(tUserEntity));
        final debitedInstance = TransactionEntity(
          id: 'recurring-1',
          userId: 'user-1',
          type: TransactionType.expense,
          amount: 30.0,
          paid: true,
          isRecurring: false,
          createdAt: tDateTime,
          notes: 'Subscription',
        );
        when(
          () => mockSyncRecurringTransactions(any()),
        ).thenAnswer((_) async => [debitedInstance]);
        return transactionLoadBloc;
      },
      act: (bloc) => bloc.add(SyncRecurringTransactionsRequested()),
      expect: () => <TransactionLoadState>[],
      verify: (_) {
        verify(() => mockAddNotification(any())).called(1);
      },
    );
  });
}
