---
name: add-notification
description: Use when triggering or scheduling on-device notifications in DueDay (payment due reminders, notification inbox entries); there is no push/FCM. Covers NotificationService scheduling, cancellation, and the Hive-backed notifications inbox.
---

# Add Notification

How it works: [notifications.md](../../docs/notifications.md). All titles and bodies come from l10n.

## OS reminder

```dart
await sl<NotificationService>().scheduleTransactionReminder(
  id: transaction.id.hashCode,
  title: l10n.reminderTitle,
  body: l10n.reminderBody(description, amount),
  scheduledDate: dueDate.subtract(const Duration(days: 1)),
);
```

To cancel, use `cancelAll()` and reschedule what's still pending. Specific ids aren't tracked.

## Inbox entry (Hive)

```dart
await sl<AddNotification>()(NotificationEntity(
  id: '${transaction.id}_due_today',
  userId: transaction.userId,
  title: l10n.transactionsNotificationDueTodayTitle,
  description: l10n.transactionsNotificationDueTodayBody(description, amount),
  timestamp: DateTime.now(),
  read: false,
  isUrgent: true,
  type: NotificationType.dueToday,
));
```

Remove entries with `DeleteNotification`. Only the latest 100 are kept.
