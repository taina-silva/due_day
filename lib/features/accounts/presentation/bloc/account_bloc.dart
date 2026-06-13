import 'dart:async';

import 'package:due_day/features/accounts/domain/entities/account_entity.dart';
import 'package:due_day/features/accounts/domain/usecases/account_usecases.dart';
import 'package:due_day/features/accounts/presentation/bloc/account_event.dart';
import 'package:due_day/features/accounts/presentation/bloc/account_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AccountBloc extends Bloc<AccountEvent, AccountState> {
  final AddAccount addAccount;
  final UpdateAccount updateAccount;
  final DeleteAccount deleteAccount;
  final GetAccounts getAccounts;

  StreamSubscription? _accountsSubscription;

  AccountBloc({
    required this.addAccount,
    required this.updateAccount,
    required this.deleteAccount,
    required this.getAccounts,
  }) : super(AccountInitial()) {
    on<LoadAccounts>(_onLoadAccounts);
    on<AddAccountEvent>(_onAddAccount);
    on<UpdateAccountEvent>(_onUpdateAccount);
    on<DeleteAccountEvent>(_onDeleteAccount);
    on<AccountLoadFailed>(_onAccountLoadFailed);
    on<_AccountsUpdated>(_onAccountsUpdated);
  }

  void _onLoadAccounts(LoadAccounts event, Emitter<AccountState> emit) {
    emit(AccountLoading());
    _accountsSubscription?.cancel();
    _accountsSubscription = getAccounts().listen((result) {
      result.fold(
        (failure) => add(AccountLoadFailed(failure.message)),
        (accounts) => add(_AccountsUpdated(accounts)),
      );
    });
  }

  void _onAccountLoadFailed(
    AccountLoadFailed event,
    Emitter<AccountState> emit,
  ) {
    emit(AccountError(message: event.message));
  }

  void _onAccountsUpdated(_AccountsUpdated event, Emitter<AccountState> emit) {
    emit(AccountLoaded(accounts: event.accounts));
  }

  Future<void> _onAddAccount(
    AddAccountEvent event,
    Emitter<AccountState> emit,
  ) async {
    final result = await addAccount(event.account);
    result.fold(
      (failure) => emit(AccountError(message: failure.message)),
      (_) {}, // Snapshot stream atualiza sozinho
    );
  }

  Future<void> _onUpdateAccount(
    UpdateAccountEvent event,
    Emitter<AccountState> emit,
  ) async {
    final result = await updateAccount(event.account);
    result.fold(
      (failure) => emit(AccountError(message: failure.message)),
      (_) {},
    );
  }

  Future<void> _onDeleteAccount(
    DeleteAccountEvent event,
    Emitter<AccountState> emit,
  ) async {
    final result = await deleteAccount(event.accountId);
    result.fold(
      (failure) => emit(AccountError(message: failure.message)),
      (_) {},
    );
  }

  @override
  Future<void> close() {
    _accountsSubscription?.cancel();
    return super.close();
  }
}

class _AccountsUpdated extends AccountEvent {
  final List<AccountEntity> accounts;
  const _AccountsUpdated(this.accounts);

  @override
  List<Object> get props => [accounts];
}
