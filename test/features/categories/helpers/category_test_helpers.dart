// ignore_for_file: subtype_of_sealed_class

import 'package:bloc_test/bloc_test.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:due_day/features/categories/data/datasources/category_remote_data_source.dart';
import 'package:due_day/features/categories/data/models/category_model.dart';
import 'package:due_day/features/categories/domain/entities/category_entity.dart';
import 'package:due_day/features/categories/domain/repositories/category_repository.dart';
import 'package:due_day/features/categories/domain/usecases/category_usecases.dart';
import 'package:due_day/features/categories/presentation/bloc/category_bloc.dart';
import 'package:due_day/features/categories/presentation/bloc/category_event.dart';
import 'package:due_day/features/categories/presentation/bloc/category_state.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:mocktail/mocktail.dart';

// Firebase mocks
class MockFirebaseAuth extends Mock implements FirebaseAuth {}

class MockFirebaseFirestore extends Mock implements FirebaseFirestore {}

class MockUser extends Mock implements User {}

class MockCollectionReference extends Mock
    implements CollectionReference<Map<String, dynamic>> {}

class MockDocumentReference extends Mock
    implements DocumentReference<Map<String, dynamic>> {}

class MockDocumentSnapshot extends Mock
    implements DocumentSnapshot<Map<String, dynamic>> {}

class MockQuerySnapshot extends Mock
    implements QuerySnapshot<Map<String, dynamic>> {}

class MockQueryDocumentSnapshot extends Mock
    implements QueryDocumentSnapshot<Map<String, dynamic>> {}

// Core Mocks
class MockCategoryRemoteDataSource extends Mock
    implements CategoryRemoteDataSource {}

class MockCategoryRepository extends Mock implements CategoryRepository {}

// UseCases
class MockAddCategory extends Mock implements AddCategory {}

class MockUpdateCategory extends Mock implements UpdateCategory {}

class MockDeleteCategory extends Mock implements DeleteCategory {}

class MockGetCategories extends Mock implements GetCategories {}

// BLoC Mock
class MockCategoryBloc extends MockBloc<CategoryEvent, CategoryState>
    implements CategoryBloc {}

// Test Data
final tDateTime = DateTime(2026, 7, 7);

final tCategoryEntity = CategoryEntity(
  id: 'category-1',
  userId: 'user-1',
  name: 'Food',
  color: '#4361EE',
  icon: '0xe57a',
  createdAt: tDateTime,
  transactionCount: 5,
);

final tCategoryModel = CategoryModel(
  id: 'category-1',
  userId: 'user-1',
  name: 'Food',
  color: '#4361EE',
  icon: '0xe57a',
  createdAt: tDateTime,
  transactionCount: 5,
);

final tCategoryEntity2 = CategoryEntity(
  id: 'category-2',
  userId: 'user-1',
  name: 'Transport',
  color: '#E63946',
  icon: '0xe531',
  createdAt: tDateTime,
  transactionCount: 2,
);

final tCategoryModel2 = CategoryModel(
  id: 'category-2',
  userId: 'user-1',
  name: 'Transport',
  color: '#E63946',
  icon: '0xe531',
  createdAt: tDateTime,
  transactionCount: 2,
);
