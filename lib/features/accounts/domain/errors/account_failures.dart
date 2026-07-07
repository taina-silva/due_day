import 'package:due_day/core/errors/failures.dart';

class AccountNotFoundFailure extends Failure {
  const AccountNotFoundFailure([super.message = 'Account not found.']);
}

class UserNotAuthenticatedFailure extends Failure {
  const UserNotAuthenticatedFailure([
    super.message = 'User not authenticated.',
  ]);
}
