# Standard Procedure: Add Notification (add_notification.md)

This guide describes how to trigger and schedule local or push notifications in **DueDay**.

---

## 🛠️ Step-by-Step Notification Recipe

### Phase 1: Local Reminders
Use `NotificationService` to schedule alarms for payment due dates:

1.  **Retrieve Service Instance:** Resolve `NotificationService` from the service locator:
    ```dart
    final notificationService = sl<NotificationService>();
    ```
2.  **Trigger Scheduler:** When saving a scheduled transaction, trigger the alert:
    ```dart
    await notificationService.scheduleTransactionReminder(
      id: transaction.id.hashCode, // unique integer identifier
      title: 'Bill Due Tomorrow',
      body: 'Your bill for ${transaction.description} of \$${transaction.amount} is due.',
      scheduledDate: transaction.dueDate.subtract(const Duration(days: 1)),
    );
    ```
3.  **Cancel Alarms:** If a transaction is deleted or paid, cancel scheduled reminders:
    ```dart
    // Note: To cancel specific alarms, track scheduled IDs, or run cancelAll for simplicity.
    await notificationService.cancelAll();
    ```

### Phase 2: Local Notification History (Inbox)
Record the same event in the local notifications inbox (`hive_ce`-backed, no network round-trip) so it shows up in the "Notificações" page:

1.  **Add to history:** Resolve `AddNotification` from the service locator and call it with a `NotificationEntity`:
    ```dart
    await sl<AddNotification>()(
      NotificationEntity(
        id: '${transaction.id}_due_today',
        userId: transaction.userId,
        title: l10n.transactionsNotificationDueTodayTitle,
        description: l10n.transactionsNotificationDueTodayBody(description, amount),
        timestamp: DateTime.now(),
        read: false,
        isUrgent: true,
        type: NotificationType.dueToday,
      ),
    );
    ```
2.  **Delete when no longer relevant:** Use `DeleteNotification` (same pattern) to remove an entry — e.g. triggered by swipe-to-dismiss on `NotificationsPage`.
3.  Only the last 100 notifications are retained on-device; older entries are pruned automatically on insert.
