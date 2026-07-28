import 'package:due_day/core/errors/failures.dart';

class NotificationSaveFailure extends Failure {
  const NotificationSaveFailure([
    super.message = 'Failed to save notification.',
  ]);
}

class NotificationDeleteFailure extends Failure {
  const NotificationDeleteFailure([
    super.message = 'Failed to delete notification.',
  ]);
}
