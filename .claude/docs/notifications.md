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

## 📥 2. Inbox de Notificações (Local/Hive)

O histórico de notificações exibido na tela "Notificações" (`lib/features/notifications/`) é 100% local, persistido em um `Box<Map>` do Hive (`hive_ce`/`hive_ce_flutter`) — não depende de rede nem do Firestore. A autenticação continua via `FirebaseAuth` apenas para filtrar notificações do usuário atual.

### 2.1. Camada de dados
- **`NotificationsLocalDataSource`** (`data/datasources/notifications_local_data_source.dart`): interface com `addNotification`, `markAsRead`, `deleteNotification` e `getNotifications()` (stream reativa via `box.watch()`).
- A box é aberta uma única vez em `injection_container.dart` (`Hive.initFlutter()` + `Hive.openBox<Map>('notifications_box')`) e injetada como `Box<Map>` singleton.
- `NotificationModel` já serializa para `Map<String, dynamic>` puro via `toJson()`/`fromJson()` (sem `TypeAdapter`/codegen do Hive necessário).
- Retém apenas as últimas 100 notificações no dispositivo — ao inserir, entradas mais antigas além do limite são removidas automaticamente.
- Exceções: `CacheException` → mapeada para `CacheFailure` no repositório (`NotificationsRepositoryImpl`).

### 2.2. Bloc (`NotificationsBloc`)
Eventos: `LoadNotifications`, `MarkAsReadEvent`, `DeleteNotificationEvent`. A página (`NotificationsPage`) permite excluir uma notificação com swipe (`Dismissible`).

---

## 🔑 3. Notification Payloads & Deep Linking

To redirect users to detailed pages when they tap a notification:
1.  **Payload Map:** Include routing parameters (e.g. `{"route": "/transactions/schedule"}`) in the data payload.
2.  **GoRouter Integration:** In `app_router.dart`, handle initial notification clicks and run context redirects to the targeted tab index or page.
3.  **Permission Guards:** Ensure that if a user opens the app through a notification deep link, authentication redirects execute first before showing the target page.
