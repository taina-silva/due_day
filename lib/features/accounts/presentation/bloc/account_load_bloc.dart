import 'dart:async';

import 'package:due_day/features/accounts/domain/usecases/account_usecases.dart';
import 'package:due_day/features/accounts/presentation/bloc/account_load_event.dart';
import 'package:due_day/features/accounts/presentation/bloc/account_load_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AccountLoadBloc extends Bloc<AccountLoadEvent, AccountLoadState> {
  final GetAccounts getAccounts;

  StreamSubscription? _accountsSubscription;

  AccountLoadBloc({required this.getAccounts}) : super(AccountInitial()) {
    on<LoadAccounts>(_onLoadAccounts);
    on<AccountsUpdated>(_onAccountsUpdated);
    on<AccountLoadFailed>(_onAccountLoadFailed);
  }

  void _onLoadAccounts(LoadAccounts event, Emitter<AccountLoadState> emit) {
    emit(AccountLoading());
    _accountsSubscription?.cancel();
    _accountsSubscription = getAccounts().listen((result) {
      result.fold(
        (failure) => add(AccountLoadFailed(failure)),
        (accounts) => add(AccountsUpdated(accounts)),
      );
    });
  }

  void _onAccountsUpdated(
    AccountsUpdated event,
    Emitter<AccountLoadState> emit,
  ) {
    emit(AccountLoaded(accounts: event.accounts));
  }

  void _onAccountLoadFailed(
    AccountLoadFailed event,
    Emitter<AccountLoadState> emit,
  ) {
    emit(AccountError(failure: event.failure));
  }

  @override
  Future<void> close() {
    _accountsSubscription?.cancel();
    return super.close();
  }
}
