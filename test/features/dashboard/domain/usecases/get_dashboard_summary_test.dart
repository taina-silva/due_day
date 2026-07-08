import 'package:due_day/features/dashboard/domain/usecases/get_dashboard_summary.dart';
import 'package:due_day/features/transactions/domain/entities/transaction_entity.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/dashboard_test_helpers.dart';

void main() {
  late GetDashboardSummary getDashboardSummary;

  setUp(() {
    getDashboardSummary = GetDashboardSummary();
  });

  test('should calculate correct dashboard summary from accounts and transactions', () {
    // Current balance should be acc1 (1000) + acc2 (5000) = 6000
    // Income transaction: paid, income, 200, createdAt=tDateTime.
    // Expense transaction: paid, expense, 50, createdAt=tDateTime.
    // Unpaid expense transaction: unpaid, expense, 100, dueDate=2026-07-15, createdAt=tDateTime.

    // We adjust current local DateTime during test or just rely on tDateTime month match.
    // Note: GetDashboardSummary uses DateTime.now() to check the current month.
    // If the test runs in a different month than tDateTime, monthly totals won't match.
    // So let's build the test transactions dynamically using DateTime.now() to ensure the test always passes regardless of when it is run!
    final now = DateTime.now();
    final firstDayOfMonth = DateTime(now.year, now.month, 1);

    final currentMonthIncome = TransactionEntity(
      id: 'tx-1',
      userId: 'user-1',
      type: TransactionType.income,
      amount: 200.0,
      paid: true,
      isRecurring: false,
      createdAt: firstDayOfMonth.add(const Duration(hours: 12)),
      accountTo: 'acc-1',
      notes: 'Salary bonus',
    );

    final currentMonthExpense = TransactionEntity(
      id: 'tx-2',
      userId: 'user-1',
      type: TransactionType.expense,
      amount: 50.0,
      paid: true,
      isRecurring: false,
      createdAt: firstDayOfMonth.add(const Duration(hours: 12)),
      accountFrom: 'acc-1',
      category: 'cat-1',
      notes: 'Coffee',
    );

    final futureUnpaidExpense = TransactionEntity(
      id: 'tx-3',
      userId: 'user-1',
      type: TransactionType.expense,
      amount: 100.0,
      paid: false,
      isRecurring: false,
      createdAt: firstDayOfMonth.add(const Duration(hours: 12)),
      dueDate: now.add(const Duration(days: 5)),
      accountFrom: 'acc-1',
      category: 'cat-2',
      notes: 'Electricity bill',
    );

    final result = getDashboardSummary(
      accounts: [tAccount1, tAccount2],
      transactions: [
        currentMonthIncome,
        currentMonthExpense,
        futureUnpaidExpense,
      ],
    );

    expect(result.currentBalance, 6000.0);
    expect(result.monthlyIncome, 200.0);
    expect(result.monthlyExpenses, 150.0);
    // Upcoming dues: should contain futureUnpaidExpense
    expect(result.upcomingDues, contains(futureUnpaidExpense));
    expect(result.spendingByCategory['cat-1'], 50.0);
    expect(result.spendingByCategory['cat-2'], 100.0);

    // Projected Balance: Current (6000) - Unpaid Expenses (100) = 5900
    expect(result.projectedBalance, 5900.0);
  });
}
