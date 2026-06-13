import 'package:due_day/features/accounts/domain/entities/account_entity.dart';
import 'package:equatable/equatable.dart';

abstract class AccountState extends Equatable {
  const AccountState();

  @override
  List<Object> get props => [];
}

class AccountInitial extends AccountState {}

class AccountLoading extends AccountState {}

class AccountLoaded extends AccountState {
  final List<AccountEntity> accounts;

  const AccountLoaded({required this.accounts});

  List<AccountEntity> get activeAccounts {
    final accountsActives = accounts.where((a) => a.deletedAt == null).toList();
    accountsActives.sort((a, b) => a.name.compareTo(b.name));
    return accountsActives;
  }

  @override
  List<Object> get props => [accounts];
}

class AccountError extends AccountState {
  final String message;

  const AccountError({required this.message});

  @override
  List<Object> get props => [message];
}
