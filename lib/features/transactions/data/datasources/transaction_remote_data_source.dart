import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:due_day/core/errors/exceptions.dart';
import 'package:due_day/features/transactions/data/models/transaction_model.dart';
import 'package:firebase_auth/firebase_auth.dart';

abstract class TransactionRemoteDataSource {
  Future<TransactionModel> addTransaction(TransactionModel transaction);
  Future<TransactionModel> updateTransaction(TransactionModel transaction);
  Future<void> deleteTransaction(String transactionId);
  Future<TransactionModel> getTransaction(String transactionId);
  Stream<List<TransactionModel>> getTransactions({
    DateTime? startDate,
    DateTime? endDate,
    String? categoryId,
    String? type,
    String? frequency,
  });
}

class TransactionRemoteDataSourceImpl implements TransactionRemoteDataSource {
  final FirebaseFirestore firestore;
  final FirebaseAuth firebaseAuth;

  TransactionRemoteDataSourceImpl({
    required this.firestore,
    required this.firebaseAuth,
  });

  String get _userId {
    final user = firebaseAuth.currentUser;
    if (user == null) throw const ServerException('Usuário não autenticado.');
    return user.uid;
  }

  CollectionReference<Map<String, dynamic>> get _collection =>
      firestore.collection('users').doc(_userId).collection('transactions');

  CollectionReference<Map<String, dynamic>> get _categoriesCollection =>
      firestore.collection('users').doc(_userId).collection('categories');

  @override
  Future<TransactionModel> addTransaction(TransactionModel transaction) async {
    try {
      final docRef = _collection.doc(transaction.id);
      final batch = firestore.batch();

      batch.set(docRef, transaction.toJson());

      if (transaction.category != null && transaction.category!.isNotEmpty) {
        final categoryRef = _categoriesCollection.doc(transaction.category);
        batch.update(categoryRef, {
          'transactionCount': FieldValue.increment(1),
        });
      }

      await batch.commit();
      return transaction;
    } catch (e) {
      throw ServerException('Erro ao adicionar transação: $e');
    }
  }

  @override
  Future<TransactionModel> updateTransaction(
    TransactionModel transaction,
  ) async {
    try {
      final oldTransaction = await getTransaction(transaction.id);
      final docRef = _collection.doc(transaction.id);
      final batch = firestore.batch();

      batch.update(docRef, transaction.toJson());

      // Update category counts if the category changed
      if (oldTransaction.category != transaction.category) {
        if (oldTransaction.category != null &&
            oldTransaction.category!.isNotEmpty) {
          final oldCategoryRef = _categoriesCollection.doc(
            oldTransaction.category,
          );
          batch.update(oldCategoryRef, {
            'transactionCount': FieldValue.increment(-1),
          });
        }
        if (transaction.category != null && transaction.category!.isNotEmpty) {
          final newCategoryRef = _categoriesCollection.doc(
            transaction.category,
          );
          batch.update(newCategoryRef, {
            'transactionCount': FieldValue.increment(1),
          });
        }
      }

      await batch.commit();
      return transaction;
    } catch (e) {
      throw ServerException('Erro ao atualizar transação: $e');
    }
  }

  @override
  Future<void> deleteTransaction(String transactionId) async {
    try {
      final oldTransaction = await getTransaction(transactionId);
      final docRef = _collection.doc(transactionId);
      final batch = firestore.batch();

      batch.delete(docRef);

      if (oldTransaction.category != null &&
          oldTransaction.category!.isNotEmpty) {
        final categoryRef = _categoriesCollection.doc(oldTransaction.category);
        batch.update(categoryRef, {
          'transactionCount': FieldValue.increment(-1),
        });
      }

      await batch.commit();
    } catch (e) {
      throw ServerException('Erro ao deletar transação: $e');
    }
  }

  @override
  Future<TransactionModel> getTransaction(String transactionId) async {
    try {
      final doc = await _collection.doc(transactionId).get();
      if (!doc.exists) {
        throw const ServerException('Transação não encontrada.');
      }
      return TransactionModel.fromJson(doc.data()!);
    } catch (e) {
      throw ServerException('Erro ao buscar transação: $e');
    }
  }

  @override
  Stream<List<TransactionModel>> getTransactions({
    DateTime? startDate,
    DateTime? endDate,
    String? categoryId,
    String? type,
    String? frequency,
  }) {
    try {
      Query<Map<String, dynamic>> query = _collection;

      if (startDate != null) {
        query = query.where(
          'createdAt',
          isGreaterThanOrEqualTo: startDate.toIso8601String(),
        );
      }
      if (endDate != null) {
        query = query.where(
          'createdAt',
          isLessThanOrEqualTo: endDate.toIso8601String(),
        );
      }
      if (categoryId != null) {
        query = query.where('category', isEqualTo: categoryId);
      }
      if (type != null) {
        query = query.where('type', isEqualTo: type);
      }
      if (frequency != null) {
        query = query.where('frequency', isEqualTo: frequency);
      }

      return query.snapshots().map((snapshot) {
        return snapshot.docs
            .map((doc) => TransactionModel.fromJson(doc.data()))
            .toList();
      });
    } catch (e) {
      throw ServerException('Erro ao buscar transações: $e');
    }
  }
}
