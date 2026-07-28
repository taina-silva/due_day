import 'package:due_day/features/accounts/domain/entities/account_entity.dart';
import 'package:due_day/features/dashboard/domain/entities/dashboard_summary.dart';
import 'package:due_day/features/transactions/domain/entities/transaction_entity.dart';

class GetDashboardSummary {
  DashboardSummary call({
    required List<AccountEntity> accounts,
    required List<TransactionEntity> transactions,
  }) {
    double currentBalance = 0;
    for (final account in accounts) {
      currentBalance += account.balance;
    }

    double monthlyIncome = 0;
    double monthlyExpenses = 0;
    final now = DateTime.now();
    final firstDayOfMonth = DateTime(now.year, now.month, 1);
    final lastDayOfMonth = DateTime(now.year, now.month + 1, 0);

    final Map<String, double> spendingByCategory = {};

    for (final tx in transactions) {
      // Monthly totals (only for this month)
      if (tx.createdAt.isAfter(firstDayOfMonth) ||
          tx.createdAt.isAtSameMomentAs(firstDayOfMonth)) {
        if (tx.type == TransactionType.income) {
          monthlyIncome += tx.amount;
        } else if (tx.type == TransactionType.expense) {
          monthlyExpenses += tx.amount;

          // Spending by category (only for expenses)
          if (tx.category != null) {
            spendingByCategory[tx.category!] =
                (spendingByCategory[tx.category!] ?? 0) + tx.amount;
          }
        }
      }
    }

    // Upcoming dues: unpaid expenses due in the future
    final upcomingDues = transactions
        .where(
          (tx) =>
              tx.type == TransactionType.expense &&
              !tx.paid &&
              tx.dueDate != null &&
              tx.dueDate!.isAfter(now),
        )
        .toList();
    upcomingDues.sort((a, b) => a.dueDate!.compareTo(b.dueDate!));

    // Projected Balance: Current + Unpaid Incomes - Unpaid Expenses (for this month)
    double projectedBalance = currentBalance;
    for (final tx in transactions) {
      if (!tx.paid &&
          tx.dueDate != null &&
          tx.dueDate!.isBefore(lastDayOfMonth)) {
        if (tx.type == TransactionType.income) {
          projectedBalance += tx.amount;
        } else if (tx.type == TransactionType.expense) {
          projectedBalance -= tx.amount;
        }
      }
    }

    return DashboardSummary(
      currentBalance: currentBalance,
      projectedBalance: projectedBalance,
      monthlyIncome: monthlyIncome,
      monthlyExpenses: monthlyExpenses,
      upcomingDues: upcomingDues.take(5).toList(),
      spendingByCategory: spendingByCategory,
      insight: _classifyInsight(
        monthlyIncome: monthlyIncome,
        monthlyExpenses: monthlyExpenses,
        spendingByCategory: spendingByCategory,
      ),
    );
  }

  DashboardInsight _classifyInsight({
    required double monthlyIncome,
    required double monthlyExpenses,
    required Map<String, double> spendingByCategory,
  }) {
    var insight = const DashboardInsight(type: DashboardInsightType.healthy);

    if (monthlyIncome > 0 && monthlyExpenses > monthlyIncome) {
      insight = DashboardInsight(
        type: DashboardInsightType.budgetWarning,
        budgetPercentage: ((monthlyExpenses / monthlyIncome) * 100).toInt(),
      );
    }

    if (monthlyIncome > 0 && spendingByCategory.isNotEmpty) {
      final highestCategoryEntry = spendingByCategory.entries.reduce(
        (a, b) => a.value > b.value ? a : b,
      );

      if (highestCategoryEntry.value > (monthlyIncome * 0.3)) {
        insight = DashboardInsight(
          type: DashboardInsightType.categoryWarning,
          categoryId: highestCategoryEntry.key,
        );
      }
    }

    return insight;
  }
}
