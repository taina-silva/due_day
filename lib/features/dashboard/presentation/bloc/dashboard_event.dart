import 'package:equatable/equatable.dart';

abstract class DashboardEvent extends Equatable {
  const DashboardEvent();

  @override
  List<Object?> get props => [];
}

class DashboardLoadRequested extends DashboardEvent {
  final bool forceRefresh;

  const DashboardLoadRequested({this.forceRefresh = false});

  @override
  List<Object?> get props => [forceRefresh];
}

class DashboardSyncRecurringRequested extends DashboardEvent {}

class DashboardFilterAccountsRequested extends DashboardEvent {
  final List<String> selectedAccountIds;

  const DashboardFilterAccountsRequested(this.selectedAccountIds);

  @override
  List<Object?> get props => [selectedAccountIds];
}
