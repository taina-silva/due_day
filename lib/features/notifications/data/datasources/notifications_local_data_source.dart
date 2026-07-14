import 'package:due_day/core/errors/exceptions.dart';
import 'package:due_day/features/notifications/data/models/notification_model.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:hive_ce/hive.dart';

const int kMaxStoredNotifications = 100;

abstract class NotificationsLocalDataSource {
  Future<void> addNotification(NotificationModel notification);
  Future<void> markAsRead(String notificationId);
  Future<void> deleteNotification(String notificationId);
  Stream<List<NotificationModel>> getNotifications();
}

class NotificationsLocalDataSourceImpl implements NotificationsLocalDataSource {
  final Box<Map> box;
  final FirebaseAuth firebaseAuth;

  NotificationsLocalDataSourceImpl({required this.box, required this.firebaseAuth});

  @override
  Future<void> addNotification(NotificationModel notification) async {
    try {
      await box.put(notification.id, notification.toJson());
      await _enforceMaxSize();
    } catch (e) {
      throw CacheException('Erro ao salvar notificação: $e');
    }
  }

  @override
  Future<void> markAsRead(String notificationId) async {
    try {
      final json = box.get(notificationId);
      if (json == null) return;
      await box.put(notificationId, {...json, 'read': true});
    } catch (e) {
      throw CacheException('Erro ao atualizar notificação: $e');
    }
  }

  @override
  Future<void> deleteNotification(String notificationId) async {
    try {
      await box.delete(notificationId);
    } catch (e) {
      throw CacheException('Erro ao excluir notificação: $e');
    }
  }

  @override
  Stream<List<NotificationModel>> getNotifications() {
    return Stream.multi((controller) {
      void emit() => controller.add(_readNotifications());

      emit();
      final subscription = box.watch().listen((_) => emit());
      controller.onCancel = subscription.cancel;
    });
  }

  List<NotificationModel> _readNotifications() {
    final userId = firebaseAuth.currentUser?.uid;
    if (userId == null) return const [];

    final models = box.values
        .map((json) => NotificationModel.fromJson(Map<String, dynamic>.from(json)))
        .where((model) => model.userId == userId)
        .toList();
    models.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    return models;
  }

  Future<void> _enforceMaxSize() async {
    if (box.length <= kMaxStoredNotifications) return;

    final entries = box.keys
        .map((key) {
          final json = box.get(key);
          final timestamp = json == null
              ? DateTime.fromMillisecondsSinceEpoch(0)
              : NotificationModel.fromJson(Map<String, dynamic>.from(json)).timestamp;
          return MapEntry(key, timestamp);
        })
        .toList()
      ..sort((a, b) => a.value.compareTo(b.value));

    final overflow = box.length - kMaxStoredNotifications;
    final keysToRemove = entries.take(overflow).map((e) => e.key);
    await box.deleteAll(keysToRemove);
  }
}
