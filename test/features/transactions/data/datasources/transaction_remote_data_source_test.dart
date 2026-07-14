import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:due_day/core/errors/exceptions.dart';
import 'package:due_day/features/transactions/data/datasources/transaction_remote_data_source.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../helpers/transaction_test_helpers.dart';

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
  });
}
