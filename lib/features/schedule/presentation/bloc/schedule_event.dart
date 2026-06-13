import 'package:due_day/features/transactions/domain/entities/transaction_entity.dart';
import 'package:equatable/equatable.dart';

abstract class ScheduleEvent extends Equatable {
  const ScheduleEvent();

  @override
  List<Object?> get props => [];
}

class LoadScheduleData extends ScheduleEvent {}

class MarkAsPaid extends ScheduleEvent {
  final TransactionEntity transaction;

  const MarkAsPaid(this.transaction);

  @override
  List<Object?> get props => [transaction];
}
