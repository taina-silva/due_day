import 'package:due_day/core/errors/failures.dart';
import 'package:due_day/features/dashboard/domain/entities/dashboard_summary.dart';
import 'package:equatable/equatable.dart';

abstract class DashboardState extends Equatable {
  const DashboardState();

  @override
  List<Object?> get props => [];
}

class DashboardInitial extends DashboardState {}

class DashboardLoading extends DashboardState {}

class DashboardLoaded extends DashboardState {
  final DashboardSummary summary;
  final List<String> selectedAccountIds;

  const DashboardLoaded(this.summary, {this.selectedAccountIds = const []});

  @override
  List<Object?> get props => [summary, selectedAccountIds];
}

class DashboardError extends DashboardState {
  final Failure failure;

  const DashboardError(this.failure);

  @override
  List<Object?> get props => [failure];
}
