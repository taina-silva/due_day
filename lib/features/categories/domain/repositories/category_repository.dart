import 'package:due_day/core/errors/failures.dart';
import 'package:due_day/features/categories/domain/entities/category_entity.dart';
import 'package:fpdart/fpdart.dart';

abstract class CategoryRepository {
  Future<Either<Failure, CategoryEntity>> addCategory(CategoryEntity category);
  Future<Either<Failure, CategoryEntity>> updateCategory(
    CategoryEntity category,
  );
  Future<Either<Failure, void>> deleteCategory(String categoryId);
  Stream<Either<Failure, List<CategoryEntity>>> getCategories();
}
