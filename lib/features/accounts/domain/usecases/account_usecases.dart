import 'package:due_day/core/errors/failures.dart';
import 'package:due_day/features/accounts/domain/entities/account_entity.dart';
import 'package:due_day/features/accounts/domain/repositories/account_repository.dart';
import 'package:fpdart/fpdart.dart';

class AddAccount {
  final AccountRepository repository;
  AddAccount(this.repository);

  Future<Either<Failure, AccountEntity>> call(AccountEntity account) {
    return repository.addAccount(account);
  }
}

class UpdateAccount {
  final AccountRepository repository;
  UpdateAccount(this.repository);

  Future<Either<Failure, AccountEntity>> call(AccountEntity account) {
    return repository.updateAccount(account);
  }
}

class DeleteAccount {
  final AccountRepository repository;
  DeleteAccount(this.repository);

  Future<Either<Failure, void>> call(String accountId) {
    return repository.deleteAccount(accountId);
  }
}

class GetAccounts {
  final AccountRepository repository;
  GetAccounts(this.repository);

  Stream<Either<Failure, List<AccountEntity>>> call() {
    return repository.getAccounts();
  }
}
