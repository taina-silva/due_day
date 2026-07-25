import 'package:due_day/core/errors/failures.dart';

class AccountNotFoundFailure extends Failure {
  const AccountNotFoundFailure([super.message = 'Account not found.']);
}

class UserNotAuthenticatedFailure extends Failure {
  const UserNotAuthenticatedFailure([
    super.message = 'User not authenticated.',
  ]);
}

class AccountSaveFailure extends Failure {
  const AccountSaveFailure([super.message = 'Failed to save account.']);
}

class AccountDeleteFailure extends Failure {
  const AccountDeleteFailure([super.message = 'Failed to delete account.']);
}
