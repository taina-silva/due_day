# Notifications Configuration (notifications.md)

This document describes how notifications are handled in **DueDay**, covering local OS reminders for due dates, the local (Hive-backed) notifications inbox, and permission configuration. There is no push/FCM integration — everything is on-device.

---

## 🔔 1. Local Notifications

Local reminders alert users about transactions that are about to reach their due date. They are managed through `NotificationService` (`lib/core/services/notification_service.dart`) using the `flutter_local_notifications` package.

### 1.1. Service Initialization
During app startup, the service initializes time zones and registers channel details:
- **Android Settings:** Hooks into `@mipmap/ic_launcher` and defines a high-importance channel (`dueday_reminders`).
- **iOS Settings:** Configures initial permission requests for alert sound, badge count, and notifications overlay.

### 1.2. Scheduling Reminders
Reminders are scheduled for future dates using timezone-aware dates:
```dart
Future<void> scheduleTransactionReminder({
  required int id,
  required String title,
  required String body,
  required DateTime scheduledDate,
}) async {
  if (scheduledDate.isBefore(DateTime.now())) return;

  await _plugin.zonedSchedule(
    id: id,
    title: title,
    body: body,
    scheduledDate: tz.TZDateTime.from(scheduledDate, tz.local),
    notificationDetails: const NotificationDetails(
      android: AndroidNotificationDetails(
        'dueday_reminders',
        'DueDay Reminders',
        channelDescription: 'DueDay transaction payment reminders channel',
        importance: Importance.max,
        priority: Priority.high,
      ),
      iOS: DarwinNotificationDetails(),
    ),
    androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
  );
}
```

---

## 📥 2. Notifications Inbox (Local/Hive)

The notification history shown on the "Notifications" screen (`lib/features/notifications/`) is 100% local, persisted in a Hive `Box<Map>` (`hive_ce`/`hive_ce_flutter`) — it does not depend on the network or Firestore. Authentication still goes through `FirebaseAuth`, but only to filter notifications for the current user.

### 2.1. Data Layer
- **`NotificationsLocalDataSource`** (`data/datasources/notifications_local_data_source.dart`): interface with `addNotification`, `markAsRead`, `deleteNotification`, and `getNotifications()` (reactive stream via `box.watch()`).
- The box is opened once in `injection_container.dart` (`Hive.initFlutter()` + `Hive.openBox<Map>('notifications_box')`) and injected as a `Box<Map>` singleton.
- `NotificationModel` already serializes to a plain `Map<String, dynamic>` via `toJson()`/`fromJson()` (no Hive `TypeAdapter`/codegen needed).
- Retains only the last 100 notifications on the device — on insert, entries beyond the limit are automatically removed.
- Exceptions: `CacheException` → mapped to `CacheFailure` in the repository (`NotificationsRepositoryImpl`).

### 2.2. Bloc (`NotificationsBloc`)
Events: `LoadNotifications`, `MarkAsReadEvent`, `DeleteNotificationEvent`. The page (`NotificationsPage`) allows deleting a notification via swipe (`Dismissible`).

---

## 🔑 3. Notification Payloads & Deep Linking

To redirect users to detailed pages when they tap a notification:
1.  **Payload Map:** Include routing parameters (e.g. `{"route": "/transactions/schedule"}`) in the data payload.
2.  **GoRouter Integration:** In `app_router.dart`, handle initial notification clicks and run context redirects to the targeted tab index or page.
3.  **Permission Guards:** Ensure that if a user opens the app through a notification deep link, authentication redirects execute first before showing the target page.
