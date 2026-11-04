import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:due_day/core/errors/exceptions.dart';
import 'package:firebase_auth/firebase_auth.dart';

abstract class UserDataRemoteDataSource {
  /// Deletes `accounts`, `categories`, and `transactions` under
  /// `/users/{uid}` (SET-001). The user document itself stays.
  Future<void> deleteAll();
}

class UserDataRemoteDataSourceImpl implements UserDataRemoteDataSource {
  /// Firestore allows 500 writes per batch; stay below it.
  static const int maxWritesPerBatch = 450;
  static const List<String> collections = [
    'accounts',
    'categories',
    'transactions',
  ];

  final FirebaseFirestore firestore;
  final FirebaseAuth firebaseAuth;

  UserDataRemoteDataSourceImpl({
    required this.firestore,
    required this.firebaseAuth,
  });

  @override
  Future<void> deleteAll() async {
    try {
      final user = firebaseAuth.currentUser;
      if (user == null) {
        throw const ServerException(
          'User not authenticated.',
          'unauthenticated',
        );
      }
      final userDoc = firestore.collection('users').doc(user.uid);

      for (final name in collections) {
        final snapshot = await userDoc.collection(name).get();
        final refs = snapshot.docs.map((doc) => doc.reference).toList();
        for (var i = 0; i < refs.length; i += maxWritesPerBatch) {
          final batch = firestore.batch();
          final end = (i + maxWritesPerBatch).clamp(0, refs.length);
          for (final ref in refs.sublist(i, end)) {
            batch.delete(ref);
          }
          await batch.commit();
        }
      }
    } on ServerException {
      rethrow;
    } on FirebaseException catch (e) {
      throw ServerException(e.message ?? 'Failed to delete user data.', e.code);
    } catch (e) {
      throw ServerException('Failed to delete user data: $e');
    }
  }
}
