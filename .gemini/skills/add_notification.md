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

### Phase 2: Remote Push Alerts
1.  **Configure FCM Handler:** Add custom events inside `lib/features/notifications/presentation/bloc/notifications_bloc.dart` to handle incoming foreground messages:
    ```dart
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      add(PushReceivedEvent(message.data));
    });
    ```
2.  **Register Device FCM Token:** Sync client tokens with Firestore when users sign in:
    ```dart
    final token = await FirebaseMessaging.instance.getToken();
    await firestore.collection('users').doc(userId).update({'fcm_token': token});
    ```
3.  **Handle Click Action:** Define route redirection on clicks inside `app_router.dart`.
