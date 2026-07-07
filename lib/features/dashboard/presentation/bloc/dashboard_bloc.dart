import 'dart:async';

import 'package:due_day/features/accounts/presentation/bloc/account_bloc.dart';
import 'package:due_day/features/accounts/presentation/bloc/account_event.dart';
import 'package:due_day/features/accounts/presentation/bloc/account_state.dart';
import 'package:due_day/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:due_day/features/auth/presentation/bloc/auth_state.dart';
import 'package:due_day/features/dashboard/domain/usecases/get_dashboard_summary.dart';
import 'package:due_day/features/dashboard/presentation/bloc/dashboard_event.dart';
import 'package:due_day/features/dashboard/presentation/bloc/dashboard_state.dart';
import 'package:due_day/features/transactions/domain/usecases/sync_recurring_transactions.dart';
import 'package:due_day/features/transactions/presentation/bloc/transaction_bloc.dart';
import 'package:due_day/features/transactions/presentation/bloc/transaction_event.dart';
import 'package:due_day/features/transactions/presentation/bloc/transaction_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class DashboardBloc extends Bloc<DashboardEvent, DashboardState> {
  final GetDashboardSummary getDashboardSummary;
  final SyncRecurringTransactions syncRecurringTransactions;
  final AccountBloc accountBloc;
  final TransactionBloc transactionBloc;
  final AuthBloc authBloc;

  List<String> _selectedAccountIds = [];

  StreamSubscription? _accountSubscription;
  StreamSubscription? _transactionSubscription;

  DashboardBloc({
    required this.getDashboardSummary,
    required this.syncRecurringTransactions,
    required this.accountBloc,
    required this.transactionBloc,
    required this.authBloc,
  }) : super(DashboardInitial()) {
    on<DashboardLoadRequested>(_onLoadRequested);
    on<DashboardSyncRecurringRequested>(_onSyncRecurringRequested);
    on<DashboardFilterAccountsRequested>(_onFilterAccountsRequested);

    // Listen to account and transaction changes to refresh dashboard
    _accountSubscription = accountBloc.stream.listen((state) {
      if (state is AccountLoaded || state is AccountError) {
        add(const DashboardLoadRequested());
      }
    });

    _transactionSubscription = transactionBloc.stream.listen((state) {
      if (state is TransactionLoaded || state is TransactionError) {
        add(const DashboardLoadRequested());
      }
    });
  }

  Future<void> _onLoadRequested(
    DashboardLoadRequested event,
    Emitter<DashboardState> emit,
  ) async {
    final accountState = accountBloc.state;
    final transactionState = transactionBloc.state;

    if (accountState is AccountLoaded &&
        transactionState is TransactionLoaded) {
      // Filter accounts
      final filteredAccounts = _selectedAccountIds.isEmpty
          ? accountState.activeAccounts
          : accountState.activeAccounts
                .where((a) => _selectedAccountIds.contains(a.id))
                .toList();

      // Filter transactions related to selected accounts
      final filteredTransactions = _selectedAccountIds.isEmpty
          ? transactionState.transactions
          : transactionState.transactions.where((tx) {
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
    } else if (accountState is AccountError) {
      emit(DashboardError(accountState.failure.message));
    } else if (transactionState is TransactionError) {
      emit(DashboardError(transactionState.message));
    } else {
      // Trigger load if initial
      if (accountState is AccountInitial) {
        accountBloc.add(LoadAccounts());
      }
      if (transactionState is TransactionInitial) {
        transactionBloc.add(const LoadTransactions());
      }

      // If data is not loaded yet and we are in an initial or error state, show loading
      if (state is DashboardInitial || state is DashboardError) {
        emit(DashboardLoading());
      }
    }
  }

  Future<void> _onSyncRecurringRequested(
    DashboardSyncRecurringRequested event,
    Emitter<DashboardState> emit,
  ) async {
    final authState = authBloc.state;
    if (authState is AuthAuthenticated) {
      await syncRecurringTransactions(authState.user.uid);
      // After sync, TransactionBloc will likely emit a new state,
      // which will trigger a reload via the subscription.
    }
  }

  Future<void> _onFilterAccountsRequested(
    DashboardFilterAccountsRequested event,
    Emitter<DashboardState> emit,
  ) async {
    _selectedAccountIds = event.selectedAccountIds;
    add(const DashboardLoadRequested());
  }

  @override
  Future<void> close() {
    _accountSubscription?.cancel();
    _transactionSubscription?.cancel();
    return super.close();
  }
}
