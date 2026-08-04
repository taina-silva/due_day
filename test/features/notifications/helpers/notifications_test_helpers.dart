import 'package:due_day/features/notifications/data/datasources/notifications_local_data_source.dart';
import 'package:due_day/features/notifications/domain/entities/notification_entity.dart';
import 'package:due_day/features/notifications/domain/repositories/notifications_repository.dart';
import 'package:due_day/features/notifications/domain/usecases/notification_usecases.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:mocktail/mocktail.dart';

class MockNotificationsLocalDataSource extends Mock
    implements NotificationsLocalDataSource {}

class MockNotificationsRepository extends Mock
    implements NotificationsRepository {}

class MockFirebaseAuth extends Mock implements FirebaseAuth {}

class MockUser extends Mock implements User {}

class MockGetNotifications extends Mock implements GetNotifications {}

class MockAddNotification extends Mock implements AddNotification {}

class MockMarkNotificationAsRead extends Mock
    implements MarkNotificationAsRead {}

class MockMarkAllNotificationsAsRead extends Mock
    implements MarkAllNotificationsAsRead {}

class MockDeleteNotification extends Mock implements DeleteNotification {}

final tDateTime = DateTime(2026, 7, 7, 8, 0);

final tNotificationEntity = NotificationEntity(
  id: 'notification-1',
  userId: 'user-1',
  title: 'Bill due today!',
  description: 'Your bill is due today.',
  timestamp: tDateTime,
  read: false,
  isUrgent: true,
  type: NotificationType.dueToday,
);
