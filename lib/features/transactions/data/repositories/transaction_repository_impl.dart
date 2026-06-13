import 'package:due_day/core/errors/exceptions.dart';
import 'package:due_day/core/errors/failures.dart';
import 'package:due_day/features/transactions/data/datasources/transaction_remote_data_source.dart';
import 'package:due_day/features/transactions/data/models/transaction_model.dart';
import 'package:due_day/features/transactions/domain/entities/transaction_entity.dart';
import 'package:due_day/features/transactions/domain/repositories/transaction_repository.dart';
import 'package:fpdart/fpdart.dart';

class TransactionRepositoryImpl implements TransactionRepository {
  final TransactionRemoteDataSource remoteDataSource;

  TransactionRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, TransactionEntity>> addTransaction(
    TransactionEntity transaction,
  ) async {
    try {
      final model = TransactionModel.fromEntity(transaction);
      final result = await remoteDataSource.addTransaction(model);
      return Right(result.toEntity());
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(GenericFailure(e.toString()));
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
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(GenericFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> deleteTransaction(String transactionId) async {
    try {
      await remoteDataSource.deleteTransaction(transactionId);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(GenericFailure(e.toString()));
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
      return Left(ServerFailure(e.message));
    } catch (e) {
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
  }) {
    return remoteDataSource
        .getTransactions(
          startDate: startDate,
          endDate: endDate,
          categoryId: categoryId,
          type: type?.name,
          frequency: frequency?.name,
        )
        .map(
          (models) => Right<Failure, List<TransactionEntity>>(
            models.map((m) => m.toEntity()).toList(),
          ),
        )
        .handleError((error) {
          return Left<Failure, List<TransactionEntity>>(
            ServerFailure(error.toString()),
          );
        });
  }
}
