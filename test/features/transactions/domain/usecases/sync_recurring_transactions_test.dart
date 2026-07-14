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
    registerFallbackValue(tAccountEntity);
  });

  setUp(() {
    mockTransactionRepository = MockTransactionRepository();
    mockAccountRepository = MockAccountRepository();
    usecase = SyncRecurringTransactions(
      transactionRepository: mockTransactionRepository,
      accountRepository: mockAccountRepository,
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
    'should create a new instance for an overdue recurring template and update balance',
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
      when(
        () => mockAccountRepository.getAccounts(),
      ).thenAnswer((_) => Stream.value(Right([tAccountEntity])));
      when(
        () => mockAccountRepository.updateAccount(any()),
      ).thenAnswer((_) async => Right(tAccountEntity));

      final created = await usecase('user-1');

      expect(created, hasLength(1));
      expect(created.first.parentRecurringId, 'template-1');
      expect(created.first.isRecurring, false);
      verify(() => mockTransactionRepository.addTransaction(any())).called(1);
      verify(
        () => mockAccountRepository.updateAccount(
          any(
            that: predicate<dynamic>(
              (a) => a.balance == tAccountEntity.balance - 30.0,
            ),
          ),
        ),
      ).called(1);
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
