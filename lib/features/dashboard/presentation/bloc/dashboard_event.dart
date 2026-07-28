import 'package:due_day/core/errors/failures.dart';
import 'package:due_day/features/accounts/domain/entities/account_entity.dart';
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

class DashboardDataUpdated extends DashboardEvent {
  final List<AccountEntity> accounts;
  final List<TransactionEntity> transactions;

  const DashboardDataUpdated({
    required this.accounts,
    required this.transactions,
  });

  @override
  List<Object?> get props => [accounts, transactions];
}

class DashboardErrorOccurred extends DashboardEvent {
  final Failure failure;

  const DashboardErrorOccurred(this.failure);

  @override
  List<Object?> get props => [failure];
}
