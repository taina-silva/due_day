import 'package:due_day/core/errors/failures.dart';

class InvalidCredentialsFailure extends Failure {
  const InvalidCredentialsFailure([super.message = 'Invalid credentials.']);
}

class EmailAlreadyInUseFailure extends Failure {
  const EmailAlreadyInUseFailure([super.message = 'Email already in use.']);
}

class WeakPasswordFailure extends Failure {
  const WeakPasswordFailure([super.message = 'Weak password.']);
}

class UserDisabledFailure extends Failure {
  const UserDisabledFailure([super.message = 'User disabled.']);
}

class AuthCancelledFailure extends Failure {
  const AuthCancelledFailure([super.message = 'Authentication cancelled.']);
}

class UserNotFoundFailure extends Failure {
  const UserNotFoundFailure([super.message = 'User not found.']);
}
