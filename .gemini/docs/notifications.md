# Notifications Configuration (notifications.md)

This document describes how notifications are handled in **DueDay**, covering local reminders for due dates, push notifications via Firebase Cloud Messaging (FCM), and permission configuration.

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

## ☁️ 2. Firebase Cloud Messaging (FCM)

For server-triggered push alerts, the application integrates with `firebase_messaging`.

### 2.1. FCM Bloc Integration (`NotificationsBloc`)
The notifications feature folder (`lib/features/notifications/`) uses `NotificationsBloc` to manage token generation and push payload events:
- **`LoadNotifications`:** Triggers token registration, updates user settings in Firestore `/users/{userId}`, and requests permissions.
- **`firebase_messaging` Streams:** BLoCs listen to foreground message alerts (`FirebaseMessaging.onMessage`) and click redirections (`FirebaseMessaging.onMessageOpenedApp`).

---

## 🔑 3. Notification Payloads & Deep Linking

To redirect users to detailed pages when they tap a notification:
1.  **Payload Map:** Include routing parameters (e.g. `{"route": "/transactions/schedule"}`) in the data payload.
2.  **GoRouter Integration:** In `app_router.dart`, handle initial notification clicks and run context redirects to the targeted tab index or page.
3.  **Permission Guards:** Ensure that if a user opens the app through a notification deep link, authentication redirects execute first before showing the target page.
