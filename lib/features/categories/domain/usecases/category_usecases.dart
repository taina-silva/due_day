import 'package:due_day/core/errors/failures.dart';
import 'package:due_day/features/categories/domain/entities/category_entity.dart';
import 'package:due_day/features/categories/domain/repositories/category_repository.dart';
import 'package:fpdart/fpdart.dart';

class AddCategory {
  final CategoryRepository repository;
  AddCategory(this.repository);

  Future<Either<Failure, CategoryEntity>> call(CategoryEntity category) {
    return repository.addCategory(category);
  }
}

class UpdateCategory {
  final CategoryRepository repository;
  UpdateCategory(this.repository);

  Future<Either<Failure, CategoryEntity>> call(CategoryEntity category) {
    return repository.updateCategory(category);
  }
}

class DeleteCategory {
  final CategoryRepository repository;
  DeleteCategory(this.repository);

  Future<Either<Failure, void>> call(String categoryId) {
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
