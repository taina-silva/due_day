import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:due_day/core/errors/exceptions.dart';
import 'package:due_day/features/transactions/data/datasources/transaction_remote_data_source.dart';
import 'package:due_day/features/transactions/data/models/transaction_model.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../helpers/transaction_test_helpers.dart';

// ignore: subtype_of_sealed_class
class MockQuery extends Mock implements Query<Map<String, dynamic>> {}

void main() {
  late MockFirebaseAuth mockFirebaseAuth;
  late MockFirebaseFirestore mockFirebaseFirestore;
  late MockUser mockUser;
  late MockCollectionReference mockCollectionReference;
  late MockDocumentReference mockUserDocRef;
  late MockDocumentReference mockTransactionDocRef;
  late MockDocumentReference mockCategoryDocRef;
  late MockDocumentSnapshot mockDocumentSnapshot;
  late MockWriteBatch mockWriteBatch;
  late TransactionRemoteDataSourceImpl dataSource;

  setUpAll(() {
    registerFallbackValue(<String, dynamic>{});
    registerFallbackValue(MockDocumentReference());
  });

  setUp(() {
    mockFirebaseAuth = MockFirebaseAuth();
    mockFirebaseFirestore = MockFirebaseFirestore();
    mockUser = MockUser();
    mockCollectionReference = MockCollectionReference();
    mockUserDocRef = MockDocumentReference();
    mockTransactionDocRef = MockDocumentReference();
    mockCategoryDocRef = MockDocumentReference();
    mockDocumentSnapshot = MockDocumentSnapshot();
    mockWriteBatch = MockWriteBatch();

    dataSource = TransactionRemoteDataSourceImpl(
      firestore: mockFirebaseFirestore,
      firebaseAuth: mockFirebaseAuth,
    );

    when(() => mockFirebaseAuth.currentUser).thenReturn(mockUser);
    when(() => mockUser.uid).thenReturn('user-1');
    when(
      () => mockFirebaseFirestore.collection('users'),
    ).thenReturn(mockCollectionReference);
    when(
      () => mockCollectionReference.doc('user-1'),
    ).thenReturn(mockUserDocRef);
    when(
      () => mockUserDocRef.collection('transactions'),
    ).thenReturn(mockCollectionReference);
    when(
      () => mockUserDocRef.collection('categories'),
    ).thenReturn(mockCollectionReference);
    when(() => mockFirebaseFirestore.batch()).thenReturn(mockWriteBatch);
    when(() => mockWriteBatch.commit()).thenAnswer((_) async {});
  });

  group('TransactionRemoteDataSourceImpl Tests', () {
    group('User Authentication Check', () {
      test(
        'should throw ServerException when firebaseAuth.currentUser is null',
        () async {
          when(() => mockFirebaseAuth.currentUser).thenReturn(null);

          expect(
            () => dataSource.addTransaction(tTransactionModel),
            throwsA(
              isA<ServerException>().having(
                (e) => e.code,
                'code',
                'unauthenticated',
              ),
            ),
          );
        },
      );
    });

    group('addTransaction', () {
      test(
        'should set transaction JSON and increment category count',
        () async {
          when(
            () => mockCollectionReference.doc(tTransactionModel.id),
          ).thenReturn(mockTransactionDocRef);
          when(
            () => mockCollectionReference.doc(tTransactionModel.category),
          ).thenReturn(mockCategoryDocRef);
          when(() => mockWriteBatch.set(any(), any())).thenReturn(null);
          when(() => mockWriteBatch.update(any(), any())).thenReturn(null);

          final result = await dataSource.addTransaction(tTransactionModel);

          expect(result, tTransactionModel);
          verify(
            () => mockWriteBatch.set(
              mockTransactionDocRef,
              tTransactionModel.toJson(),
            ),
          ).called(1);
          verify(
            () => mockWriteBatch.update(mockCategoryDocRef, {
              'transactionCount': FieldValue.increment(1),
            }),
          ).called(1);
          verify(() => mockWriteBatch.commit()).called(1);
        },
      );

      test(
        'should throw ServerException with Firestore error code on failure',
        () async {
          when(
            () => mockCollectionReference.doc(tTransactionModel.id),
          ).thenReturn(mockTransactionDocRef);
          when(
            () => mockCollectionReference.doc(tTransactionModel.category),
          ).thenReturn(mockCategoryDocRef);
          when(() => mockWriteBatch.set(any(), any())).thenReturn(null);
          when(() => mockWriteBatch.update(any(), any())).thenReturn(null);
          when(() => mockWriteBatch.commit()).thenThrow(
            FirebaseException(
              plugin: 'firestore',
              message: 'Permission denied',
              code: 'permission-denied',
            ),
          );

          expect(
            () => dataSource.addTransaction(tTransactionModel),
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

    group('getTransaction', () {
      test('should return TransactionModel when document exists', () async {
        when(
          () => mockCollectionReference.doc('transaction-1'),
        ).thenReturn(mockTransactionDocRef);
        when(
          () => mockTransactionDocRef.get(),
        ).thenAnswer((_) async => mockDocumentSnapshot);
        when(() => mockDocumentSnapshot.exists).thenReturn(true);
        when(
          () => mockDocumentSnapshot.data(),
        ).thenReturn(tTransactionModel.toJson());

        final result = await dataSource.getTransaction('transaction-1');

        expect(result, tTransactionModel);
      });

      test(
        'should throw ServerException with not-found code when document does not exist',
        () async {
          when(
            () => mockCollectionReference.doc('missing-id'),
          ).thenReturn(mockTransactionDocRef);
          when(
            () => mockTransactionDocRef.get(),
          ).thenAnswer((_) async => mockDocumentSnapshot);
          when(() => mockDocumentSnapshot.exists).thenReturn(false);

          expect(
            () => dataSource.getTransaction('missing-id'),
            throwsA(
              isA<ServerException>().having((e) => e.code, 'code', 'not-found'),
            ),
          );
        },
      );
    });

    group('deleteTransaction', () {
      test('should delete transaction and decrement category count', () async {
        when(
          () => mockCollectionReference.doc('transaction-1'),
        ).thenReturn(mockTransactionDocRef);
        when(
          () => mockCollectionReference.doc(tTransactionModel.category),
        ).thenReturn(mockCategoryDocRef);
        when(
          () => mockTransactionDocRef.get(),
        ).thenAnswer((_) async => mockDocumentSnapshot);
        when(() => mockDocumentSnapshot.exists).thenReturn(true);
        when(
          () => mockDocumentSnapshot.data(),
        ).thenReturn(tTransactionModel.toJson());
        when(() => mockWriteBatch.delete(any())).thenReturn(null);
        when(() => mockWriteBatch.update(any(), any())).thenReturn(null);

        await dataSource.deleteTransaction('transaction-1');

        verify(() => mockWriteBatch.delete(mockTransactionDocRef)).called(1);
        verify(
          () => mockWriteBatch.update(mockCategoryDocRef, {
            'transactionCount': FieldValue.increment(-1),
          }),
        ).called(1);
        verify(() => mockWriteBatch.commit()).called(1);
      });
    });

    group('getTransactions', () {
      late StreamController<User?> authStateController;

      setUp(() {
        authStateController = StreamController<User?>();
        when(
          () => mockFirebaseAuth.authStateChanges(),
        ).thenAnswer((_) => authStateController.stream);
      });

      tearDown(() => authStateController.close());

      test(
        'given no authenticated user when getTransactions is listened then it emits an empty list',
        () async {
          final future = dataSource.getTransactions().first;

          authStateController.add(null);

          expect(await future, isEmpty);
        },
      );

      test(
        'given the auth session switches accounts when getTransactions is listened '
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
            () => mockUserDocRefB.collection('transactions'),
          ).thenReturn(mockCollectionReferenceB);
          final controllerB =
              StreamController<QuerySnapshot<Map<String, dynamic>>>();
          when(
            () => mockCollectionReferenceB.snapshots(),
          ).thenAnswer((_) => controllerB.stream);

          final emissions = <List<TransactionModel>>[];
          final subscription = dataSource.getTransactions().listen(
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
          when(() => mockDocB.data()).thenReturn(tTransactionModel.toJson());
          final snapshotB = MockQuerySnapshot();
          when(() => snapshotB.docs).thenReturn([mockDocB]);
          controllerB.add(snapshotB);
          await Future.delayed(Duration.zero);

          expect(emissions.last, [tTransactionModel]);
          verify(() => mockCollectionReferenceB.snapshots()).called(1);

          // A stale event from the old (now-abandoned) user-1 listener must
          // never surface as data for user-2.
          final staleSnapshot = MockQuerySnapshot();
          when(() => staleSnapshot.docs).thenReturn([]);
          controllerA.add(staleSnapshot);
          await Future.delayed(Duration.zero);
          expect(emissions.last, [tTransactionModel]);

          await subscription.cancel();
          await controllerA.close();
          await controllerB.close();
        },
      );
    });

    group('addTransactionsBatch', () {
      test(
        'chunks writes at 450 items per batch and issues one call() per chunk',
        () async {
          final transactions = List.generate(
            1200,
            (i) => tTransactionModel.copyWith(id: 'tx-$i', category: null),
          );

          when(
            () => mockCollectionReference.doc(any(that: isNot('user-1'))),
          ).thenReturn(mockTransactionDocRef);
          when(() => mockWriteBatch.set(any(), any())).thenReturn(null);

          final result = await dataSource.addTransactionsBatch(transactions);

          expect(result, transactions);
          // ceil(1200 / 450) = 3 doc-write batches.
          verify(() => mockFirebaseFirestore.batch()).called(3);
          verify(() => mockWriteBatch.commit()).called(3);
        },
      );

      test(
        'aggregates category counter increments across chunks into a single update',
        () async {
          final transactions = List.generate(
            500,
            (i) => tTransactionModel.copyWith(id: 'tx-$i', category: 'cat-1'),
          );

          when(
            () => mockCollectionReference.doc(any(that: isNot('user-1'))),
          ).thenReturn(mockTransactionDocRef);
          when(() => mockWriteBatch.set(any(), any())).thenReturn(null);
          when(() => mockWriteBatch.update(any(), any())).thenReturn(null);

          await dataSource.addTransactionsBatch(transactions);

          // 2 doc-write batches (ceil(500/450)) + 1 counter batch = 3.
          verify(() => mockFirebaseFirestore.batch()).called(3);
          verify(
            () => mockWriteBatch.update(mockTransactionDocRef, {
              'transactionCount': FieldValue.increment(500),
            }),
          ).called(1);
        },
      );

      test('throws ServerException on Firestore failure', () async {
        when(
          () => mockCollectionReference.doc(tTransactionModel.id),
        ).thenReturn(mockTransactionDocRef);
        when(() => mockWriteBatch.set(any(), any())).thenReturn(null);
        when(() => mockWriteBatch.commit()).thenThrow(
          FirebaseException(plugin: 'firestore', code: 'unavailable'),
        );

        expect(
          () => dataSource.addTransactionsBatch([tTransactionModel]),
          throwsA(isA<ServerException>()),
        );
      });
    });

    group('findExistingExternalIds', () {
      test(
        'chunks the whereIn query at 30 ids and unions the results',
        () async {
          final ids = List.generate(65, (i) => 'ext-$i').toSet();
          final mockQuery = MockQuery();
          final mockSnapshot = MockQuerySnapshot();
          final mockDoc = MockQueryDocumentSnapshot();

          when(
            () => mockCollectionReference.where(
              'externalId',
              whereIn: any(named: 'whereIn'),
            ),
          ).thenReturn(mockQuery);
          when(() => mockQuery.get()).thenAnswer((_) async => mockSnapshot);
          when(() => mockSnapshot.docs).thenReturn([mockDoc]);
          when(() => mockDoc.data()).thenReturn({'externalId': 'ext-0'});

          final result = await dataSource.findExistingExternalIds(ids);

          expect(result, {'ext-0'});
          // ceil(65 / 30) = 3 chunked queries.
          verify(
            () => mockCollectionReference.where(
              'externalId',
              whereIn: any(named: 'whereIn'),
            ),
          ).called(3);
        },
      );

      test('throws ServerException on Firestore failure', () async {
        final mockQuery = MockQuery();
        when(
          () => mockCollectionReference.where(
            'externalId',
            whereIn: any(named: 'whereIn'),
          ),
        ).thenReturn(mockQuery);
        when(() => mockQuery.get()).thenThrow(
          FirebaseException(plugin: 'firestore', code: 'unavailable'),
        );

        expect(
          () => dataSource.findExistingExternalIds({'ext-1'}),
          throwsA(isA<ServerException>()),
        );
      });
    });
  });
}
