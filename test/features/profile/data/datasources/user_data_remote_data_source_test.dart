// ignore_for_file: subtype_of_sealed_class

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:due_day/core/errors/exceptions.dart';
import 'package:due_day/features/profile/data/datasources/user_data_remote_data_source.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockFirebaseAuth extends Mock implements FirebaseAuth {}

class MockFirebaseFirestore extends Mock implements FirebaseFirestore {}

class MockUser extends Mock implements User {}

class MockCollectionReference extends Mock
    implements CollectionReference<Map<String, dynamic>> {}

class MockDocumentReference extends Mock
    implements DocumentReference<Map<String, dynamic>> {}

class MockQuerySnapshot extends Mock
    implements QuerySnapshot<Map<String, dynamic>> {}

class MockQueryDocumentSnapshot extends Mock
    implements QueryDocumentSnapshot<Map<String, dynamic>> {}

class MockWriteBatch extends Mock implements WriteBatch {}

void main() {
  late MockFirebaseAuth auth;
  late MockFirebaseFirestore firestore;
  late MockCollectionReference users;
  late MockDocumentReference userDoc;
  late List<MockWriteBatch> batches;
  late UserDataRemoteDataSourceImpl dataSource;

  setUpAll(() => registerFallbackValue(MockDocumentReference()));

  void stubCollection(String name, int docCount) {
    final collection = MockCollectionReference();
    final snapshot = MockQuerySnapshot();
    final docs = List.generate(docCount, (_) {
      final doc = MockQueryDocumentSnapshot();
      when(() => doc.reference).thenReturn(MockDocumentReference());
      return doc;
    });
    when(() => userDoc.collection(name)).thenReturn(collection);
    when(() => collection.get()).thenAnswer((_) async => snapshot);
    when(() => snapshot.docs).thenReturn(docs);
  }

  setUp(() {
    auth = MockFirebaseAuth();
    firestore = MockFirebaseFirestore();
    users = MockCollectionReference();
    userDoc = MockDocumentReference();
    batches = [];
    final user = MockUser();

    when(() => auth.currentUser).thenReturn(user);
    when(() => user.uid).thenReturn('user-1');
    when(() => firestore.collection('users')).thenReturn(users);
    when(() => users.doc('user-1')).thenReturn(userDoc);
    when(() => firestore.batch()).thenAnswer((_) {
      final batch = MockWriteBatch();
      when(() => batch.commit()).thenAnswer((_) async {});
      batches.add(batch);
      return batch;
    });

    dataSource = UserDataRemoteDataSourceImpl(
      firestore: firestore,
      firebaseAuth: auth,
    );
  });

  group('UserDataRemoteDataSourceImpl.deleteAll', () {
    test('SET-001: deletes accounts, categories, and 1000 transactions in '
        'batches of at most 450 writes', () async {
      stubCollection('accounts', 2);
      stubCollection('categories', 15);
      stubCollection('transactions', 1000);

      await dataSource.deleteAll();

      // accounts: 1 batch, categories: 1 batch, transactions: 3 batches.
      expect(batches, hasLength(5));
      var totalDeletes = 0;
      for (final batch in batches) {
        final calls = verify(() => batch.delete(any())).callCount;
        expect(calls, lessThanOrEqualTo(450));
        totalDeletes += calls;
        verify(() => batch.commit()).called(1);
      }
      expect(totalDeletes, 1017);
      verifyNever(() => userDoc.delete());
    });

    test('commits nothing for empty collections', () async {
      stubCollection('accounts', 0);
      stubCollection('categories', 0);
      stubCollection('transactions', 0);

      await dataSource.deleteAll();

      expect(batches, isEmpty);
    });

    test('throws ServerException when not signed in', () async {
      when(() => auth.currentUser).thenReturn(null);

      expect(dataSource.deleteAll, throwsA(isA<ServerException>()));
    });

    test('maps FirebaseException to ServerException', () async {
      final collection = MockCollectionReference();
      when(() => userDoc.collection('accounts')).thenReturn(collection);
      when(
        () => collection.get(),
      ).thenThrow(FirebaseException(plugin: 'firestore', code: 'unavailable'));

      expect(dataSource.deleteAll, throwsA(isA<ServerException>()));
    });
  });
}
