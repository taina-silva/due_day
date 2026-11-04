import 'package:due_day/core/errors/failures.dart';
import 'package:due_day/features/categories/domain/entities/category_entity.dart';
import 'package:due_day/features/transactions/domain/entities/transaction_entity.dart';
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

class DashboardFilterAccountsRequested extends DashboardEvent {
  final List<String> selectedAccountIds;

  const DashboardFilterAccountsRequested(this.selectedAccountIds);

  @override
  List<Object?> get props => [selectedAccountIds];
}

/// Shows another calendar month (DSH-001). Any day inside it works.
class DashboardMonthChanged extends DashboardEvent {
  final DateTime month;

  const DashboardMonthChanged(this.month);

  @override
  List<Object?> get props => [month];
}

class DashboardDataUpdated extends DashboardEvent {
  final List<TransactionEntity> transactions;
  final List<CategoryEntity> categories;

  const DashboardDataUpdated({
    required this.transactions,
    required this.categories,
  });

  @override
  List<Object?> get props => [transactions, categories];
}

class DashboardErrorOccurred extends DashboardEvent {
  final Failure failure;

  const DashboardErrorOccurred(this.failure);

  @override
  List<Object?> get props => [failure];
}
