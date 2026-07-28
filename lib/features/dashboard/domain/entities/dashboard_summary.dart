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
  final double currentBalance;
  final double projectedBalance;
  final double monthlyIncome;
  final double monthlyExpenses;
  final List<TransactionEntity> upcomingDues;
  final Map<String, double> spendingByCategory;
  final DashboardInsight insight;

  const DashboardSummary({
    required this.currentBalance,
    required this.projectedBalance,
    required this.monthlyIncome,
    required this.monthlyExpenses,
    required this.upcomingDues,
    required this.spendingByCategory,
    required this.insight,
  });

  @override
  List<Object?> get props => [
    currentBalance,
    projectedBalance,
    monthlyIncome,
    monthlyExpenses,
    upcomingDues,
    spendingByCategory,
    insight,
  ];
}
