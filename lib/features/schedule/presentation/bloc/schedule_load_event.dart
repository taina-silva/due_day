import 'package:due_day/core/errors/failures.dart';
import 'package:due_day/features/schedule/domain/entities/schedule_summary.dart';
import 'package:equatable/equatable.dart';

abstract class ScheduleLoadEvent extends Equatable {
  const ScheduleLoadEvent();

  @override
  List<Object?> get props => [];
}

class LoadScheduleData extends ScheduleLoadEvent {}

class ScheduleDataUpdated extends ScheduleLoadEvent {
  final ScheduleSummary summary;

  const ScheduleDataUpdated(this.summary);

  @override
  List<Object?> get props => [summary];
}

class ScheduleLoadFailed extends ScheduleLoadEvent {
  final Failure failure;

  const ScheduleLoadFailed(this.failure);

  @override
  List<Object?> get props => [failure];
}
