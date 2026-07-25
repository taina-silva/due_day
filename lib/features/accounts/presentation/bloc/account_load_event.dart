import 'package:due_day/core/errors/failures.dart';
import 'package:due_day/features/accounts/domain/entities/account_entity.dart';
import 'package:equatable/equatable.dart';

abstract class AccountLoadEvent extends Equatable {
  const AccountLoadEvent();

  @override
  List<Object> get props => [];
}

class LoadAccounts extends AccountLoadEvent {}

class AccountsUpdated extends AccountLoadEvent {
  final List<AccountEntity> accounts;
  const AccountsUpdated(this.accounts);

  @override
  List<Object> get props => [accounts];
}

class AccountLoadFailed extends AccountLoadEvent {
  final Failure failure;
  const AccountLoadFailed(this.failure);

  @override
  List<Object> get props => [failure];
}
