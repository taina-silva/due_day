import 'package:due_day/features/transactions/domain/entities/transaction_entity.dart';
import 'package:equatable/equatable.dart';

enum ReminderUrgency { overdue, dueToday, dueTomorrow }

class TransactionReminder extends Equatable {
  final TransactionEntity transaction;
  final ReminderUrgency urgency;
  final DateTime notifyAt;

  const TransactionReminder({
    required this.transaction,
    required this.urgency,
    required this.notifyAt,
  });

  @override
  List<Object?> get props => [transaction, urgency, notifyAt];
}

/// Pure, synchronous classification of which reminders each unpaid expense
/// transaction currently needs (overdue / due today / due tomorrow), with
/// the [DateTime] each one should notify at.
class ClassifyTransactionReminders {
  List<TransactionReminder> call(
    List<TransactionEntity> transactions, {
    DateTime? now,
  }) {
    final currentNow = now ?? DateTime.now();
    final todayMidnight = DateTime(
      currentNow.year,
      currentNow.month,
      currentNow.day,
    );

    final reminders = <TransactionReminder>[];

    for (final t in transactions) {
      if (t.dueDate == null ||
          t.paid != false ||
          t.type != TransactionType.expense) {
        continue;
      }

      final dueDate = t.dueDate!;
      final dueDateMidnight = DateTime(
        dueDate.year,
        dueDate.month,
        dueDate.day,
      );

      if (dueDateMidnight.isBefore(todayMidnight)) {
        reminders.add(
          TransactionReminder(
            transaction: t,
            urgency: ReminderUrgency.overdue,
            notifyAt: dueDate,
          ),
        );
        continue;
      }

      // 8:00 AM on the due date itself.
      final notifyDueDay = DateTime(
        dueDate.year,
        dueDate.month,
        dueDate.day,
        8,
        0,
      );

      if (dueDateMidnight.isAtSameMomentAs(todayMidnight)) {
        reminders.add(
          TransactionReminder(
            transaction: t,
            urgency: ReminderUrgency.dueToday,
            notifyAt: notifyDueDay,
          ),
        );
        continue;
      }

      // Due in the future: remind 1 day before (8:00 AM) and on the due
      // date itself (8:00 AM).
      final dayBefore = dueDate.subtract(const Duration(days: 1));
      final notifyDayBefore = DateTime(
        dayBefore.year,
        dayBefore.month,
        dayBefore.day,
        8,
        0,
      );

      reminders.add(
        TransactionReminder(
          transaction: t,
          urgency: ReminderUrgency.dueTomorrow,
          notifyAt: notifyDayBefore,
        ),
      );
      reminders.add(
        TransactionReminder(
          transaction: t,
          urgency: ReminderUrgency.dueToday,
          notifyAt: notifyDueDay,
        ),
      );
    }

    return reminders;
  }
}
