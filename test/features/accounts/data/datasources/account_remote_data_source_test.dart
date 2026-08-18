import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:due_day/core/errors/exceptions.dart';
import 'package:due_day/features/accounts/data/datasources/account_remote_data_source.dart';
import 'package:due_day/features/accounts/data/models/account_model.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../helpers/account_test_helpers.dart';

void main() {
  late MockFirebaseAuth mockFirebaseAuth;
  late MockFirebaseFirestore mockFirebaseFirestore;
  late MockUser mockUser;
  late MockCollectionReference mockCollectionReference;
  late MockDocumentReference mockUserDocRef;
  late MockDocumentReference mockAccountDocRef;
  late MockDocumentSnapshot mockDocumentSnapshot;
  late AccountRemoteDataSourceImpl dataSource;

  setUp(() {
    mockFirebaseAuth = MockFirebaseAuth();
    mockFirebaseFirestore = MockFirebaseFirestore();
    mockUser = MockUser();
    mockCollectionReference = MockCollectionReference();
    mockUserDocRef = MockDocumentReference();
    mockAccountDocRef = MockDocumentReference();
    mockDocumentSnapshot = MockDocumentSnapshot();

    dataSource = AccountRemoteDataSourceImpl(
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
      () => mockUserDocRef.collection('accounts'),
    ).thenReturn(mockCollectionReference);
  });

  group('AccountRemoteDataSourceImpl Tests', () {
    group('User Authentication Check', () {
      test(
        'should throw ServerException when firebaseAuth.currentUser is null',
        () async {
          // Arrange
          when(() => mockFirebaseAuth.currentUser).thenReturn(null);

          // Act & Assert
          expect(
            () => dataSource.addAccount(tAccountModel),
            throwsA(isA<ServerException>()),
          );
        },
      );
    });

    group('addAccount', () {
      test('should set account JSON on Firestore successfully', () async {
        // Arrange
        when(
          () => mockCollectionReference.doc(tAccountModel.id),
        ).thenReturn(mockAccountDocRef);
        when(() => mockAccountDocRef.set(any())).thenAnswer((_) async {});

        // Act
        final result = await dataSource.addAccount(tAccountModel);

        // Assert
        expect(result, tAccountModel);
        verify(() => mockAccountDocRef.set(tAccountModel.toJson())).called(1);
      });

      test(
        'should throw ServerException when Firestore set throws exception',
        () async {
          // Arrange
          when(
            () => mockCollectionReference.doc(tAccountModel.id),
          ).thenReturn(mockAccountDocRef);
          when(() => mockAccountDocRef.set(any())).thenThrow(
            FirebaseException(
              plugin: 'firestore',
              message: 'Permission denied',
              code: 'permission-denied',
            ),
          );

          // Act & Assert
          expect(
            () => dataSource.addAccount(tAccountModel),
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

    group('updateAccount', () {
      test('should update account data on Firestore successfully', () async {
        // Arrange
        when(
          () => mockCollectionReference.doc(tAccountModel.id),
        ).thenReturn(mockAccountDocRef);
        when(() => mockAccountDocRef.update(any())).thenAnswer((_) async {});

        // Act
        final result = await dataSource.updateAccount(tAccountModel);

        // Assert
        expect(result, tAccountModel);
        verify(
          () => mockAccountDocRef.update(tAccountModel.toJson()),
        ).called(1);
      });
    });

    group('deleteAccount', () {
      test(
        'should set deletedAt field to server timestamp on Firestore',
        () async {
          // Arrange
          when(
            () => mockCollectionReference.doc('account-1'),
          ).thenReturn(mockAccountDocRef);
          when(() => mockAccountDocRef.update(any())).thenAnswer((_) async {});

          // Act
          await dataSource.deleteAccount('account-1');

          // Assert
          verify(() => mockAccountDocRef.update(any())).called(1);
        },
      );
    });

    group('getAccountById', () {
      test('should return AccountModel when account exists', () async {
        // Arrange
        when(
          () => mockCollectionReference.doc('account-1'),
        ).thenReturn(mockAccountDocRef);
        when(
          () => mockAccountDocRef.get(),
        ).thenAnswer((_) async => mockDocumentSnapshot);
        when(() => mockDocumentSnapshot.exists).thenReturn(true);
        when(
          () => mockDocumentSnapshot.data(),
        ).thenReturn(tAccountModel.toJson());

        // Act
        final result = await dataSource.getAccountById('account-1');

        // Assert
        expect(result, tAccountModel);
      });

      test(
        'should throw ServerException when account does not exist',
        () async {
          // Arrange
          when(
            () => mockCollectionReference.doc('account-1'),
          ).thenReturn(mockAccountDocRef);
          when(
            () => mockAccountDocRef.get(),
          ).thenAnswer((_) async => mockDocumentSnapshot);
          when(() => mockDocumentSnapshot.exists).thenReturn(false);

          // Act & Assert
          expect(
            () => dataSource.getAccountById('account-1'),
            throwsA(
              isA<ServerException>().having((e) => e.code, 'code', 'not-found'),
            ),
          );
        },
      );
    });

    group('getAccounts', () {
      late StreamController<User?> authStateController;

      setUp(() {
        authStateController = StreamController<User?>();
        when(
          () => mockFirebaseAuth.authStateChanges(),
        ).thenAnswer((_) => authStateController.stream);
      });

      tearDown(() => authStateController.close());

      test(
        'given no authenticated user when getAccounts is listened then it emits an empty list',
        () async {
          final future = dataSource.getAccounts().first;

          authStateController.add(null);

          expect(await future, isEmpty);
        },
      );

      test(
        'given the auth session switches accounts when getAccounts is listened '
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
            () => mockUserDocRefB.collection('accounts'),
          ).thenReturn(mockCollectionReferenceB);
          final controllerB =
              StreamController<QuerySnapshot<Map<String, dynamic>>>();
          when(
            () => mockCollectionReferenceB.snapshots(),
          ).thenAnswer((_) => controllerB.stream);

          final emissions = <List<AccountModel>>[];
          final subscription = dataSource.getAccounts().listen(emissions.add);

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
          when(() => mockDocB.data()).thenReturn(tAccountModel.toJson());
          final snapshotB = MockQuerySnapshot();
          when(() => snapshotB.docs).thenReturn([mockDocB]);
          controllerB.add(snapshotB);
          await Future.delayed(Duration.zero);

          expect(emissions.last, [tAccountModel]);
          verify(() => mockCollectionReferenceB.snapshots()).called(1);

          // A stale event from the old (now-abandoned) user-1 listener must
          // never surface as data for user-2.
          final staleSnapshot = MockQuerySnapshot();
          when(() => staleSnapshot.docs).thenReturn([]);
          controllerA.add(staleSnapshot);
          await Future.delayed(Duration.zero);
          expect(emissions.last, [tAccountModel]);

          await subscription.cancel();
          await controllerA.close();
          await controllerB.close();
        },
      );
    });
  });
}
