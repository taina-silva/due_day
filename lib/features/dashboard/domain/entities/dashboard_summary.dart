import 'package:due_day/features/transactions/domain/entities/transaction_entity.dart';
import 'package:equatable/equatable.dart';

class DashboardSummary extends Equatable {
  final double currentBalance;
  final double projectedBalance;
  final double monthlyIncome;
  final double monthlyExpenses;
  final List<TransactionEntity> upcomingDues;
  final Map<String, double> spendingByCategory;

  const DashboardSummary({
    required this.currentBalance,
    required this.projectedBalance,
    required this.monthlyIncome,
    required this.monthlyExpenses,
    required this.upcomingDues,
    required this.spendingByCategory,
  });

  @override
  List<Object?> get props => [
    currentBalance,
    projectedBalance,
    monthlyIncome,
    monthlyExpenses,
    upcomingDues,
    spendingByCategory,
  ];
}
