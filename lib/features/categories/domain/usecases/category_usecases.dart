import 'package:due_day/core/errors/failures.dart';
import 'package:due_day/features/categories/domain/entities/category_entity.dart';
import 'package:due_day/features/categories/domain/entities/category_kind.dart';
import 'package:due_day/features/categories/domain/entities/system_categories.dart';
import 'package:due_day/features/categories/domain/errors/category_failures.dart';
import 'package:due_day/features/categories/domain/repositories/category_repository.dart';
import 'package:fpdart/fpdart.dart';

class AddCategory {
  final CategoryRepository repository;
  AddCategory(this.repository);

  /// User-created categories are always `spending` and never system
  /// (CAT-001, CAT-003).
  Future<Either<Failure, CategoryEntity>> call(CategoryEntity category) async {
    if (category.isSystem || category.kind != CategoryKind.spending) {
      return const Left(SystemCategoryProtectedFailure());
    }
    return repository.addCategory(category);
  }
}

class UpdateCategory {
  final CategoryRepository repository;
  UpdateCategory(this.repository);

  /// System categories keep their stored name and kind; only color and
  /// icon can change (CAT-003).
  Future<Either<Failure, CategoryEntity>> call(CategoryEntity category) async {
    if (category.isSystem &&
        (category.name != SystemCategories.storedNameFor(category.id) ||
            category.kind != SystemCategories.kindFor(category.id))) {
      return const Left(SystemCategoryProtectedFailure());
    }
    return repository.updateCategory(category);
  }
}

class DeleteCategory {
  final CategoryRepository repository;
  DeleteCategory(this.repository);

  Future<Either<Failure, void>> call(String categoryId) async {
    if (SystemCategories.isSystemId(categoryId)) {
      return const Left(SystemCategoryProtectedFailure());
    }
    return repository.deleteCategory(categoryId);
  }
}

class GetCategories {
  final CategoryRepository repository;
  GetCategories(this.repository);

  Stream<Either<Failure, List<CategoryEntity>>> call() {
    return repository.getCategories();
  }
}
