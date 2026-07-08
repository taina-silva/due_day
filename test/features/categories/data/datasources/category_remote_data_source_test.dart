import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:due_day/core/errors/exceptions.dart';
import 'package:due_day/features/categories/data/datasources/category_remote_data_source.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../helpers/category_test_helpers.dart';

void main() {
  late MockFirebaseAuth mockFirebaseAuth;
  late MockFirebaseFirestore mockFirebaseFirestore;
  late MockUser mockUser;
  late MockCollectionReference mockCollectionReference;
  late MockDocumentReference mockUserDocRef;
  late MockDocumentReference mockCategoryDocRef;
  late CategoryRemoteDataSourceImpl dataSource;

  setUp(() {
    mockFirebaseAuth = MockFirebaseAuth();
    mockFirebaseFirestore = MockFirebaseFirestore();
    mockUser = MockUser();
    mockCollectionReference = MockCollectionReference();
    mockUserDocRef = MockDocumentReference();
    mockCategoryDocRef = MockDocumentReference();

    dataSource = CategoryRemoteDataSourceImpl(
      firestore: mockFirebaseFirestore,
      firebaseAuth: mockFirebaseAuth,
    );

    // Default setup for authenticated user
    when(() => mockFirebaseAuth.currentUser).thenReturn(mockUser);
    when(() => mockUser.uid).thenReturn('user-1');
    when(
      () => mockFirebaseFirestore.collection('users'),
    ).thenReturn(mockCollectionReference);
    when(
      () => mockCollectionReference.doc('user-1'),
    ).thenReturn(mockUserDocRef);
    when(
      () => mockUserDocRef.collection('categories'),
    ).thenReturn(mockCollectionReference);
  });

  group('CategoryRemoteDataSourceImpl Tests', () {
    group('User Authentication Check', () {
      test(
        'should throw ServerException when firebaseAuth.currentUser is null',
        () async {
          // Arrange
          when(() => mockFirebaseAuth.currentUser).thenReturn(null);

          // Act & Assert
          expect(
            () => dataSource.addCategory(tCategoryModel),
            throwsA(isA<ServerException>()),
          );
        },
      );
    });

    group('addCategory', () {
      test('should set category JSON on Firestore successfully', () async {
        // Arrange
        when(
          () => mockCollectionReference.doc(tCategoryModel.id),
        ).thenReturn(mockCategoryDocRef);
        when(() => mockCategoryDocRef.set(any())).thenAnswer((_) async {});

        // Act
        final result = await dataSource.addCategory(tCategoryModel);

        // Assert
        expect(result, tCategoryModel);
        verify(() => mockCategoryDocRef.set(tCategoryModel.toJson())).called(1);
      });

      test(
        'should throw ServerException when Firestore set throws exception',
        () async {
          // Arrange
          when(
            () => mockCollectionReference.doc(tCategoryModel.id),
          ).thenReturn(mockCategoryDocRef);
          when(() => mockCategoryDocRef.set(any())).thenThrow(
            FirebaseException(
              plugin: 'firestore',
              message: 'Permission denied',
              code: 'permission-denied',
            ),
          );

          // Act & Assert
          expect(
            () => dataSource.addCategory(tCategoryModel),
            throwsA(
              isA<ServerException>().having(
                (e) => e.code,
                'code',
                'permission-denied',
              ),
            ),
          );
        },
      );
    });

    group('updateCategory', () {
      test('should update category data on Firestore successfully', () async {
        // Arrange
        when(
          () => mockCollectionReference.doc(tCategoryModel.id),
        ).thenReturn(mockCategoryDocRef);
        when(() => mockCategoryDocRef.update(any())).thenAnswer((_) async {});

        // Act
        final result = await dataSource.updateCategory(tCategoryModel);

        // Assert
        expect(result, tCategoryModel);
        verify(
          () => mockCategoryDocRef.update(tCategoryModel.toJson()),
        ).called(1);
      });
    });

    group('deleteCategory', () {
      test('should delete category on Firestore successfully', () async {
        // Arrange
        when(
          () => mockCollectionReference.doc('category-1'),
        ).thenReturn(mockCategoryDocRef);
        when(() => mockCategoryDocRef.delete()).thenAnswer((_) async {});

        // Act
        await dataSource.deleteCategory('category-1');

        // Assert
        verify(() => mockCategoryDocRef.delete()).called(1);
      });
    });
  });
}
