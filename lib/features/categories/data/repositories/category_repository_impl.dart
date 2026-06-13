import 'package:due_day/core/errors/exceptions.dart';
import 'package:due_day/core/errors/failures.dart';
import 'package:due_day/features/categories/data/datasources/category_remote_data_source.dart';
import 'package:due_day/features/categories/data/models/category_model.dart';
import 'package:due_day/features/categories/domain/entities/category_entity.dart';
import 'package:due_day/features/categories/domain/repositories/category_repository.dart';
import 'package:fpdart/fpdart.dart';

class CategoryRepositoryImpl implements CategoryRepository {
  final CategoryRemoteDataSource remoteDataSource;

  CategoryRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, CategoryEntity>> addCategory(
    CategoryEntity category,
  ) async {
    try {
      final model = CategoryModel.fromEntity(category);
      final result = await remoteDataSource.addCategory(model);
      return Right(result.toEntity());
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
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
      return Left(ServerFailure(e.message));
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
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(GenericFailure(e.toString()));
    }
  }

  @override
  Stream<Either<Failure, List<CategoryEntity>>> getCategories() {
    return remoteDataSource
        .getCategories()
        .map(
          (models) => Right<Failure, List<CategoryEntity>>(
            models.map((m) => m.toEntity()).toList(),
          ),
        )
        .handleError((error) {
          return Left<Failure, List<CategoryEntity>>(
            ServerFailure(error.toString()),
          );
        });
  }
}
