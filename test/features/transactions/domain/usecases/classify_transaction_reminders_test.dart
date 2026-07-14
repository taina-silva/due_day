import 'package:due_day/features/transactions/domain/entities/transaction_entity.dart';
import 'package:due_day/features/transactions/domain/usecases/classify_transaction_reminders.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final usecase = ClassifyTransactionReminders();
  final now = DateTime(2026, 7, 14, 10, 0);

  TransactionEntity buildTransaction({
    String id = 'transaction-1',
    DateTime? dueDate,
    bool paid = false,
    TransactionType type = TransactionType.expense,
  }) {
    return TransactionEntity(
      id: id,
      userId: 'user-1',
      type: type,
      amount: 50.0,
      dueDate: dueDate,
      paid: paid,
      isRecurring: false,
      createdAt: now,
    );
  }

  test(
    'given an overdue unpaid expense when call is invoked then classify it as overdue with notifyAt at the due date',
    () {
      final dueDate = DateTime(2026, 7, 12);
      final transaction = buildTransaction(dueDate: dueDate);

      final result = usecase([transaction], now: now);

      expect(result, [
        TransactionReminder(
          transaction: transaction,
          urgency: ReminderUrgency.overdue,
          notifyAt: dueDate,
        ),
      ]);
    },
  );

  test(
    'given an expense due today when call is invoked then classify it as dueToday at 8:00 AM',
    () {
      final dueDate = DateTime(2026, 7, 14);
      final transaction = buildTransaction(dueDate: dueDate);

      final result = usecase([transaction], now: now);

      expect(result, [
        TransactionReminder(
          transaction: transaction,
          urgency: ReminderUrgency.dueToday,
          notifyAt: DateTime(2026, 7, 14, 8, 0),
        ),
      ]);
    },
  );

  test(
    'given an expense due in the future when call is invoked then classify it as dueTomorrow and dueToday reminders',
    () {
      final dueDate = DateTime(2026, 7, 17);
      final transaction = buildTransaction(dueDate: dueDate);

      final result = usecase([transaction], now: now);

      expect(result, [
        TransactionReminder(
          transaction: transaction,
          urgency: ReminderUrgency.dueTomorrow,
          notifyAt: DateTime(2026, 7, 16, 8, 0),
        ),
        TransactionReminder(
          transaction: transaction,
          urgency: ReminderUrgency.dueToday,
          notifyAt: DateTime(2026, 7, 17, 8, 0),
        ),
      ]);
    },
  );

  test(
    'given a transaction without a due date when call is invoked then it is skipped',
    () {
      final transaction = buildTransaction(dueDate: null);

      final result = usecase([transaction], now: now);

      expect(result, isEmpty);
    },
  );

  test(
    'given an already paid transaction when call is invoked then it is skipped',
    () {
      final transaction = buildTransaction(
        dueDate: DateTime(2026, 7, 14),
        paid: true,
      );

      final result = usecase([transaction], now: now);

      expect(result, isEmpty);
    },
  );

  test(
    'given a non-expense transaction when call is invoked then it is skipped',
    () {
      final transaction = buildTransaction(
        dueDate: DateTime(2026, 7, 14),
        type: TransactionType.income,
      );

      final result = usecase([transaction], now: now);

      expect(result, isEmpty);
    },
  );
}
