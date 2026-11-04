import 'package:due_day/features/transactions/domain/entities/transaction_entity.dart';
import 'package:due_day/features/transactions/domain/usecases/sync_recurring_transactions.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';

import '../../helpers/transaction_test_helpers.dart';

void main() {
  late MockTransactionRepository mockTransactionRepository;
  late MockAccountRepository mockAccountRepository;
  late SyncRecurringTransactions usecase;

  setUpAll(() {
    registerFallbackValue(tTransactionEntity);
  });

  setUp(() {
    mockTransactionRepository = MockTransactionRepository();
    mockAccountRepository = MockAccountRepository();
    usecase = SyncRecurringTransactions(
      transactionRepository: mockTransactionRepository,
    );
  });

  final overdueTemplate = TransactionEntity(
    id: 'template-1',
    userId: 'user-1',
    type: TransactionType.expense,
    amount: 30.0,
    accountFrom: 'acc-1',
    dueDate: DateTime.now().subtract(const Duration(days: 10)),
    paid: true,
    isRecurring: true,
    frequency: TransactionFrequency.weekly,
    createdAt: DateTime.now().subtract(const Duration(days: 30)),
  );

  test(
    'TRX-004: creates the next instance of an overdue template without touching accounts',
    () async {
      when(
        () => mockTransactionRepository.getTransactions(),
      ).thenAnswer((_) => Stream.value(Right([overdueTemplate])));
      when(() => mockTransactionRepository.addTransaction(any())).thenAnswer((
        invocation,
      ) async {
        final tx = invocation.positionalArguments.first as TransactionEntity;
        return Right(tx);
      });
      final created = await usecase('user-1');

      expect(created, hasLength(1));
      expect(created.first.parentRecurringId, 'template-1');
      expect(created.first.isRecurring, false);
      verify(() => mockTransactionRepository.addTransaction(any())).called(1);
      verifyZeroInteractions(mockAccountRepository);
    },
  );

  test(
    'should not create a new instance when an occurrence already exists for the due date',
    () async {
      final nextDate = overdueTemplate.dueDate!.add(const Duration(days: 7));
      final existingInstance = TransactionEntity(
        id: 'instance-1',
        userId: 'user-1',
        type: TransactionType.expense,
        amount: 30.0,
        accountFrom: 'acc-1',
        dueDate: nextDate,
        paid: true,
        isRecurring: false,
        parentRecurringId: 'template-1',
        createdAt: DateTime.now(),
      );

      when(() => mockTransactionRepository.getTransactions()).thenAnswer(
        (_) => Stream.value(Right([overdueTemplate, existingInstance])),
      );

      final created = await usecase('user-1');

      expect(created, isEmpty);
      verifyNever(() => mockTransactionRepository.addTransaction(any()));
    },
  );

  test('should not create instances for non-recurring templates', () async {
    final nonRecurring = TransactionEntity(
      id: 'tx-1',
      userId: 'user-1',
      type: TransactionType.expense,
      amount: 10.0,
      paid: true,
      isRecurring: false,
      createdAt: DateTime.now(),
    );

    when(
      () => mockTransactionRepository.getTransactions(),
    ).thenAnswer((_) => Stream.value(Right([nonRecurring])));

    final created = await usecase('user-1');

    expect(created, isEmpty);
    verifyNever(() => mockTransactionRepository.addTransaction(any()));
  });
}
