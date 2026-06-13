import 'package:due_day/features/accounts/domain/entities/account_entity.dart';
import 'package:equatable/equatable.dart';

abstract class AccountEvent extends Equatable {
  const AccountEvent();

  @override
  List<Object> get props => [];
}

class LoadAccounts extends AccountEvent {}

class AddAccountEvent extends AccountEvent {
  final AccountEntity account;
  const AddAccountEvent(this.account);

  @override
  List<Object> get props => [account];
}

class UpdateAccountEvent extends AccountEvent {
  final AccountEntity account;
  const UpdateAccountEvent(this.account);

  @override
  List<Object> get props => [account];
}

class DeleteAccountEvent extends AccountEvent {
  final String accountId;
  const DeleteAccountEvent(this.accountId);

  @override
  List<Object> get props => [accountId];
}

class AccountLoadFailed extends AccountEvent {
  final String message;
  const AccountLoadFailed(this.message);

  @override
  List<Object> get props => [message];
}
