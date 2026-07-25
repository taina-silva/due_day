import 'package:due_day/core/errors/exceptions.dart';
import 'package:due_day/core/errors/failures.dart';
import 'package:due_day/core/observability/observability_service.dart';
import 'package:due_day/features/categories/data/datasources/category_remote_data_source.dart';
import 'package:due_day/features/categories/data/models/category_model.dart';
import 'package:due_day/features/categories/domain/entities/category_entity.dart';
import 'package:due_day/features/categories/domain/errors/category_failures.dart';
import 'package:due_day/features/categories/domain/repositories/category_repository.dart';
import 'package:fpdart/fpdart.dart';

class CategoryRepositoryImpl implements CategoryRepository {
  final CategoryRemoteDataSource remoteDataSource;
  final ObservabilityService observability;

  static const String _tag = 'categories';

  CategoryRepositoryImpl({
    required this.remoteDataSource,
    required this.observability,
  });

  // [fallback] is operation-specific: load reads (getCategories) fall back
  // to a generic ServerFailure, while add/update/delete fall back to
  // CategorySaveFailure/CategoryDeleteFailure so the action bottom sheet can
  // show wording distinct from the load-stream error text.
  Failure _mapServerExceptionToFailure(
    ServerException e, {
    required Failure fallback,
  }) {
    if (e.code == 'unauthenticated' || e.message.contains('authenticated')) {
      return const UserNotAuthenticatedFailure();
    }
    if (e.code == 'not-found' || e.message.contains('not found')) {
      return const CategoryNotFoundFailure();
    }
    return fallback;
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
      observability.error(
        'addCategory failed',
        tag: _tag,
        error: e,
        stackTrace: StackTrace.current,
      );
      return Left(
        _mapServerExceptionToFailure(
          e,
          fallback: CategorySaveFailure(e.message),
        ),
      );
    } catch (e, stackTrace) {
      observability.error(
        'addCategory unexpected failure',
        tag: _tag,
        error: e,
        stackTrace: stackTrace,
      );
      return Left(CategorySaveFailure(e.toString()));
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
      observability.error(
        'updateCategory failed',
        tag: _tag,
        error: e,
        stackTrace: StackTrace.current,
      );
      return Left(
        _mapServerExceptionToFailure(
          e,
          fallback: CategorySaveFailure(e.message),
        ),
      );
    } catch (e, stackTrace) {
      observability.error(
        'updateCategory unexpected failure',
        tag: _tag,
        error: e,
        stackTrace: stackTrace,
      );
      return Left(CategorySaveFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> deleteCategory(String categoryId) async {
    try {
      await remoteDataSource.deleteCategory(categoryId);
      return const Right(null);
    } on ServerException catch (e) {
      observability.error(
        'deleteCategory failed',
        tag: _tag,
        error: e,
        stackTrace: StackTrace.current,
      );
      return Left(
        _mapServerExceptionToFailure(
          e,
          fallback: CategoryDeleteFailure(e.message),
        ),
      );
    } catch (e, stackTrace) {
      observability.error(
        'deleteCategory unexpected failure',
        tag: _tag,
        error: e,
        stackTrace: stackTrace,
      );
      return Left(CategoryDeleteFailure(e.toString()));
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
      observability.error(
        'getCategories stream failed',
        tag: _tag,
        error: e,
        stackTrace: StackTrace.current,
      );
      yield Left<Failure, List<CategoryEntity>>(
        _mapServerExceptionToFailure(e, fallback: ServerFailure(e.message)),
      );
    } catch (e, stackTrace) {
      observability.error(
        'getCategories stream unexpected failure',
        tag: _tag,
        error: e,
        stackTrace: stackTrace,
      );
      yield Left<Failure, List<CategoryEntity>>(GenericFailure(e.toString()));
    }
  }
}
