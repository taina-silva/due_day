import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:due_day/core/errors/exceptions.dart';
import 'package:due_day/features/categories/data/models/category_model.dart';
import 'package:firebase_auth/firebase_auth.dart';

abstract class CategoryRemoteDataSource {
  Future<CategoryModel> addCategory(CategoryModel category);
  Future<CategoryModel> updateCategory(CategoryModel category);
  Future<void> deleteCategory(String categoryId);
  Stream<List<CategoryModel>> getCategories();
}

class CategoryRemoteDataSourceImpl implements CategoryRemoteDataSource {
  final FirebaseFirestore firestore;
  final FirebaseAuth firebaseAuth;

  CategoryRemoteDataSourceImpl({
    required this.firestore,
    required this.firebaseAuth,
  });

  String get _userId {
    final user = firebaseAuth.currentUser;
    if (user == null) throw const ServerException('Usuário não autenticado.');
    return user.uid;
  }

  CollectionReference<Map<String, dynamic>> get _collection =>
      firestore.collection('users').doc(_userId).collection('categories');

  @override
  Future<CategoryModel> addCategory(CategoryModel category) async {
    try {
      final docRef = _collection.doc(category.id);
      await docRef.set(category.toJson());
      return category;
    } catch (e) {
      throw ServerException('Erro ao adicionar categoria: $e');
    }
  }

  @override
  Future<CategoryModel> updateCategory(CategoryModel category) async {
    try {
      final docRef = _collection.doc(category.id);
      await docRef.update(category.toJson());
      return category;
    } catch (e) {
      throw ServerException('Erro ao atualizar categoria: $e');
    }
  }

  @override
  Future<void> deleteCategory(String categoryId) async {
    try {
      await _collection.doc(categoryId).delete();
    } catch (e) {
      throw ServerException('Erro ao deletar categoria: $e');
    }
  }

  @override
  Stream<List<CategoryModel>> getCategories() {
    try {
      return _collection.snapshots().map((snapshot) {
        return snapshot.docs
            .map((doc) => CategoryModel.fromJson(doc.data()))
            .toList();
      });
    } catch (e) {
      throw ServerException('Erro ao buscar categorias: $e');
    }
  }
}
