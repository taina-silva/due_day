import 'package:due_day/core/errors/exceptions.dart';
import 'package:due_day/core/errors/failures.dart';
import 'package:due_day/features/categories/data/datasources/category_remote_data_source.dart';
import 'package:due_day/features/categories/data/models/category_model.dart';
import 'package:due_day/features/categories/domain/entities/category_entity.dart';
import 'package:due_day/features/categories/domain/errors/category_failures.dart';
import 'package:due_day/features/categories/domain/repositories/category_repository.dart';
import 'package:fpdart/fpdart.dart';

class CategoryRepositoryImpl implements CategoryRepository {
  final CategoryRemoteDataSource remoteDataSource;

  CategoryRepositoryImpl({required this.remoteDataSource});

  Failure _mapServerExceptionToFailure(ServerException e) {
    if (e.code == 'unauthenticated' || e.message.contains('authenticated')) {
      return const UserNotAuthenticatedFailure();
    }
    if (e.code == 'not-found' || e.message.contains('not found')) {
      return const CategoryNotFoundFailure();
    }
    return ServerFailure(e.message);
  }

  @override
  Future<Either<Failure, CategoryEntity>> addCategory(
    CategoryEntity category,
  ) async {
    try {
      final model = CategoryModel.fromEntity(category);
      final result = await remoteDataSource.addCategory(model);
      return Right(result.toEntity());
    } on ServerException catch (e) {
      return Left(_mapServerExceptionToFailure(e));
    } catch (e) {
      return Left(GenericFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, CategoryEntity>> updateCategory(
    CategoryEntity category,
  ) async {
    try {
      final model = CategoryModel.fromEntity(category);
      final result = await remoteDataSource.updateCategory(model);
      return Right(result.toEntity());
    } on ServerException catch (e) {
      return Left(_mapServerExceptionToFailure(e));
    } catch (e) {
      return Left(GenericFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> deleteCategory(String categoryId) async {
    try {
      await remoteDataSource.deleteCategory(categoryId);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(_mapServerExceptionToFailure(e));
    } catch (e) {
      return Left(GenericFailure(e.toString()));
    }
  }

  @override
  Stream<Either<Failure, List<CategoryEntity>>> getCategories() async* {
    try {
      await for (final models in remoteDataSource.getCategories()) {
        yield Right<Failure, List<CategoryEntity>>(
          models.map((m) => m.toEntity()).toList(),
        );
      }
    } on ServerException catch (e) {
      yield Left<Failure, List<CategoryEntity>>(
        _mapServerExceptionToFailure(e),
      );
    } catch (e) {
      yield Left<Failure, List<CategoryEntity>>(GenericFailure(e.toString()));
    }
  }
}
