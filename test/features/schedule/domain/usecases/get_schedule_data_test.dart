import 'package:due_day/features/schedule/domain/usecases/get_schedule_data.dart';
import 'package:due_day/features/transactions/domain/entities/transaction_entity.dart';
import 'package:due_day/features/transactions/domain/errors/transaction_failures.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';

import '../../helpers/schedule_test_helpers.dart';

void main() {
  late MockTransactionRepository mockTransactionRepository;
  late GetScheduleData getScheduleData;

  setUp(() {
    mockTransactionRepository = MockTransactionRepository();
    getScheduleData = GetScheduleData(mockTransactionRepository);

    when(
      () => mockTransactionRepository.getTransactions(
        type: TransactionType.expense,
      ),
    ).thenAnswer((_) => Stream.value(Right(tExpenseTransactions)));
    when(
      () => mockTransactionRepository.getTransactions(
        type: TransactionType.income,
      ),
    ).thenAnswer((_) => Stream.value(Right(tIncomeTransactions)));
  });

  test(
    'should query transactions by type and return grouped, filtered schedule data',
    () async {
      // Act
      final resultStream = getScheduleData.execute();

      // Assert
      final result = await resultStream.first;
      expect(result.isRight(), true);

      result.fold((failure) => fail('Should not fail'), (summary) {
        expect(summary.totalAmount, 300.0);
        expect(summary.totalPaid, 200.0);
        expect(summary.totalToPay, 100.0);

        // Sorted by due date: tx-2 (2 days), tx-3 (5 days)
        expect(summary.transactions.length, 2);
        expect(summary.transactions[0].id, 'tx-2');
        expect(summary.transactions[1].id, 'tx-3');

        // Next income is tx-1 (since it is an income and not paid)
        expect(summary.nextIncomeAmount, 1500.0);
        expect(summary.nextIncomeDate, tDateTime.add(const Duration(days: 3)));
      });

      verify(
        () => mockTransactionRepository.getTransactions(
          type: TransactionType.expense,
        ),
      ).called(1);
      verify(
        () => mockTransactionRepository.getTransactions(
          type: TransactionType.income,
        ),
      ).called(1);
    },
  );

  test('should propagate a failure from the expense stream', () async {
    when(
      () => mockTransactionRepository.getTransactions(
        type: TransactionType.expense,
      ),
    ).thenAnswer(
      (_) => Stream.value(
        const Left(TransactionOperationFailure('Expense stream failed')),
      ),
    );

    final result = await getScheduleData.execute().first;

    expect(result.isLeft(), true);
    result.fold(
      (failure) => expect(failure, isA<TransactionOperationFailure>()),
      (_) => fail('Should not succeed'),
    );
  });
}
