import 'package:due_day/features/categories/domain/entities/category_entity.dart';
import 'package:due_day/features/categories/domain/entities/category_kind.dart';
import 'package:due_day/features/categories/domain/entities/system_categories.dart';
import 'package:due_day/features/dashboard/domain/entities/dashboard_summary.dart';
import 'package:due_day/features/dashboard/domain/usecases/get_dashboard_summary.dart';
import 'package:due_day/features/transactions/domain/entities/transaction_entity.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late GetDashboardSummary getDashboardSummary;

  final october = DateTime(2026, 10);
  final september = DateTime(2026, 9);
  final today = DateTime(2026, 10, 4);

  CategoryEntity category(String id, CategoryKind kind) => CategoryEntity(
    id: id,
    userId: 'user-1',
    name: id,
    color: '#000000',
    icon: '0xf624',
    createdAt: DateTime(2026),
    kind: kind,
  );

  final food = category('cat-food', CategoryKind.spending);
  final bills = category('cat-bills', CategoryKind.spending);
  final salary = category('cat-salary', CategoryKind.spending);
  final investment = category(
    SystemCategories.investmentId,
    CategoryKind.investment,
  );
  final ignored = category(SystemCategories.ignoredId, CategoryKind.ignored);
  final categories = [food, bills, salary, investment, ignored];

  var seq = 0;
  TransactionEntity tx({
    required TransactionType type,
    required double amount,
    String? categoryId,
    bool paid = true,
    DateTime? paidDate,
    DateTime? dueDate,
    DateTime? createdAt,
  }) {
    seq++;
    return TransactionEntity(
      id: 'tx-$seq',
      userId: 'user-1',
      type: type,
      amount: amount,
      paid: paid,
      isRecurring: false,
      category: categoryId,
      paidDate: paidDate,
      dueDate: dueDate,
      createdAt: createdAt ?? today,
    );
  }

  DashboardSummary summarize(
    List<TransactionEntity> transactions, {
    DateTime? month,
  }) => getDashboardSummary(
    month: month ?? october,
    transactions: transactions,
    categories: categories,
    now: today,
  );

  setUp(() {
    getDashboardSummary = GetDashboardSummary();
  });

  group('TRX-003: effective date', () {
    test('imported last quarter, written today → paidDate counts', () {
      final t = tx(
        type: TransactionType.expense,
        amount: 10,
        paidDate: DateTime(2026, 7, 10),
        createdAt: DateTime(2026, 10, 4),
      );

      expect(t.effectiveDate, DateTime(2026, 7, 10));
    });

    test('legacy document without dates → createdAt', () {
      final t = tx(
        type: TransactionType.expense,
        amount: 10,
        createdAt: DateTime(2026, 5, 2),
      );

      expect(t.effectiveDate, DateTime(2026, 5, 2));
    });

    test('no paidDate → dueDate', () {
      final t = tx(
        type: TransactionType.expense,
        amount: 10,
        dueDate: DateTime(2026, 6, 1),
        createdAt: DateTime(2026, 5, 2),
      );

      expect(t.effectiveDate, DateTime(2026, 6, 1));
    });
  });

  group('DSH-002: totals bounded to the selected month', () {
    final imported = [
      tx(
        type: TransactionType.expense,
        amount: 100,
        categoryId: food.id,
        paidDate: DateTime(2026, 7, 15),
      ),
      tx(
        type: TransactionType.expense,
        amount: 200,
        categoryId: food.id,
        paidDate: DateTime(2026, 8, 15),
      ),
      tx(
        type: TransactionType.expense,
        amount: 300,
        categoryId: food.id,
        paidDate: DateTime(2026, 9, 15),
      ),
      tx(
        type: TransactionType.expense,
        amount: 1,
        categoryId: food.id,
        paidDate: DateTime(2026, 9, 30, 23, 59, 59),
      ),
    ];

    test('importing three months at once → none count in October', () {
      final result = summarize(imported);

      expect(result.month, october);
      expect(result.spent, 0);
      expect(result.spendingByCategory, isEmpty);
    });

    test('September shows only September (including its last second)', () {
      final result = summarize(imported, month: september);

      expect(result.spent, 301);
      expect(result.spendingByCategory, {food.id: 301});
    });
  });

  group('DSH-003: Spent', () {
    test('mixed month → only paid spending and uncategorized count', () {
      final result = summarize([
        tx(
          type: TransactionType.expense,
          amount: 100,
          categoryId: food.id,
          paidDate: DateTime(2026, 10, 2),
        ),
        tx(
          type: TransactionType.expense,
          amount: 50,
          paidDate: DateTime(2026, 10, 3),
        ),
        tx(
          type: TransactionType.expense,
          amount: 1000,
          categoryId: investment.id,
          paidDate: DateTime(2026, 10, 5),
        ),
        tx(
          type: TransactionType.expense,
          amount: 2000,
          categoryId: ignored.id,
          paidDate: DateTime(2026, 10, 10),
        ),
        tx(
          type: TransactionType.expense,
          amount: 300,
          categoryId: bills.id,
          paid: false,
          dueDate: DateTime(2026, 10, 20),
        ),
      ]);

      expect(result.spent, 150);
    });
  });

  group('DSH-004: Income', () {
    test('card refund left uncategorized counts as income', () {
      final result = summarize([
        tx(
          type: TransactionType.income,
          amount: 5000,
          categoryId: salary.id,
          paidDate: DateTime(2026, 10, 5),
        ),
        tx(
          type: TransactionType.income,
          amount: 40,
          paidDate: DateTime(2026, 10, 6),
        ),
      ]);

      expect(result.income, 5040);
    });

    test('ignored income (payment received) does not count', () {
      final result = summarize([
        tx(
          type: TransactionType.income,
          amount: 2000,
          categoryId: ignored.id,
          paidDate: DateTime(2026, 10, 10),
        ),
      ]);

      expect(result.income, 0);
    });
  });

  group('DSH-005: Invested', () {
    test('monthly investment is shown and never added to Spent', () {
      final result = summarize([
        tx(
          type: TransactionType.expense,
          amount: 1000,
          categoryId: investment.id,
          paidDate: DateTime(2026, 10, 5),
        ),
        tx(
          type: TransactionType.expense,
          amount: 200,
          categoryId: food.id,
          paidDate: DateTime(2026, 10, 6),
        ),
      ]);

      expect(result.invested, 1000);
      expect(result.spent, 200);
    });
  });

  group('DSH-006: spending by category', () {
    test('Ignored does not appear; uncategorized is its own group', () {
      final result = summarize([
        tx(
          type: TransactionType.expense,
          amount: 2000,
          categoryId: ignored.id,
          paidDate: DateTime(2026, 10, 10),
        ),
        tx(
          type: TransactionType.expense,
          amount: 80,
          categoryId: food.id,
          paidDate: DateTime(2026, 10, 11),
        ),
        tx(
          type: TransactionType.expense,
          amount: 20,
          paidDate: DateTime(2026, 10, 12),
        ),
      ]);

      expect(result.spendingByCategory, {
        food.id: 80,
        DashboardSummary.uncategorizedKey: 20,
      });
    });
  });

  group('TRX-002: legacy transfers', () {
    test('a paid transfer in the month changes no total', () {
      final result = summarize([
        tx(
          type: TransactionType.transfer,
          amount: 500,
          paidDate: DateTime(2026, 10, 10),
        ),
      ]);

      expect(result.spent, 0);
      expect(result.income, 0);
      expect(result.invested, 0);
      expect(result.spendingByCategory, isEmpty);
    });
  });

  group('upcoming dues', () {
    test('lists unpaid future expenses sorted by due date', () {
      final later = tx(
        type: TransactionType.expense,
        amount: 10,
        paid: false,
        dueDate: DateTime(2026, 10, 20),
      );
      final sooner = tx(
        type: TransactionType.expense,
        amount: 10,
        paid: false,
        dueDate: DateTime(2026, 10, 10),
      );
      final past = tx(
        type: TransactionType.expense,
        amount: 10,
        paid: false,
        dueDate: DateTime(2026, 10, 1),
      );

      final result = summarize([later, past, sooner]);

      expect(result.upcomingDues, [sooner, later]);
    });
  });

  group('insight', () {
    test('healthy when spent is below income and no category dominates', () {
      final result = summarize([
        tx(
          type: TransactionType.income,
          amount: 1000,
          paidDate: DateTime(2026, 10, 1),
        ),
        tx(
          type: TransactionType.expense,
          amount: 100,
          categoryId: food.id,
          paidDate: DateTime(2026, 10, 2),
        ),
      ]);

      expect(result.insight.type, DashboardInsightType.healthy);
    });

    test('budgetWarning when spent exceeds income', () {
      final result = summarize([
        tx(
          type: TransactionType.income,
          amount: 1000,
          paidDate: DateTime(2026, 10, 1),
        ),
        tx(
          type: TransactionType.expense,
          amount: 1200,
          paidDate: DateTime(2026, 10, 2),
        ),
      ]);

      expect(result.insight.type, DashboardInsightType.budgetWarning);
      expect(result.insight.budgetPercentage, 120);
    });

    test('categoryWarning when one category exceeds 30% of income', () {
      final result = summarize([
        tx(
          type: TransactionType.income,
          amount: 1000,
          paidDate: DateTime(2026, 10, 1),
        ),
        tx(
          type: TransactionType.expense,
          amount: 400,
          categoryId: food.id,
          paidDate: DateTime(2026, 10, 2),
        ),
      ]);

      expect(result.insight.type, DashboardInsightType.categoryWarning);
      expect(result.insight.categoryId, food.id);
    });

    test('healthy when there is no income', () {
      final result = summarize([
        tx(
          type: TransactionType.expense,
          amount: 400,
          categoryId: food.id,
          paidDate: DateTime(2026, 10, 2),
        ),
      ]);

      expect(result.insight.type, DashboardInsightType.healthy);
    });
  });
}
