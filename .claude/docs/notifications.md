# Notifications

Everything is on-device. There is no push/FCM. Recipe: [add-notification](../skills/add-notification/SKILL.md).

## OS reminders

- `NotificationService` (`lib/core/services/notification_service.dart`), using `flutter_local_notifications`.
- Initializes time zones and the Android channel `dueday_reminders`; requests iOS permissions.
- `scheduleTransactionReminder(id, title, body, scheduledDate)` uses `zonedSchedule` (exact, allow while idle) and skips dates in the past.
- Reminders are rescheduled by `TransactionLoadBloc` when transactions load (cancel all, then reschedule).
- Tapping a notification does not deep-link anywhere yet.

## Inbox

The "Notifications" screen (`lib/features/notifications/`) is stored locally in **Hive**, not Firestore.

- Box `notifications_box` (`Box<Map>`), opened in `injection_container.dart`.
- `NotificationsLocalDataSource`: `addNotification`, `markAsRead`, `deleteNotification`, `getNotifications()` (stream via `box.watch()`).
- `NotificationModel` serializes with `toJson`/`fromJson` (no Hive adapter).
- Keeps only the latest **100** entries per device.
- Filtered by the current Firebase user.
- `CacheException` → `CacheFailure`.
- BLoCs: `NotificationsLoadBloc` + `NotificationsActionBloc` (mark read, delete via swipe).
