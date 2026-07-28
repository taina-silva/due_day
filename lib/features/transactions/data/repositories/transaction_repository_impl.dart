import 'package:due_day/core/errors/exceptions.dart';
import 'package:due_day/core/errors/failures.dart';
import 'package:due_day/core/observability/observability_service.dart';
import 'package:due_day/features/transactions/data/datasources/transaction_remote_data_source.dart';
import 'package:due_day/features/transactions/data/models/transaction_model.dart';
import 'package:due_day/features/transactions/domain/entities/transaction_entity.dart';
import 'package:due_day/features/transactions/domain/errors/transaction_failures.dart';
import 'package:due_day/features/transactions/domain/repositories/transaction_repository.dart';
import 'package:fpdart/fpdart.dart';

class TransactionRepositoryImpl implements TransactionRepository {
  final TransactionRemoteDataSource remoteDataSource;
  final ObservabilityService observability;

  static const String _tag = 'transactions';

  TransactionRepositoryImpl({
    required this.remoteDataSource,
    required this.observability,
  });

  // [fallback] is operation-specific: reads (getTransaction/getTransactions)
  // fall back to a generic ServerFailure, while add/update/delete fall back
  // to TransactionSaveFailure/TransactionDeleteFailure so the action bottom
  // sheet can show wording distinct from the load-stream error text.
  Failure _mapServerExceptionToFailure(
    ServerException e, {
    required Failure fallback,
  }) {
    if (e.code == 'unauthenticated' || e.message.contains('authenticated')) {
      return const UserNotAuthenticatedFailure();
    }
    if (e.code == 'not-found' || e.message.contains('not found')) {
      return const TransactionNotFoundFailure();
    }
    return fallback;
  }

  @override
  Future<Either<Failure, TransactionEntity>> addTransaction(
    TransactionEntity transaction,
  ) async {
    try {
      final model = TransactionModel.fromEntity(transaction);
      final result = await remoteDataSource.addTransaction(model);
      return Right(result.toEntity());
    } on ServerException catch (e) {
      observability.error(
        'addTransaction failed',
        tag: _tag,
        error: e,
        stackTrace: StackTrace.current,
      );
      return Left(
        _mapServerExceptionToFailure(
          e,
          fallback: TransactionSaveFailure(e.message),
        ),
      );
    } catch (e, stackTrace) {
      observability.error(
        'addTransaction unexpected failure',
        tag: _tag,
        error: e,
        stackTrace: stackTrace,
      );
      return Left(TransactionSaveFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, TransactionEntity>> updateTransaction(
    TransactionEntity transaction,
  ) async {
    try {
      final model = TransactionModel.fromEntity(transaction);
      final result = await remoteDataSource.updateTransaction(model);
      return Right(result.toEntity());
    } on ServerException catch (e) {
      observability.error(
        'updateTransaction failed',
        tag: _tag,
        error: e,
        stackTrace: StackTrace.current,
      );
      return Left(
        _mapServerExceptionToFailure(
          e,
          fallback: TransactionSaveFailure(e.message),
        ),
      );
    } catch (e, stackTrace) {
      observability.error(
        'updateTransaction unexpected failure',
        tag: _tag,
        error: e,
        stackTrace: stackTrace,
      );
      return Left(TransactionSaveFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> deleteTransaction(String transactionId) async {
    try {
      await remoteDataSource.deleteTransaction(transactionId);
      return const Right(null);
    } on ServerException catch (e) {
      observability.error(
        'deleteTransaction failed',
        tag: _tag,
        error: e,
        stackTrace: StackTrace.current,
      );
      return Left(
        _mapServerExceptionToFailure(
          e,
          fallback: TransactionDeleteFailure(e.message),
        ),
      );
    } catch (e, stackTrace) {
      observability.error(
        'deleteTransaction unexpected failure',
        tag: _tag,
        error: e,
        stackTrace: stackTrace,
      );
      return Left(TransactionDeleteFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, TransactionEntity>> getTransaction(
    String transactionId,
  ) async {
    try {
      final result = await remoteDataSource.getTransaction(transactionId);
      return Right(result.toEntity());
    } on ServerException catch (e) {
      observability.error(
        'getTransaction failed',
        tag: _tag,
        error: e,
        stackTrace: StackTrace.current,
      );
      return Left(
        _mapServerExceptionToFailure(e, fallback: ServerFailure(e.message)),
      );
    } catch (e, stackTrace) {
      observability.error(
        'getTransaction unexpected failure',
        tag: _tag,
        error: e,
        stackTrace: stackTrace,
      );
      return Left(GenericFailure(e.toString()));
    }
  }

  @override
  Stream<Either<Failure, List<TransactionEntity>>> getTransactions({
    DateTime? startDate,
    DateTime? endDate,
    String? categoryId,
    TransactionType? type,
    TransactionFrequency? frequency,
  }) async* {
    try {
      await for (final models in remoteDataSource.getTransactions(
        startDate: startDate,
        endDate: endDate,
        categoryId: categoryId,
        type: type?.name,
        frequency: frequency?.name,
      )) {
        yield Right<Failure, List<TransactionEntity>>(
          models.map((m) => m.toEntity()).toList(),
        );
      }
    } on ServerException catch (e) {
      observability.error(
        'getTransactions stream failed',
        tag: _tag,
        error: e,
        stackTrace: StackTrace.current,
      );
      yield Left<Failure, List<TransactionEntity>>(
        _mapServerExceptionToFailure(e, fallback: ServerFailure(e.message)),
      );
    } catch (e, stackTrace) {
      observability.error(
        'getTransactions stream unexpected failure',
        tag: _tag,
        error: e,
        stackTrace: stackTrace,
      );
      yield Left<Failure, List<TransactionEntity>>(ServerFailure(e.toString()));
    }
  }
}
