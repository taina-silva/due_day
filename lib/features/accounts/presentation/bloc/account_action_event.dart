import 'package:due_day/features/accounts/domain/entities/account_entity.dart';
import 'package:equatable/equatable.dart';

abstract class AccountActionEvent extends Equatable {
  const AccountActionEvent();

  @override
  List<Object> get props => [];
}

class AddAccountEvent extends AccountActionEvent {
  final AccountEntity account;
  const AddAccountEvent(this.account);

  @override
  List<Object> get props => [account];
}

class UpdateAccountEvent extends AccountActionEvent {
  final AccountEntity account;
  const UpdateAccountEvent(this.account);

  @override
  List<Object> get props => [account];
}

class DeleteAccountEvent extends AccountActionEvent {
  final String accountId;
  const DeleteAccountEvent(this.accountId);

  @override
  List<Object> get props => [accountId];
}
