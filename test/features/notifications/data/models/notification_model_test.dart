import 'package:due_day/features/notifications/data/models/notification_model.dart';
import 'package:due_day/features/notifications/domain/entities/notification_entity.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final tDateTime = DateTime(2026, 7, 7, 8, 0);

  final tNotificationModel = NotificationModel(
    id: 'notification-1',
    userId: 'user-1',
    title: 'Bill due today!',
    description: 'Your bill is due today.',
    timestamp: tDateTime,
    read: false,
    isUrgent: true,
    type: 'dueToday',
  );

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

  final tJson = {
    'id': 'notification-1',
    'userId': 'user-1',
    'title': 'Bill due today!',
    'description': 'Your bill is due today.',
    'timestamp': tDateTime.toIso8601String(),
    'read': false,
    'isUrgent': true,
    'type': 'dueToday',
  };

  test(
    'given a valid json when fromJson is called then return a matching NotificationModel',
    () {
      final result = NotificationModel.fromJson(tJson);
      expect(result, tNotificationModel);
    },
  );

  test(
    'given a NotificationModel when toJson is called then return a matching json map',
    () {
      final result = tNotificationModel.toJson();
      expect(result, tJson);
    },
  );

  test(
    'given a NotificationEntity when fromEntity is called then return a matching NotificationModel',
    () {
      final result = NotificationModel.fromEntity(tNotificationEntity);
      expect(result, tNotificationModel);
    },
  );

  test(
    'given a NotificationModel when toEntity is called then return a matching NotificationEntity',
    () {
      final result = tNotificationModel.toEntity();
      expect(result, tNotificationEntity);
    },
  );

  test(
    'given two NotificationModel instances with the same values when compared then they are equal',
    () {
      final other = NotificationModel(
        id: 'notification-1',
        userId: 'user-1',
        title: 'Bill due today!',
        description: 'Your bill is due today.',
        timestamp: tDateTime,
        read: false,
        isUrgent: true,
        type: 'dueToday',
      );
      expect(tNotificationModel, other);
    },
  );

  test(
    'given an unknown type string when fromJson is called then default to upcomingDue',
    () {
      final result = NotificationModel.fromJson({...tJson, 'type': 'unknown'});
      expect(result.toEntity().type, NotificationType.upcomingDue);
    },
  );
}
