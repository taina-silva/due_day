import 'package:due_day/core/errors/failures.dart';

class TransactionNotFoundFailure extends Failure {
  const TransactionNotFoundFailure([super.message = 'Transaction not found.']);
}

class UserNotAuthenticatedFailure extends Failure {
  const UserNotAuthenticatedFailure([
    super.message = 'User not authenticated.',
  ]);
}

class TransactionOperationFailure extends Failure {
  const TransactionOperationFailure([
    super.message = 'Transaction operation failed.',
  ]);
}
