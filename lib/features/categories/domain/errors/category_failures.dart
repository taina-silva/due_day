import 'package:due_day/core/errors/failures.dart';

class CategoryNotFoundFailure extends Failure {
  const CategoryNotFoundFailure([super.message = 'Category not found.']);
}

class UserNotAuthenticatedFailure extends Failure {
  const UserNotAuthenticatedFailure([
    super.message = 'User not authenticated.',
  ]);
}

class CategorySaveFailure extends Failure {
  const CategorySaveFailure([super.message = 'Failed to save category.']);
}

class CategoryDeleteFailure extends Failure {
  const CategoryDeleteFailure([super.message = 'Failed to delete category.']);
}
