import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:due_day/core/errors/exceptions.dart';
import 'package:due_day/features/categories/data/models/category_model.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:rxdart/rxdart.dart';

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
    if (user == null) {
      throw const ServerException('User not authenticated.', 'unauthenticated');
    }
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
    } on ServerException {
      rethrow;
    } on FirebaseException catch (e) {
      throw ServerException(e.message ?? 'Failed to add category.', e.code);
    } catch (e) {
      throw ServerException('Failed to add category: $e');
    }
  }

  @override
  Future<CategoryModel> updateCategory(CategoryModel category) async {
    try {
      final docRef = _collection.doc(category.id);
      await docRef.update(category.toJson());
      return category;
    } on ServerException {
      rethrow;
    } on FirebaseException catch (e) {
      throw ServerException(e.message ?? 'Failed to update category.', e.code);
    } catch (e) {
      throw ServerException('Failed to update category: $e');
    }
  }

  @override
  Future<void> deleteCategory(String categoryId) async {
    try {
      await _collection.doc(categoryId).delete();
    } on ServerException {
      rethrow;
    } on FirebaseException catch (e) {
      throw ServerException(e.message ?? 'Failed to delete category.', e.code);
    } catch (e) {
      throw ServerException('Failed to delete category: $e');
    }
  }

  @override
  Stream<List<CategoryModel>> getCategories() {
    // Switches the underlying Firestore listener to the signed-in user's
    // own collection whenever the auth session changes, so a listener from
    // a previous account never lingers (and never trips permission-denied)
    // after logout/login.
    return firebaseAuth.authStateChanges().switchMap((user) {
      if (user == null) {
        return Stream<List<CategoryModel>>.value(const []);
      }

      return firestore
          .collection('users')
          .doc(user.uid)
          .collection('categories')
          .snapshots()
          .map((snapshot) {
            return snapshot.docs
                .map((doc) => CategoryModel.fromJson(doc.data()))
                .toList();
          });
    }).handleError((Object e) {
      if (e is FirebaseException) {
        throw ServerException(
          e.message ?? 'Failed to fetch categories.',
          e.code,
        );
      }
      throw ServerException('Failed to fetch categories: $e');
    });
  }
}
