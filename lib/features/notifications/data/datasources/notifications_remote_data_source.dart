import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:due_day/core/errors/exceptions.dart';
import 'package:due_day/features/notifications/data/models/notification_model.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:rxdart/rxdart.dart';

abstract class NotificationsRemoteDataSource {
  Future<void> addNotification(NotificationModel notification);
  Future<void> markAsRead(String notificationId);
  Stream<List<NotificationModel>> getNotifications();
}

class NotificationsRemoteDataSourceImpl implements NotificationsRemoteDataSource {
  final FirebaseFirestore firestore;
  final FirebaseAuth firebaseAuth;

  NotificationsRemoteDataSourceImpl({
    required this.firestore,
    required this.firebaseAuth,
  });

  String get _userId {
    final user = firebaseAuth.currentUser;
    if (user == null) throw const ServerException('Usuário não autenticado.');
    return user.uid;
  }

  CollectionReference<Map<String, dynamic>> get _collection =>
      firestore.collection('users').doc(_userId).collection('notifications');

  @override
  Future<void> addNotification(NotificationModel notification) async {
    try {
      await _collection.doc(notification.id).set(notification.toJson());
    } catch (e) {
      throw ServerException('Erro ao salvar notificação: $e');
    }
  }

  @override
  Future<void> markAsRead(String notificationId) async {
    try {
      await _collection.doc(notificationId).update({'read': true});
    } catch (e) {
      throw ServerException('Erro ao atualizar notificação: $e');
    }
  }

  @override
  Stream<List<NotificationModel>> getNotifications() {
    return firebaseAuth.authStateChanges().switchMap((user) {
      if (user == null) {
        return Stream.value(<NotificationModel>[]);
      }
      final now = DateTime.now();
      return firestore
          .collection('users')
          .doc(user.uid)
          .collection('notifications')
          .where('timestamp', isLessThanOrEqualTo: Timestamp.fromDate(now))
          .orderBy('timestamp', descending: true)
          .snapshots()
          .map((snapshot) {
        return snapshot.docs
            .map((doc) => NotificationModel.fromJson(doc.data()))
            .toList();
      });
    });
  }
}
