import 'package:due_day/features/accounts/domain/usecases/account_usecases.dart';
import 'package:due_day/features/accounts/presentation/bloc/account_action_event.dart';
import 'package:due_day/features/accounts/presentation/bloc/account_action_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AccountActionBloc extends Bloc<AccountActionEvent, AccountActionState> {
  final AddAccount addAccount;
  final UpdateAccount updateAccount;
  final DeleteAccount deleteAccount;

  AccountActionBloc({
    required this.addAccount,
    required this.updateAccount,
    required this.deleteAccount,
  }) : super(AccountActionInitial()) {
    on<AddAccountEvent>(_onAddAccount);
    on<UpdateAccountEvent>(_onUpdateAccount);
    on<DeleteAccountEvent>(_onDeleteAccount);
  }

  Future<void> _onAddAccount(
    AddAccountEvent event,
    Emitter<AccountActionState> emit,
  ) async {
    emit(AccountActionInProgress());
    final result = await addAccount(event.account);
    result.fold(
      (failure) => emit(AccountActionError(failure: failure)),
      (_) => emit(AccountActionSuccess()),
    );
  }

  Future<void> _onUpdateAccount(
    UpdateAccountEvent event,
    Emitter<AccountActionState> emit,
  ) async {
    emit(AccountActionInProgress());
    final result = await updateAccount(event.account);
    result.fold(
      (failure) => emit(AccountActionError(failure: failure)),
      (_) => emit(AccountActionSuccess()),
    );
  }

  Future<void> _onDeleteAccount(
    DeleteAccountEvent event,
    Emitter<AccountActionState> emit,
  ) async {
    emit(AccountActionInProgress());
    final result = await deleteAccount(event.accountId);
    result.fold(
      (failure) => emit(AccountActionError(failure: failure)),
      (_) => emit(AccountActionSuccess()),
    );
  }
}
