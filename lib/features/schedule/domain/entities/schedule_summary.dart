import 'package:due_day/features/transactions/domain/entities/transaction_entity.dart';
import 'package:equatable/equatable.dart';

class ScheduleSummary extends Equatable {
  final double totalAmount;
  final double totalPaid;
  final double totalToPay;
  final double? nextIncomeAmount;
  final DateTime? nextIncomeDate;
  final List<TransactionEntity> transactions;

  const ScheduleSummary({
    required this.totalAmount,
    required this.totalPaid,
    required this.totalToPay,
    required this.transactions,
    this.nextIncomeAmount,
    this.nextIncomeDate,
  });

  @override
  List<Object?> get props => [
    totalAmount,
    totalPaid,
    totalToPay,
    nextIncomeAmount,
    nextIncomeDate,
    transactions,
  ];
}
