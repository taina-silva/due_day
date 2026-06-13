import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:due_day/core/errors/exceptions.dart';
import 'package:due_day/features/accounts/data/models/account_model.dart';
import 'package:firebase_auth/firebase_auth.dart';

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
      throw const ServerException('Usuário não autenticado.');
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
    } catch (e) {
      throw ServerException('Erro ao adicionar conta: $e');
    }
  }

  @override
  Future<AccountModel> updateAccount(AccountModel account) async {
    try {
      final docRef = _collection.doc(account.id);
      await docRef.update(account.toJson());
      return account;
    } catch (e) {
      throw ServerException('Erro ao atualizar conta: $e');
    }
  }

  @override
  Future<void> deleteAccount(String accountId) async {
    try {
      await _collection.doc(accountId).update({
        'deletedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw ServerException('Erro ao deletar conta: $e');
    }
  }

  @override
  Future<AccountModel> getAccountById(String accountId) async {
    try {
      final doc = await _collection.doc(accountId).get();
      if (!doc.exists) {
        throw const ServerException('Conta não encontrada.');
      }
      return AccountModel.fromJson(doc.data()!);
    } catch (e) {
      throw ServerException('Erro ao buscar conta: $e');
    }
  }

  @override
  Stream<List<AccountModel>> getAccounts() {
    try {
      return _collection.snapshots().map((snapshot) {
        return snapshot.docs
            .map((doc) => AccountModel.fromJson(doc.data()))
            .toList();
      });
    } catch (e) {
      throw ServerException('Erro ao buscar contas: $e');
    }
  }
}
