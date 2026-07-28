import 'package:due_day/features/dashboard/domain/entities/dashboard_summary.dart';
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
      // Must stay after `now` and before `lastDayOfMonth` regardless of
      // which day of the month the test runs on, so a short, fixed offset
      // is safer than a multi-day one near the end of the month.
      dueDate: now.add(const Duration(hours: 1)),
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

    // cat-2 (100) is >30% of the 200 monthly income, so it takes priority
    // over the (not even triggered, since expenses < income) budget warning.
    expect(result.insight.type, DashboardInsightType.categoryWarning);
    expect(result.insight.categoryId, 'cat-2');
  });

  group('insight classification', () {
    test('should classify as healthy when expenses are below income and no '
        'category dominates spending', () {
      final result = getDashboardSummary(
        accounts: const [],
        transactions: [
          TransactionEntity(
            id: 'income-1',
            userId: 'user-1',
            type: TransactionType.income,
            amount: 1000.0,
            paid: true,
            isRecurring: false,
            createdAt: DateTime.now(),
          ),
          TransactionEntity(
            id: 'expense-1',
            userId: 'user-1',
            type: TransactionType.expense,
            amount: 100.0,
            paid: true,
            isRecurring: false,
            createdAt: DateTime.now(),
            category: 'cat-1',
          ),
        ],
      );

      expect(result.insight.type, DashboardInsightType.healthy);
    });

    test('should classify as budgetWarning when monthly expenses exceed '
        'monthly income and no single category dominates spending', () {
      final result = getDashboardSummary(
        accounts: const [],
        transactions: [
          TransactionEntity(
            id: 'income-1',
            userId: 'user-1',
            type: TransactionType.income,
            amount: 100.0,
            paid: true,
            isRecurring: false,
            createdAt: DateTime.now(),
          ),
          TransactionEntity(
            id: 'expense-1',
            userId: 'user-1',
            type: TransactionType.expense,
            amount: 30.0,
            paid: true,
            isRecurring: false,
            createdAt: DateTime.now(),
            category: 'cat-1',
          ),
          TransactionEntity(
            id: 'expense-2',
            userId: 'user-1',
            type: TransactionType.expense,
            amount: 30.0,
            paid: true,
            isRecurring: false,
            createdAt: DateTime.now(),
            category: 'cat-2',
          ),
          TransactionEntity(
            id: 'expense-3',
            userId: 'user-1',
            type: TransactionType.expense,
            amount: 30.0,
            paid: true,
            isRecurring: false,
            createdAt: DateTime.now(),
            category: 'cat-3',
          ),
          TransactionEntity(
            id: 'expense-4',
            userId: 'user-1',
            type: TransactionType.expense,
            amount: 30.0,
            paid: true,
            isRecurring: false,
            createdAt: DateTime.now(),
            category: 'cat-4',
          ),
        ],
      );

      // Each category (30) sits exactly at 30% of the 100 income, so none
      // individually triggers categoryWarning; only the combined 120 total
      // (>100 income) triggers budgetWarning.
      expect(result.insight.type, DashboardInsightType.budgetWarning);
      expect(result.insight.budgetPercentage, 120);
    });

    test('should classify as categoryWarning when a single category exceeds '
        '30% of monthly income, taking priority over budgetWarning', () {
      final result = getDashboardSummary(
        accounts: const [],
        transactions: [
          TransactionEntity(
            id: 'income-1',
            userId: 'user-1',
            type: TransactionType.income,
            amount: 100.0,
            paid: true,
            isRecurring: false,
            createdAt: DateTime.now(),
          ),
          TransactionEntity(
            id: 'expense-1',
            userId: 'user-1',
            type: TransactionType.expense,
            amount: 40.0,
            paid: true,
            isRecurring: false,
            createdAt: DateTime.now(),
            category: 'cat-1',
          ),
        ],
      );

      expect(result.insight.type, DashboardInsightType.categoryWarning);
      expect(result.insight.categoryId, 'cat-1');
    });

    test('should classify as healthy when there is no monthly income', () {
      final result = getDashboardSummary(
        accounts: const [],
        transactions: [
          TransactionEntity(
            id: 'expense-1',
            userId: 'user-1',
            type: TransactionType.expense,
            amount: 100.0,
            paid: true,
            isRecurring: false,
            createdAt: DateTime.now(),
            category: 'cat-1',
          ),
        ],
      );

      expect(result.insight.type, DashboardInsightType.healthy);
    });
  });
}
