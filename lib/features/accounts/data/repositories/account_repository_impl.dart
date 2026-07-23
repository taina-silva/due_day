import 'package:due_day/core/errors/exceptions.dart';
import 'package:due_day/core/errors/failures.dart';
import 'package:due_day/core/observability/observability_service.dart';
import 'package:due_day/features/accounts/data/datasources/account_remote_data_source.dart';
import 'package:due_day/features/accounts/data/models/account_model.dart';
import 'package:due_day/features/accounts/domain/entities/account_entity.dart';
import 'package:due_day/features/accounts/domain/errors/account_failures.dart';
import 'package:due_day/features/accounts/domain/repositories/account_repository.dart';
import 'package:fpdart/fpdart.dart';

class AccountRepositoryImpl implements AccountRepository {
  final AccountRemoteDataSource remoteDataSource;
  final ObservabilityService observability;

  static const String _tag = 'accounts';

  AccountRepositoryImpl({
    required this.remoteDataSource,
    required this.observability,
  });

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
      observability.error(
        'addAccount failed',
        tag: _tag,
        error: e,
        stackTrace: StackTrace.current,
      );
      return Left(_mapServerExceptionToFailure(e));
    } catch (e, stackTrace) {
      observability.error(
        'addAccount unexpected failure',
        tag: _tag,
        error: e,
        stackTrace: stackTrace,
      );
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
      observability.error(
        'updateAccount failed',
        tag: _tag,
        error: e,
        stackTrace: StackTrace.current,
      );
      return Left(_mapServerExceptionToFailure(e));
    } catch (e, stackTrace) {
      observability.error(
        'updateAccount unexpected failure',
        tag: _tag,
        error: e,
        stackTrace: stackTrace,
      );
      return Left(GenericFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> deleteAccount(String accountId) async {
    try {
      await remoteDataSource.deleteAccount(accountId);
      return const Right(null);
    } on ServerException catch (e) {
      observability.error(
        'deleteAccount failed',
        tag: _tag,
        error: e,
        stackTrace: StackTrace.current,
      );
      return Left(_mapServerExceptionToFailure(e));
    } catch (e, stackTrace) {
      observability.error(
        'deleteAccount unexpected failure',
        tag: _tag,
        error: e,
        stackTrace: stackTrace,
      );
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
      observability.error(
        'getAccountById failed',
        tag: _tag,
        error: e,
        stackTrace: StackTrace.current,
      );
      return Left(_mapServerExceptionToFailure(e));
    } catch (e, stackTrace) {
      observability.error(
        'getAccountById unexpected failure',
        tag: _tag,
        error: e,
        stackTrace: stackTrace,
      );
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
      observability.error(
        'getAccounts stream failed',
        tag: _tag,
        error: e,
        stackTrace: StackTrace.current,
      );
      yield Left<Failure, List<AccountEntity>>(_mapServerExceptionToFailure(e));
    } catch (e, stackTrace) {
      observability.error(
        'getAccounts stream unexpected failure',
        tag: _tag,
        error: e,
        stackTrace: stackTrace,
      );
      yield Left<Failure, List<AccountEntity>>(GenericFailure(e.toString()));
    }
  }
}
