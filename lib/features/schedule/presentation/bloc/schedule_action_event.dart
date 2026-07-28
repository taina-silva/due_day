import 'package:due_day/features/transactions/domain/entities/transaction_entity.dart';
import 'package:equatable/equatable.dart';

abstract class ScheduleActionEvent extends Equatable {
  const ScheduleActionEvent();

  @override
  List<Object?> get props => [];
}

class MarkAsPaidEvent extends ScheduleActionEvent {
  final TransactionEntity transaction;

  const MarkAsPaidEvent(this.transaction);

  @override
  List<Object?> get props => [transaction];
}
