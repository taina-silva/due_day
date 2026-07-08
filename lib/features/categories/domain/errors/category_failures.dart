import 'package:due_day/core/errors/failures.dart';

class CategoryNotFoundFailure extends Failure {
  const CategoryNotFoundFailure([super.message = 'Category not found.']);
}

class UserNotAuthenticatedFailure extends Failure {
  const UserNotAuthenticatedFailure([
    super.message = 'User not authenticated.',
  ]);
}

class CategoryOperationFailure extends Failure {
  const CategoryOperationFailure([
    super.message = 'Category operation failed.',
  ]);
}
