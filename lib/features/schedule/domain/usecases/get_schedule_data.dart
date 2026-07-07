import 'package:due_day/core/errors/failures.dart';
import 'package:due_day/features/schedule/domain/entities/schedule_summary.dart';
import 'package:due_day/features/transactions/domain/entities/transaction_entity.dart';
import 'package:due_day/features/transactions/domain/repositories/transaction_repository.dart';
import 'package:fpdart/fpdart.dart';

class GetScheduleData {
  final TransactionRepository repository;

  GetScheduleData(this.repository);

  Stream<Either<Failure, ScheduleSummary>> execute() {
    // For now, let's get all transactions and filter/aggregate them here.
    // In a real app, we might want to pass dates to the repository.
    return repository.getTransactions().map((either) {
      return either.map((transactions) {
        final now = DateTime.now();
        // Simple logic for weekly overview: transactions in the next 7 days or overdue
        final weekFromNow = now.add(const Duration(days: 7));

        final scheduledItems = transactions.where((t) {
          final date = t.dueDate ?? t.createdAt;
          // Include if it's an expense and (is overdue OR is within the next 7 days)
          return t.type == TransactionType.expense &&
              (date.isBefore(weekFromNow));
        }).toList();

        // Sort by date
        scheduledItems.sort((a, b) {
          final dateA = a.dueDate ?? a.createdAt;
          final dateB = b.dueDate ?? b.createdAt;
          return dateA.compareTo(dateB);
        });

        double totalPaid = 0;
        double totalToPay = 0;

        for (final item in scheduledItems) {
          if (item.paid) {
            totalPaid += item.amount.abs();
          } else {
            totalToPay += item.amount.abs();
          }
        }

        // Find next income
        TransactionEntity? nextIncome;
        final incomes = transactions
            .where((t) => t.type == TransactionType.income && !t.paid)
            .toList();
        incomes.sort((a, b) {
          final dateA = a.dueDate ?? a.createdAt;
          final dateB = b.dueDate ?? b.createdAt;
          return dateA.compareTo(dateB);
        });

        if (incomes.isNotEmpty) {
          nextIncome = incomes.first;
        }

        return ScheduleSummary(
          totalAmount: totalPaid + totalToPay,
          totalPaid: totalPaid,
          totalToPay: totalToPay,
          transactions: scheduledItems,
          nextIncomeAmount: nextIncome?.amount,
          nextIncomeDate: nextIncome?.dueDate ?? nextIncome?.createdAt,
        );
      });
    });
  }
}
