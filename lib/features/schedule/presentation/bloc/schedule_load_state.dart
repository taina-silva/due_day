import 'package:due_day/core/errors/failures.dart';
import 'package:due_day/features/schedule/domain/entities/schedule_summary.dart';
import 'package:equatable/equatable.dart';

abstract class ScheduleLoadState extends Equatable {
  const ScheduleLoadState();

  @override
  List<Object?> get props => [];
}

class ScheduleInitial extends ScheduleLoadState {}

class ScheduleLoading extends ScheduleLoadState {}

class ScheduleLoaded extends ScheduleLoadState {
  final ScheduleSummary summary;

  const ScheduleLoaded(this.summary);

  @override
  List<Object?> get props => [summary];
}

class ScheduleError extends ScheduleLoadState {
  final Failure failure;

  const ScheduleError(this.failure);

  @override
  List<Object?> get props => [failure];
}
