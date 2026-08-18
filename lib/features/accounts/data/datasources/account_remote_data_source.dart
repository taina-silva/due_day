import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:due_day/core/errors/exceptions.dart';
import 'package:due_day/features/accounts/data/models/account_model.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:rxdart/rxdart.dart';

abstract class AccountRemoteDataSource {
  Future<AccountModel> addAccount(AccountModel account);
  Future<AccountModel> updateAccount(AccountModel account);
  Future<void> deleteAccount(String accountId);
  Future<AccountModel> getAccountById(String accountId);
  Stream<List<AccountModel>> getAccounts();
}

class AccountRemoteDataSourceImpl implements AccountRemoteDataSource {
  final FirebaseFirestore firestore;
  final FirebaseAuth firebaseAuth;

  AccountRemoteDataSourceImpl({
    required this.firestore,
    required this.firebaseAuth,
  });

  String get _userId {
    final user = firebaseAuth.currentUser;
    if (user == null) {
      throw const ServerException('User not authenticated.', 'unauthenticated');
    }
    return user.uid;
  }

  CollectionReference<Map<String, dynamic>> get _collection =>
      firestore.collection('users').doc(_userId).collection('accounts');

  @override
  Future<AccountModel> addAccount(AccountModel account) async {
    try {
      final docRef = _collection.doc(account.id);
      await docRef.set(account.toJson());
      return account;
    } on ServerException {
      rethrow;
    } on FirebaseException catch (e) {
      throw ServerException(e.message ?? 'Failed to add account.', e.code);
    } catch (e) {
      throw ServerException('Failed to add account: $e');
    }
  }

  @override
  Future<AccountModel> updateAccount(AccountModel account) async {
    try {
      final docRef = _collection.doc(account.id);
      await docRef.update(account.toJson());
      return account;
    } on ServerException {
      rethrow;
    } on FirebaseException catch (e) {
      throw ServerException(e.message ?? 'Failed to update account.', e.code);
    } catch (e) {
      throw ServerException('Failed to update account: $e');
    }
  }

  @override
  Future<void> deleteAccount(String accountId) async {
    try {
      await _collection.doc(accountId).update({
        'deletedAt': FieldValue.serverTimestamp(),
      });
    } on ServerException {
      rethrow;
    } on FirebaseException catch (e) {
      throw ServerException(e.message ?? 'Failed to delete account.', e.code);
    } catch (e) {
      throw ServerException('Failed to delete account: $e');
    }
  }

  @override
  Future<AccountModel> getAccountById(String accountId) async {
    try {
      final doc = await _collection.doc(accountId).get();
      if (!doc.exists) {
        throw const ServerException('Account not found.', 'not-found');
      }
      return AccountModel.fromJson(doc.data()!);
    } on ServerException {
      rethrow;
    } on FirebaseException catch (e) {
      throw ServerException(e.message ?? 'Failed to retrieve account.', e.code);
    } catch (e) {
      throw ServerException('Failed to retrieve account: $e');
    }
  }

  @override
  Stream<List<AccountModel>> getAccounts() {
    // Switches the underlying Firestore listener to the signed-in user's
    // own collection whenever the auth session changes, so a listener from
    // a previous account never lingers (and never trips permission-denied)
    // after logout/login.
    return firebaseAuth.authStateChanges().switchMap((user) {
      if (user == null) {
        return Stream<List<AccountModel>>.value(const []);
      }

      return firestore
          .collection('users')
          .doc(user.uid)
          .collection('accounts')
          .snapshots()
          .map((snapshot) {
            return snapshot.docs
                .map((doc) => AccountModel.fromJson(doc.data()))
                .toList();
          });
    }).handleError((Object e) {
      if (e is FirebaseException) {
        throw ServerException(e.message ?? 'Failed to fetch accounts.', e.code);
      }
      throw ServerException('Failed to fetch accounts: $e');
    });
  }
}
