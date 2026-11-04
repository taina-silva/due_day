import 'package:due_day/features/categories/domain/entities/category_entity.dart';
import 'package:due_day/features/categories/domain/entities/category_kind.dart';
import 'package:due_day/features/categories/domain/entities/system_categories.dart';
import 'package:due_day/features/dashboard/domain/entities/dashboard_summary.dart';
import 'package:due_day/features/transactions/domain/entities/transaction_entity.dart';

/// Computes one calendar month of the dashboard (DSH-001…DSH-007).
///
/// Only transactions whose effective date (TRX-003) falls inside [month]
/// count. Legacy transfers count nowhere (TRX-002). Balances don't exist
/// (DSH-007).
class GetDashboardSummary {
  DashboardSummary call({
    required DateTime month,
    required List<TransactionEntity> transactions,
    required List<CategoryEntity> categories,
    DateTime? now,
  }) {
    final start = DateTime(month.year, month.month);
    final end = DateTime(month.year, month.month + 1);
    final kindById = {for (final c in categories) c.id: c.kind};

    double spent = 0;
    double income = 0;
    double invested = 0;
    final spendingByCategory = <String, double>{};

    for (final tx in transactions) {
      if (!tx.paid || tx.type == TransactionType.transfer) continue;
      final date = tx.effectiveDate;
      if (date.isBefore(start) || !date.isBefore(end)) continue;

      // System ids keep their kind even if the document is missing; other
      // unknown or missing ids read as uncategorized spending.
      final kind =
          kindById[tx.category] ?? SystemCategories.kindFor(tx.category ?? '');
      final groupKey = kind == null
          ? DashboardSummary.uncategorizedKey
          : tx.category!;

      if (tx.type == TransactionType.income) {
        if (kind != CategoryKind.ignored) income += tx.amount;
        continue;
      }

      switch (kind ?? CategoryKind.spending) {
        case CategoryKind.spending:
          spent += tx.amount;
          spendingByCategory[groupKey] =
              (spendingByCategory[groupKey] ?? 0) + tx.amount;
        case CategoryKind.investment:
          invested += tx.amount;
        case CategoryKind.ignored:
          break;
      }
    }

    // Upcoming dues: unpaid expenses due in the future.
    final reference = now ?? DateTime.now();
    final upcomingDues =
        transactions
            .where(
              (tx) =>
                  tx.type == TransactionType.expense &&
                  !tx.paid &&
                  tx.dueDate != null &&
                  tx.dueDate!.isAfter(reference),
            )
            .toList()
          ..sort((a, b) => a.dueDate!.compareTo(b.dueDate!));

    return DashboardSummary(
      month: start,
      spent: spent,
      income: income,
      invested: invested,
      upcomingDues: upcomingDues.take(5).toList(),
      spendingByCategory: spendingByCategory,
      insight: _classifyInsight(
        income: income,
        spent: spent,
        spendingByCategory: spendingByCategory,
      ),
    );
  }

  DashboardInsight _classifyInsight({
    required double income,
    required double spent,
    required Map<String, double> spendingByCategory,
  }) {
    var insight = const DashboardInsight(type: DashboardInsightType.healthy);

    if (income > 0 && spent > income) {
      insight = DashboardInsight(
        type: DashboardInsightType.budgetWarning,
        budgetPercentage: ((spent / income) * 100).toInt(),
      );
    }

    final categorized = spendingByCategory.entries
        .where((e) => e.key != DashboardSummary.uncategorizedKey)
        .toList();
    if (income > 0 && categorized.isNotEmpty) {
      final highest = categorized.reduce((a, b) => a.value > b.value ? a : b);
      if (highest.value > (income * 0.3)) {
        insight = DashboardInsight(
          type: DashboardInsightType.categoryWarning,
          categoryId: highest.key,
        );
      }
    }

    return insight;
  }
}
