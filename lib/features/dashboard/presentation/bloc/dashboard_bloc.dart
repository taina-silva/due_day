import 'dart:async';

import 'package:due_day/core/errors/failures.dart';
import 'package:due_day/features/accounts/domain/usecases/account_usecases.dart';
import 'package:due_day/features/categories/domain/entities/category_entity.dart';
import 'package:due_day/features/categories/domain/usecases/category_usecases.dart';
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
  final GetCategories getCategories;
  final DateTime Function() _now;

  List<String> _selectedAccountIds = [];
  late DateTime _selectedMonth;
  List<TransactionEntity>? _lastTransactions;
  List<CategoryEntity>? _lastCategories;
  StreamSubscription? _dashboardDataSubscription;

  DashboardBloc({
    required this.getDashboardSummary,
    required this.getAccounts,
    required this.getTransactions,
    required this.getCategories,
    DateTime Function()? now,
  }) : _now = now ?? DateTime.now,
       super(DashboardInitial()) {
    final today = _now();
    _selectedMonth = DateTime(today.year, today.month);
    on<DashboardLoadRequested>(_onLoadRequested);
    on<DashboardFilterAccountsRequested>(_onFilterAccountsRequested);
    on<DashboardMonthChanged>(_onMonthChanged);
    on<DashboardDataUpdated>(_onDataUpdated);
    on<DashboardErrorOccurred>(_onDashboardErrorOccurred);
  }

  /// First day of the month on screen (DSH-001).
  DateTime get selectedMonth => _selectedMonth;

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

    // Accounts are still listened to so the account filter keeps working;
    // they carry no amounts (DSH-007).
    _dashboardDataSubscription =
        Rx.combineLatest3(
          getAccounts(),
          getTransactions(),
          getCategories(),
          (accountsResult, transactionsResult, categoriesResult) =>
              (accountsResult, transactionsResult, categoriesResult),
        ).listen(
          (results) {
            final (accountsResult, transactionsResult, categoriesResult) =
                results;
            final failure =
                accountsResult.getLeft().toNullable() ??
                transactionsResult.getLeft().toNullable() ??
                categoriesResult.getLeft().toNullable();
            if (failure != null) {
              add(DashboardErrorOccurred(failure));
              return;
            }
            add(
              DashboardDataUpdated(
                transactions: transactionsResult.getOrElse((_) => const []),
                categories: categoriesResult.getOrElse((_) => const []),
              ),
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

  void _onDataUpdated(
    DashboardDataUpdated event,
    Emitter<DashboardState> emit,
  ) {
    _lastTransactions = event.transactions;
    _lastCategories = event.categories;
    _emitSummary(emit);
  }

  void _emitSummary(Emitter<DashboardState> emit) {
    final transactions = _lastTransactions;
    final categories = _lastCategories;
    if (transactions == null || categories == null) return;

    final filteredTransactions = _selectedAccountIds.isEmpty
        ? transactions
        : transactions.where((tx) {
            final fromMatch =
                tx.accountFrom != null &&
                _selectedAccountIds.contains(tx.accountFrom);
            final toMatch =
                tx.accountTo != null &&
                _selectedAccountIds.contains(tx.accountTo);
            return fromMatch || toMatch;
          }).toList();

    final summary = getDashboardSummary(
      month: _selectedMonth,
      transactions: filteredTransactions,
      categories: categories,
      now: _now(),
    );

    emit(DashboardLoaded(summary, selectedAccountIds: _selectedAccountIds));
  }

  Future<void> _onDashboardErrorOccurred(
    DashboardErrorOccurred event,
    Emitter<DashboardState> emit,
  ) async {
    emit(DashboardError(event.failure));
  }

  void _onFilterAccountsRequested(
    DashboardFilterAccountsRequested event,
    Emitter<DashboardState> emit,
  ) {
    _selectedAccountIds = event.selectedAccountIds;
    _emitSummary(emit);
  }

  void _onMonthChanged(
    DashboardMonthChanged event,
    Emitter<DashboardState> emit,
  ) {
    _selectedMonth = DateTime(event.month.year, event.month.month);
    _emitSummary(emit);
  }

  @override
  Future<void> close() {
    _dashboardDataSubscription?.cancel();
    return super.close();
  }
}
