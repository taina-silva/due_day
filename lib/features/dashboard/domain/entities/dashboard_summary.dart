import 'package:due_day/features/transactions/domain/entities/transaction_entity.dart';
import 'package:equatable/equatable.dart';

enum DashboardInsightType { healthy, budgetWarning, categoryWarning }

class DashboardInsight extends Equatable {
  final DashboardInsightType type;
  final int budgetPercentage;
  final String? categoryId;

  const DashboardInsight({
    required this.type,
    this.budgetPercentage = 0,
    this.categoryId,
  });

  @override
  List<Object?> get props => [type, budgetPercentage, categoryId];
}

class DashboardSummary extends Equatable {
  /// Key of the "Uncategorized" group in [spendingByCategory] (DSH-006).
  static const String uncategorizedKey = '';

  /// First day of the month the totals belong to (DSH-001).
  final DateTime month;

  /// Paid expenses in `spending` (or no) categories (DSH-003).
  final double spent;

  /// Paid income not in `ignored` categories (DSH-004).
  final double income;

  /// Paid expenses in `investment` categories (DSH-005).
  final double invested;
  final List<TransactionEntity> upcomingDues;

  /// Spent grouped by category id; uncategorized under [uncategorizedKey].
  final Map<String, double> spendingByCategory;
  final DashboardInsight insight;

  const DashboardSummary({
    required this.month,
    required this.spent,
    required this.income,
    required this.invested,
    required this.upcomingDues,
    required this.spendingByCategory,
    required this.insight,
  });

  @override
  List<Object?> get props => [
    month,
    spent,
    income,
    invested,
    upcomingDues,
    spendingByCategory,
    insight,
  ];
}
