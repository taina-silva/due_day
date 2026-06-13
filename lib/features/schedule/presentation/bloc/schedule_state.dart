import 'package:due_day/features/categories/domain/entities/category_entity.dart';
import 'package:due_day/features/schedule/domain/entities/schedule_summary.dart';
import 'package:equatable/equatable.dart';

abstract class ScheduleState extends Equatable {
  const ScheduleState();

  @override
  List<Object?> get props => [];
}

class ScheduleInitial extends ScheduleState {}

class ScheduleLoading extends ScheduleState {}

class ScheduleLoaded extends ScheduleState {
  final ScheduleSummary summary;
  final Map<String, CategoryEntity> categories;

  const ScheduleLoaded(this.summary, {this.categories = const {}});

  @override
  List<Object?> get props => [summary, categories];
}

class ScheduleError extends ScheduleState {
  final String message;

  const ScheduleError(this.message);

  @override
  List<Object?> get props => [message];
}
