import 'package:due_day/core/errors/exceptions.dart';
import 'package:due_day/core/errors/failures.dart';
import 'package:due_day/features/accounts/data/datasources/account_remote_data_source.dart';
import 'package:due_day/features/accounts/data/models/account_model.dart';
import 'package:due_day/features/accounts/domain/entities/account_entity.dart';
import 'package:due_day/features/accounts/domain/errors/account_failures.dart';
import 'package:due_day/features/accounts/domain/repositories/account_repository.dart';
import 'package:fpdart/fpdart.dart';

class AccountRepositoryImpl implements AccountRepository {
  final AccountRemoteDataSource remoteDataSource;

  AccountRepositoryImpl({required this.remoteDataSource});

  Failure _mapServerExceptionToFailure(ServerException e) {
    if (e.code == 'unauthenticated' || e.message.contains('authenticated')) {
      return const UserNotAuthenticatedFailure();
    }
    if (e.code == 'not-found' || e.message.contains('not found')) {
      return const AccountNotFoundFailure();
    }
    return ServerFailure(e.message);
  }

  @override
  Future<Either<Failure, AccountEntity>> addAccount(
    AccountEntity account,
  ) async {
    try {
      final model = AccountModel.fromEntity(account);
      final result = await remoteDataSource.addAccount(model);
      return Right(result.toEntity());
    } on ServerException catch (e) {
      return Left(_mapServerExceptionToFailure(e));
    } catch (e) {
      return Left(GenericFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, AccountEntity>> updateAccount(
    AccountEntity account,
  ) async {
    try {
      final model = AccountModel.fromEntity(account);
      final result = await remoteDataSource.updateAccount(model);
      return Right(result.toEntity());
    } on ServerException catch (e) {
      return Left(_mapServerExceptionToFailure(e));
    } catch (e) {
      return Left(GenericFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> deleteAccount(String accountId) async {
    try {
      await remoteDataSource.deleteAccount(accountId);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(_mapServerExceptionToFailure(e));
    } catch (e) {
      return Left(GenericFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, AccountEntity>> getAccountById(
    String accountId,
  ) async {
    try {
      final result = await remoteDataSource.getAccountById(accountId);
      return Right(result.toEntity());
    } on ServerException catch (e) {
      return Left(_mapServerExceptionToFailure(e));
    } catch (e) {
      return Left(GenericFailure(e.toString()));
    }
  }

  @override
  Stream<Either<Failure, List<AccountEntity>>> getAccounts() async* {
    try {
      await for (final models in remoteDataSource.getAccounts()) {
        yield Right<Failure, List<AccountEntity>>(
          models.map((m) => m.toEntity()).toList(),
        );
      }
    } on ServerException catch (e) {
      yield Left<Failure, List<AccountEntity>>(_mapServerExceptionToFailure(e));
    } catch (e) {
      yield Left<Failure, List<AccountEntity>>(GenericFailure(e.toString()));
    }
  }
}
