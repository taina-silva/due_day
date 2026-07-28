import 'package:due_day/core/errors/failures.dart';

class TransactionNotFoundFailure extends Failure {
  const TransactionNotFoundFailure([super.message = 'Transaction not found.']);
}

class UserNotAuthenticatedFailure extends Failure {
  const UserNotAuthenticatedFailure([
    super.message = 'User not authenticated.',
  ]);
}

class TransactionSaveFailure extends Failure {
  const TransactionSaveFailure([super.message = 'Failed to save transaction.']);
}

class TransactionDeleteFailure extends Failure {
  const TransactionDeleteFailure([
    super.message = 'Failed to delete transaction.',
  ]);
}
