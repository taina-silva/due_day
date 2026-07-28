import 'package:due_day/core/errors/failures.dart';
import 'package:equatable/equatable.dart';

abstract class ScheduleActionState extends Equatable {
  const ScheduleActionState();

  @override
  List<Object?> get props => [];
}

class ScheduleActionInitial extends ScheduleActionState {}

class ScheduleActionInProgress extends ScheduleActionState {}

class ScheduleActionSuccess extends ScheduleActionState {}

class ScheduleActionError extends ScheduleActionState {
  final Failure failure;

  const ScheduleActionError(this.failure);

  @override
  List<Object?> get props => [failure];
}
