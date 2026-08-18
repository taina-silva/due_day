import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:due_day/core/errors/exceptions.dart';
import 'package:due_day/features/categories/data/datasources/category_remote_data_source.dart';
import 'package:due_day/features/categories/data/models/category_model.dart';
import 'package:firebase_auth/firebase_auth.dart';
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

    group('getCategories', () {
      late StreamController<User?> authStateController;

      setUp(() {
        authStateController = StreamController<User?>();
        when(
          () => mockFirebaseAuth.authStateChanges(),
        ).thenAnswer((_) => authStateController.stream);
      });

      tearDown(() => authStateController.close());

      test(
        'given no authenticated user when getCategories is listened then it emits an empty list',
        () async {
          final future = dataSource.getCategories().first;

          authStateController.add(null);

          expect(await future, isEmpty);
        },
      );

      test(
        'given the auth session switches accounts when getCategories is listened '
        'then it re-scopes to the new user and stops emitting from the old one',
        () async {
          final controllerA =
              StreamController<QuerySnapshot<Map<String, dynamic>>>();
          when(
            () => mockCollectionReference.snapshots(),
          ).thenAnswer((_) => controllerA.stream);

          final mockUserB = MockUser();
          final mockUserDocRefB = MockDocumentReference();
          final mockCollectionReferenceB = MockCollectionReference();
          when(() => mockUserB.uid).thenReturn('user-2');
          when(
            () => mockCollectionReference.doc('user-2'),
          ).thenReturn(mockUserDocRefB);
          when(
            () => mockUserDocRefB.collection('categories'),
          ).thenReturn(mockCollectionReferenceB);
          final controllerB =
              StreamController<QuerySnapshot<Map<String, dynamic>>>();
          when(
            () => mockCollectionReferenceB.snapshots(),
          ).thenAnswer((_) => controllerB.stream);

          final emissions = <List<CategoryModel>>[];
          final subscription = dataSource.getCategories().listen(
            emissions.add,
          );

          authStateController.add(mockUser); // user-1
          await Future.delayed(Duration.zero);

          final emptySnapshot = MockQuerySnapshot();
          when(() => emptySnapshot.docs).thenReturn([]);
          controllerA.add(emptySnapshot);
          await Future.delayed(Duration.zero);
          expect(emissions.last, isEmpty);

          // Switching accounts must stop reflecting the old user's listener
          // and re-scope the query under the new user's own collection.
          authStateController.add(mockUserB);
          await Future.delayed(Duration.zero);

          final mockDocB = MockQueryDocumentSnapshot();
          when(() => mockDocB.data()).thenReturn(tCategoryModel.toJson());
          final snapshotB = MockQuerySnapshot();
          when(() => snapshotB.docs).thenReturn([mockDocB]);
          controllerB.add(snapshotB);
          await Future.delayed(Duration.zero);

          expect(emissions.last, [tCategoryModel]);
          verify(() => mockCollectionReferenceB.snapshots()).called(1);

          // A stale event from the old (now-abandoned) user-1 listener must
          // never surface as data for user-2.
          final staleSnapshot = MockQuerySnapshot();
          when(() => staleSnapshot.docs).thenReturn([]);
          controllerA.add(staleSnapshot);
          await Future.delayed(Duration.zero);
          expect(emissions.last, [tCategoryModel]);

          await subscription.cancel();
          await controllerA.close();
          await controllerB.close();
        },
      );
    });
  });
}
