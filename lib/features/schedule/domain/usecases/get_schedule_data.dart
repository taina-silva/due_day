import 'package:due_day/core/errors/failures.dart';
import 'package:due_day/features/schedule/domain/entities/schedule_summary.dart';
import 'package:due_day/features/transactions/domain/entities/transaction_entity.dart';
import 'package:due_day/features/transactions/domain/repositories/transaction_repository.dart';
import 'package:fpdart/fpdart.dart';
import 'package:rxdart/rxdart.dart';

class GetScheduleData {
  final TransactionRepository repository;

  GetScheduleData(this.repository);

  Stream<Either<Failure, ScheduleSummary>> execute() {
    return Rx.combineLatest2(
      repository.getTransactions(type: TransactionType.expense),
      repository.getTransactions(type: TransactionType.income),
      (
        Either<Failure, List<TransactionEntity>> expenseResult,
        Either<Failure, List<TransactionEntity>> incomeResult,
      ) {
        return expenseResult.flatMap(
          (expenses) =>
              incomeResult.map((incomes) => _buildSummary(expenses, incomes)),
        );
      },
    );
  }

  ScheduleSummary _buildSummary(
    List<TransactionEntity> expenses,
    List<TransactionEntity> incomes,
  ) {
    final weekFromNow = DateTime.now().add(const Duration(days: 7));

    // Include overdue and upcoming (next 7 days) expenses, paid or not.
    final scheduledItems =
        expenses.where((t) => _dueDate(t).isBefore(weekFromNow)).toList()
          ..sort((a, b) => _dueDate(a).compareTo(_dueDate(b)));

    double totalPaid = 0;
    double totalToPay = 0;
    for (final item in scheduledItems) {
      if (item.paid) {
        totalPaid += item.amount.abs();
      } else {
        totalToPay += item.amount.abs();
      }
    }

    final unpaidIncomes = incomes.where((t) => !t.paid).toList()
      ..sort((a, b) => _dueDate(a).compareTo(_dueDate(b)));
    final nextIncome = unpaidIncomes.isEmpty ? null : unpaidIncomes.first;

    return ScheduleSummary(
      totalAmount: totalPaid + totalToPay,
      totalPaid: totalPaid,
      totalToPay: totalToPay,
      transactions: scheduledItems,
      nextIncomeAmount: nextIncome?.amount,
      nextIncomeDate: nextIncome != null ? _dueDate(nextIncome) : null,
    );
  }

  DateTime _dueDate(TransactionEntity transaction) =>
      transaction.dueDate ?? transaction.createdAt;
}
