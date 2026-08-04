import 'dart:io';

import 'package:due_day/features/notifications/data/datasources/notifications_local_data_source.dart';
import 'package:due_day/features/notifications/data/models/notification_model.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive_ce/hive.dart';
import 'package:mocktail/mocktail.dart';

import '../../helpers/notifications_test_helpers.dart';

void main() {
  late Directory tempDir;
  late Box<Map> box;
  late MockFirebaseAuth mockFirebaseAuth;
  late MockUser mockUser;
  late NotificationsLocalDataSourceImpl dataSource;

  NotificationModel buildModel({
    required String id,
    String userId = 'user-1',
    DateTime? timestamp,
    bool read = false,
  }) {
    return NotificationModel(
      id: id,
      userId: userId,
      title: 'Title $id',
      description: 'Description $id',
      timestamp: timestamp ?? DateTime(2026, 7, 7),
      read: read,
      isUrgent: false,
      type: 'dueToday',
    );
  }

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('notifications_hive_test');
    Hive.init(tempDir.path);
    box = await Hive.openBox<Map>('notifications_test_box');

    mockFirebaseAuth = MockFirebaseAuth();
    mockUser = MockUser();
    when(() => mockUser.uid).thenReturn('user-1');
    when(() => mockFirebaseAuth.currentUser).thenReturn(mockUser);

    dataSource = NotificationsLocalDataSourceImpl(
      box: box,
      firebaseAuth: mockFirebaseAuth,
    );
  });

  tearDown(() async {
    await box.close();
    await Hive.deleteBoxFromDisk('notifications_test_box');
    await tempDir.delete(recursive: true);
  });

  group('addNotification', () {
    test(
      'given a notification when addNotification is called then it is persisted in the box',
      () async {
        final model = buildModel(id: 'n1');

        await dataSource.addNotification(model);

        final stored = box.get('n1');
        expect(stored, isNotNull);
        expect(
          NotificationModel.fromJson(Map<String, dynamic>.from(stored!)),
          model,
        );
      },
    );

    test(
      'given a notification already marked as read when addNotification is called again with the same id then the read status is preserved',
      () async {
        await dataSource.addNotification(buildModel(id: 'n1'));
        await dataSource.markAsRead('n1');

        await dataSource.addNotification(buildModel(id: 'n1', read: false));

        final updated = NotificationModel.fromJson(
          Map<String, dynamic>.from(box.get('n1')!),
        );
        expect(updated.read, isTrue);
      },
    );

    test(
      'given more than 100 notifications when addNotification is called then only the last 100 are kept',
      () async {
        for (var i = 0; i < 100; i++) {
          await dataSource.addNotification(
            buildModel(
              id: 'n$i',
              timestamp: DateTime(2026, 1, 1).add(Duration(days: i)),
            ),
          );
        }
        expect(box.length, 100);

        await dataSource.addNotification(
          buildModel(
            id: 'n100',
            timestamp: DateTime(2026, 1, 1).add(const Duration(days: 100)),
          ),
        );

        expect(box.length, 100);
        expect(box.containsKey('n0'), isFalse);
        expect(box.containsKey('n100'), isTrue);
      },
    );
  });

  group('markAsRead', () {
    test(
      'given an existing notification when markAsRead is called then read becomes true',
      () async {
        await dataSource.addNotification(buildModel(id: 'n1'));

        await dataSource.markAsRead('n1');

        final updated = NotificationModel.fromJson(
          Map<String, dynamic>.from(box.get('n1')!),
        );
        expect(updated.read, isTrue);
      },
    );

    test(
      'given a non-existent id when markAsRead is called then nothing happens',
      () async {
        await dataSource.markAsRead('missing');

        expect(box.containsKey('missing'), isFalse);
      },
    );
  });

  group('markAllAsRead', () {
    test(
      'given unread notifications for the current user when markAllAsRead is called then all become read',
      () async {
        await dataSource.addNotification(buildModel(id: 'n1'));
        await dataSource.addNotification(buildModel(id: 'n2'));
        await dataSource.addNotification(buildModel(id: 'n3', read: true));

        await dataSource.markAllAsRead();

        final n1 = NotificationModel.fromJson(
          Map<String, dynamic>.from(box.get('n1')!),
        );
        final n2 = NotificationModel.fromJson(
          Map<String, dynamic>.from(box.get('n2')!),
        );
        expect(n1.read, isTrue);
        expect(n2.read, isTrue);
      },
    );

    test(
      'given notifications from another user when markAllAsRead is called then they remain untouched',
      () async {
        await dataSource.addNotification(
          buildModel(id: 'n1', userId: 'other-user'),
        );

        await dataSource.markAllAsRead();

        final n1 = NotificationModel.fromJson(
          Map<String, dynamic>.from(box.get('n1')!),
        );
        expect(n1.read, isFalse);
      },
    );

    test(
      'given no authenticated user when markAllAsRead is called then nothing changes',
      () async {
        await dataSource.addNotification(buildModel(id: 'n1'));
        when(() => mockFirebaseAuth.currentUser).thenReturn(null);

        await dataSource.markAllAsRead();

        final n1 = NotificationModel.fromJson(
          Map<String, dynamic>.from(box.get('n1')!),
        );
        expect(n1.read, isFalse);
      },
    );
  });

  group('deleteNotification', () {
    test(
      'given an existing notification when deleteNotification is called then it is removed',
      () async {
        await dataSource.addNotification(buildModel(id: 'n1'));

        await dataSource.deleteNotification('n1');

        expect(box.containsKey('n1'), isFalse);
      },
    );
  });

  group('getNotifications', () {
    test(
      'given notifications for the current user when getNotifications is called then it emits them ordered by timestamp desc',
      () async {
        await dataSource.addNotification(
          buildModel(id: 'n1', timestamp: DateTime(2026, 1, 1)),
        );
        await dataSource.addNotification(
          buildModel(id: 'n2', timestamp: DateTime(2026, 1, 3)),
        );
        await dataSource.addNotification(
          buildModel(
            id: 'n3',
            userId: 'other-user',
            timestamp: DateTime(2026, 1, 2),
          ),
        );

        final result = await dataSource.getNotifications().first;

        expect(result.map((m) => m.id).toList(), ['n2', 'n1']);
      },
    );

    test(
      'given a change in the box when getNotifications stream is listened then it re-emits',
      () async {
        final results = <List<NotificationModel>>[];
        final subscription = dataSource.getNotifications().listen(results.add);

        await Future.delayed(Duration.zero);
        await dataSource.addNotification(buildModel(id: 'n1'));
        await Future.delayed(Duration.zero);

        expect(results.length, greaterThanOrEqualTo(2));
        expect(results.last.map((m) => m.id), contains('n1'));

        await subscription.cancel();
      },
    );

    test(
      'given no authenticated user when getNotifications is called then it emits an empty list',
      () async {
        when(() => mockFirebaseAuth.currentUser).thenReturn(null);
        await dataSource.addNotification(buildModel(id: 'n1'));

        final result = await dataSource.getNotifications().first;

        expect(result, isEmpty);
      },
    );
  });
}
