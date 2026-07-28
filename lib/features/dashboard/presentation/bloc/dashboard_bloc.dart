import 'dart:async';

import 'package:due_day/core/errors/failures.dart';
import 'package:due_day/features/accounts/domain/entities/account_entity.dart';
import 'package:due_day/features/accounts/domain/usecases/account_usecases.dart';
import 'package:due_day/features/dashboard/domain/usecases/get_dashboard_summary.dart';
import 'package:due_day/features/dashboard/presentation/bloc/dashboard_event.dart';
import 'package:due_day/features/dashboard/presentation/bloc/dashboard_state.dart';
import 'package:due_day/features/transactions/domain/entities/transaction_entity.dart';
import 'package:due_day/features/transactions/domain/usecases/transaction_usecases.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rxdart/rxdart.dart';

class DashboardBloc extends Bloc<DashboardEvent, DashboardState> {
  final GetDashboardSummary getDashboardSummary;
  final GetAccounts getAccounts;
  final GetTransactions getTransactions;

  List<String> _selectedAccountIds = [];
  List<AccountEntity>? _lastAccounts;
  List<TransactionEntity>? _lastTransactions;
  StreamSubscription? _dashboardDataSubscription;

  DashboardBloc({
    required this.getDashboardSummary,
    required this.getAccounts,
    required this.getTransactions,
  }) : super(DashboardInitial()) {
    on<DashboardLoadRequested>(_onLoadRequested);
    on<DashboardFilterAccountsRequested>(_onFilterAccountsRequested);
    on<DashboardDataUpdated>(_onDataUpdated);
    on<DashboardErrorOccurred>(_onDashboardErrorOccurred);
  }

  Future<void> _onLoadRequested(
    DashboardLoadRequested event,
    Emitter<DashboardState> emit,
  ) async {
    if (_dashboardDataSubscription != null) {
      if (event.forceRefresh) {
        await _dashboardDataSubscription?.cancel();
      } else {
        // Already listening
        return;
      }
    }

    emit(DashboardLoading());

    _dashboardDataSubscription =
        Rx.combineLatest2(
          getAccounts(),
          getTransactions(),
          (accountsResult, transactionsResult) =>
              (accountsResult, transactionsResult),
        ).listen(
          (results) {
            final (accountsResult, transactionsResult) = results;

            accountsResult.fold(
              (failure) => add(DashboardErrorOccurred(failure)),
              (accounts) {
                transactionsResult.fold(
                  (failure) => add(DashboardErrorOccurred(failure)),
                  (transactions) => add(
                    DashboardDataUpdated(
                      accounts: accounts,
                      transactions: transactions,
                    ),
                  ),
                );
              },
            );
          },
          onError: (error) {
            add(
              DashboardErrorOccurred(
                GenericFailure(error?.toString() ?? 'Unknown error'),
              ),
            );
          },
        );
  }

  Future<void> _onDataUpdated(
    DashboardDataUpdated event,
    Emitter<DashboardState> emit,
  ) async {
    _lastAccounts = event.accounts;
    _lastTransactions = event.transactions;

    final filteredAccounts = _selectedAccountIds.isEmpty
        ? event.accounts
        : event.accounts
              .where((a) => _selectedAccountIds.contains(a.id))
              .toList();

    final filteredTransactions = _selectedAccountIds.isEmpty
        ? event.transactions
        : event.transactions.where((tx) {
            final fromMatch =
                tx.accountFrom != null &&
                _selectedAccountIds.contains(tx.accountFrom);
            final toMatch =
                tx.accountTo != null &&
                _selectedAccountIds.contains(tx.accountTo);
            return fromMatch || toMatch;
          }).toList();

    final summary = getDashboardSummary(
      accounts: filteredAccounts,
      transactions: filteredTransactions,
    );

    emit(DashboardLoaded(summary, selectedAccountIds: _selectedAccountIds));
  }

  Future<void> _onDashboardErrorOccurred(
    DashboardErrorOccurred event,
    Emitter<DashboardState> emit,
  ) async {
    emit(DashboardError(event.failure));
  }

  Future<void> _onFilterAccountsRequested(
    DashboardFilterAccountsRequested event,
    Emitter<DashboardState> emit,
  ) async {
    _selectedAccountIds = event.selectedAccountIds;
    if (_lastAccounts != null && _lastTransactions != null) {
      add(
        DashboardDataUpdated(
          accounts: _lastAccounts!,
          transactions: _lastTransactions!,
        ),
      );
    }
  }

  @override
  Future<void> close() {
    _dashboardDataSubscription?.cancel();
    return super.close();
  }
}
