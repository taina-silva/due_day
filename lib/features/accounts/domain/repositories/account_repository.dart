import 'package:due_day/core/errors/failures.dart';
import 'package:due_day/features/accounts/domain/entities/account_entity.dart';
import 'package:fpdart/fpdart.dart';

abstract class AccountRepository {
  Future<Either<Failure, AccountEntity>> addAccount(AccountEntity account);
  Future<Either<Failure, AccountEntity>> updateAccount(AccountEntity account);
  Future<Either<Failure, void>> deleteAccount(String accountId);
  Future<Either<Failure, AccountEntity>> getAccountById(String accountId);
  Stream<Either<Failure, List<AccountEntity>>> getAccounts();
}
