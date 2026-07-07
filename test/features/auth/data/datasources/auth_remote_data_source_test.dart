import 'package:due_day/core/errors/exceptions.dart';
import 'package:due_day/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../helpers/auth_test_helpers.dart';

class FakeAuthCredential extends Fake implements AuthCredential {}

void main() {
  late AuthRemoteDataSourceImpl dataSource;
  late MockFirebaseAuth mockFirebaseAuth;
  late MockFirebaseFirestore mockFirebaseFirestore;
  late MockGoogleSignIn mockGoogleSignIn;

  late MockUserCredential mockUserCredential;
  late MockUser mockUser;
  late MockCollectionReference mockCollectionReference;
  late MockDocumentReference mockDocumentReference;
  late MockDocumentSnapshot mockDocumentSnapshot;

  setUpAll(() {
    registerFallbackValue(FakeAuthCredential());
    registerFallbackValue(tUserModel);
  });

  setUp(() {
    mockFirebaseAuth = MockFirebaseAuth();
    mockFirebaseFirestore = MockFirebaseFirestore();
    mockGoogleSignIn = MockGoogleSignIn();

    mockUserCredential = MockUserCredential();
    mockUser = MockUser();
    mockCollectionReference = MockCollectionReference();
    mockDocumentReference = MockDocumentReference();
    mockDocumentSnapshot = MockDocumentSnapshot();

    dataSource = AuthRemoteDataSourceImpl(
      firebaseAuth: mockFirebaseAuth,
      firestore: mockFirebaseFirestore,
      googleSignIn: mockGoogleSignIn,
    );
  });

  void setupFirestoreUserDoc(Map<String, dynamic>? data, bool exists) {
    when(
      () => mockFirebaseFirestore.collection(any()),
    ).thenReturn(mockCollectionReference);
    when(
      () => mockCollectionReference.doc(any()),
    ).thenReturn(mockDocumentReference);
    when(
      () => mockDocumentReference.get(),
    ).thenAnswer((_) async => mockDocumentSnapshot);
    when(() => mockDocumentSnapshot.exists).thenReturn(exists);
    when(() => mockDocumentSnapshot.data()).thenReturn(data);
  }

  group('signInWithEmail', () {
    test(
      'given successful sign in and user exists in Firestore when signInWithEmail is called then return UserModel',
      () async {
        // arrange
        when(
          () => mockFirebaseAuth.signInWithEmailAndPassword(
            email: tEmail,
            password: tPassword,
          ),
        ).thenAnswer((_) async => mockUserCredential);
        when(() => mockUserCredential.user).thenReturn(mockUser);
        when(() => mockUser.uid).thenReturn(tUserModel.uid);
        when(() => mockUser.email).thenReturn(tUserModel.email);

        setupFirestoreUserDoc(tUserModel.toJson(), true);

        // act
        final result = await dataSource.signInWithEmail(tEmail, tPassword);

        // assert
        expect(result, equals(tUserModel));
        verify(
          () => mockFirebaseAuth.signInWithEmailAndPassword(
            email: tEmail,
            password: tPassword,
          ),
        ).called(1);
        verify(() => mockFirebaseFirestore.collection('users')).called(1);
      },
    );

    test(
      'given null user after sign in when signInWithEmail is called then throw ServerException',
      () async {
        // arrange
        when(
          () => mockFirebaseAuth.signInWithEmailAndPassword(
            email: tEmail,
            password: tPassword,
          ),
        ).thenAnswer((_) async => mockUserCredential);
        when(() => mockUserCredential.user).thenReturn(null);

        // act & assert
        expect(
          () => dataSource.signInWithEmail(tEmail, tPassword),
          throwsA(isA<ServerException>()),
        );
      },
    );

    test(
      'given FirebaseAuthException is thrown when signInWithEmail is called then throw ServerException',
      () async {
        // arrange
        when(
          () => mockFirebaseAuth.signInWithEmailAndPassword(
            email: tEmail,
            password: tPassword,
          ),
        ).thenThrow(
          FirebaseAuthException(
            code: 'wrong-password',
            message: 'Wrong password',
          ),
        );

        // act & assert
        expect(
          () => dataSource.signInWithEmail(tEmail, tPassword),
          throwsA(isA<ServerException>()),
        );
      },
    );
  });

  group('signUpWithEmail', () {
    test(
      'given successful registration when signUpWithEmail is called then create user in FirebaseAuth, save to Firestore, and return UserModel',
      () async {
        // arrange
        when(
          () => mockFirebaseAuth.createUserWithEmailAndPassword(
            email: tEmail,
            password: tPassword,
          ),
        ).thenAnswer((_) async => mockUserCredential);
        when(() => mockUserCredential.user).thenReturn(mockUser);
        when(() => mockUser.uid).thenReturn(tUserModel.uid);

        when(
          () => mockFirebaseFirestore.collection(any()),
        ).thenReturn(mockCollectionReference);
        when(
          () => mockCollectionReference.doc(any()),
        ).thenReturn(mockDocumentReference);
        when(
          () => mockDocumentReference.set(any()),
        ).thenAnswer((_) async => {});

        // act
        final result = await dataSource.signUpWithEmail(
          tEmail,
          tPassword,
          tDisplayName,
        );

        // assert
        expect(result.uid, equals(tUserModel.uid));
        expect(result.email, equals(tUserModel.email));
        expect(result.name, equals(tDisplayName));
        verify(
          () => mockFirebaseAuth.createUserWithEmailAndPassword(
            email: tEmail,
            password: tPassword,
          ),
        ).called(1);
        verify(() => mockDocumentReference.set(any())).called(1);
      },
    );

    test(
      'given FirebaseAuthException is thrown when signUpWithEmail is called then throw ServerException',
      () async {
        // arrange
        when(
          () => mockFirebaseAuth.createUserWithEmailAndPassword(
            email: tEmail,
            password: tPassword,
          ),
        ).thenThrow(FirebaseAuthException(code: 'email-already-in-use'));

        // act & assert
        expect(
          () => dataSource.signUpWithEmail(tEmail, tPassword, tDisplayName),
          throwsA(isA<ServerException>()),
        );
      },
    );
  });

  group('signInWithGoogle', () {
    late MockGoogleSignInAccount mockGoogleSignInAccount;
    late MockGoogleSignInAuthentication mockGoogleSignInAuthentication;

    setUp(() {
      mockGoogleSignInAccount = MockGoogleSignInAccount();
      mockGoogleSignInAuthentication = MockGoogleSignInAuthentication();
    });

    test(
      'given successful Google sign in and user exists in Firestore when signInWithGoogle is called then return UserModel',
      () async {
        // arrange
        when(
          () => mockGoogleSignIn.authenticate(),
        ).thenAnswer((_) async => mockGoogleSignInAccount);
        when(
          () => mockGoogleSignInAccount.authentication,
        ).thenReturn(mockGoogleSignInAuthentication);
        when(
          () => mockGoogleSignInAuthentication.idToken,
        ).thenReturn('google-token');

        when(
          () => mockFirebaseAuth.signInWithCredential(any()),
        ).thenAnswer((_) async => mockUserCredential);
        when(() => mockUserCredential.user).thenReturn(mockUser);
        when(() => mockUser.uid).thenReturn(tUserModel.uid);
        when(() => mockUser.email).thenReturn(tUserModel.email);

        setupFirestoreUserDoc(tUserModel.toJson(), true);

        // act
        final result = await dataSource.signInWithGoogle();

        // assert
        expect(result, equals(tUserModel));
        verify(() => mockGoogleSignIn.authenticate()).called(1);
        verify(() => mockFirebaseAuth.signInWithCredential(any())).called(1);
      },
    );

    test(
      'given successful Google sign in and user does not exist in Firestore when signInWithGoogle is called then create user in Firestore and return UserModel',
      () async {
        // arrange
        when(
          () => mockGoogleSignIn.authenticate(),
        ).thenAnswer((_) async => mockGoogleSignInAccount);
        when(
          () => mockGoogleSignInAccount.authentication,
        ).thenReturn(mockGoogleSignInAuthentication);
        when(
          () => mockGoogleSignInAuthentication.idToken,
        ).thenReturn('google-token');

        when(
          () => mockFirebaseAuth.signInWithCredential(any()),
        ).thenAnswer((_) async => mockUserCredential);
        when(() => mockUserCredential.user).thenReturn(mockUser);
        when(() => mockUser.uid).thenReturn(tUserModel.uid);
        when(() => mockUser.email).thenReturn(tUserModel.email);
        when(() => mockUser.displayName).thenReturn(tUserModel.name);
        when(() => mockUser.photoURL).thenReturn(tUserModel.photoUrl);

        setupFirestoreUserDoc(null, false);
        when(
          () => mockDocumentReference.set(any()),
        ).thenAnswer((_) async => {});

        // act
        final result = await dataSource.signInWithGoogle();

        // assert
        expect(result.uid, equals(tUserModel.uid));
        expect(result.email, equals(tUserModel.email));
        verify(() => mockDocumentReference.set(any())).called(1);
      },
    );

    test(
      'given Google sign in fails when signInWithGoogle is called then throw ServerException',
      () async {
        // arrange
        when(
          () => mockGoogleSignIn.authenticate(),
        ).thenThrow(Exception('Google Sign-in failed'));

        // act & assert
        expect(
          () => dataSource.signInWithGoogle(),
          throwsA(isA<ServerException>()),
        );
      },
    );
  });

  group('signOut', () {
    test(
      'given user is authenticated when signOut is called then call signOut on FirebaseAuth and GoogleSignIn',
      () async {
        // arrange
        when(() => mockFirebaseAuth.signOut()).thenAnswer((_) async => {});
        when(() => mockGoogleSignIn.signOut()).thenAnswer((_) async {});

        // act
        await dataSource.signOut();

        // assert
        verify(() => mockFirebaseAuth.signOut()).called(1);
        verify(() => mockGoogleSignIn.signOut()).called(1);
      },
    );

    test(
      'given signOut fails when signOut is called then throw ServerException',
      () async {
        // arrange
        when(() => mockFirebaseAuth.signOut()).thenThrow(Exception());

        // act & assert
        expect(() => dataSource.signOut(), throwsA(isA<ServerException>()));
      },
    );
  });

  group('getCurrentUser', () {
    test(
      'given currentUser exists and is in Firestore when getCurrentUser is called then return UserModel',
      () async {
        // arrange
        when(() => mockFirebaseAuth.currentUser).thenReturn(mockUser);
        when(() => mockUser.uid).thenReturn(tUserModel.uid);
        when(() => mockUser.email).thenReturn(tUserModel.email);

        setupFirestoreUserDoc(tUserModel.toJson(), true);

        // act
        final result = await dataSource.getCurrentUser();

        // assert
        expect(result, equals(tUserModel));
        verify(() => mockFirebaseAuth.currentUser).called(1);
      },
    );

    test(
      'given no currentUser exists when getCurrentUser is called then return null',
      () async {
        // arrange
        when(() => mockFirebaseAuth.currentUser).thenReturn(null);

        // act
        final result = await dataSource.getCurrentUser();

        // assert
        expect(result, isNull);
      },
    );
  });

  group('updateUser', () {
    test(
      'given UserModel when updateUser is called then update Firestore user document',
      () async {
        // arrange
        when(
          () => mockFirebaseFirestore.collection(any()),
        ).thenReturn(mockCollectionReference);
        when(
          () => mockCollectionReference.doc(any()),
        ).thenReturn(mockDocumentReference);
        when(
          () => mockDocumentReference.update(any()),
        ).thenAnswer((_) async => {});

        // act
        await dataSource.updateUser(tUserModel);

        // assert
        verify(
          () => mockDocumentReference.update(tUserModel.toJson()),
        ).called(1);
      },
    );

    test(
      'given update fails when updateUser is called then throw ServerException',
      () async {
        // arrange
        when(
          () => mockFirebaseFirestore.collection(any()),
        ).thenReturn(mockCollectionReference);
        when(
          () => mockCollectionReference.doc(any()),
        ).thenReturn(mockDocumentReference);
        when(() => mockDocumentReference.update(any())).thenThrow(
          FirebaseException(plugin: 'firestore', message: 'Update failed'),
        );

        // act & assert
        expect(
          () => dataSource.updateUser(tUserModel),
          throwsA(isA<ServerException>()),
        );
      },
    );
  });
}
