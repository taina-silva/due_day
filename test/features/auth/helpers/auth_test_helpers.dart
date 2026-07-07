// ignore_for_file: subtype_of_sealed_class

import 'package:bloc_test/bloc_test.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:due_day/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:due_day/features/auth/data/models/user_model.dart';
import 'package:due_day/features/auth/domain/entities/user_entity.dart';
import 'package:due_day/features/auth/domain/repositories/auth_repository.dart';
import 'package:due_day/features/auth/domain/usecases/auth_usecases.dart';
import 'package:due_day/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:due_day/features/auth/presentation/bloc/auth_event.dart';
import 'package:due_day/features/auth/presentation/bloc/auth_state.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_router/go_router.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:mocktail/mocktail.dart';

// Firebase & Google Sign In Mocks
class MockFirebaseAuth extends Mock implements FirebaseAuth {}

class MockFirebaseFirestore extends Mock implements FirebaseFirestore {}

class MockGoogleSignIn extends Mock implements GoogleSignIn {}

class MockGoogleSignInAccount extends Mock implements GoogleSignInAccount {}

class MockGoogleSignInAuthentication extends Mock
    implements GoogleSignInAuthentication {}

class MockUserCredential extends Mock implements UserCredential {}

class MockUser extends Mock implements User {}

class MockCollectionReference extends Mock
    implements CollectionReference<Map<String, dynamic>> {}

class MockDocumentReference extends Mock
    implements DocumentReference<Map<String, dynamic>> {}

class MockDocumentSnapshot extends Mock
    implements DocumentSnapshot<Map<String, dynamic>> {}

// Domain & Data Layer Mocks
class MockAuthRemoteDataSource extends Mock implements AuthRemoteDataSource {}

class MockAuthRepository extends Mock implements AuthRepository {}

// UseCase Mocks
class MockSignInWithEmail extends Mock implements SignInWithEmail {}

class MockSignUpWithEmail extends Mock implements SignUpWithEmail {}

class MockSignInWithGoogle extends Mock implements SignInWithGoogle {}

class MockSignOut extends Mock implements SignOut {}

class MockGetCurrentUser extends Mock implements GetCurrentUser {}

class MockUpdateUser extends Mock implements UpdateUser {}

// Presentation Layer Mocks
class MockAuthBloc extends MockBloc<AuthEvent, AuthState> implements AuthBloc {}

class MockGoRouter extends Mock implements GoRouter {}

// Static Test Data
final tDateTime = DateTime(2026, 7, 7);

final tUserModel = UserModel(
  uid: 'test-uid',
  email: 'test@example.com',
  name: 'Test User',
  photoUrl: 'https://example.com/photo.png',
  createdAt: tDateTime,
  themePreference: 'dark',
);

final tUserEntity = UserEntity(
  uid: 'test-uid',
  email: 'test@example.com',
  name: 'Test User',
  photoUrl: 'https://example.com/photo.png',
  createdAt: tDateTime,
  themePreference: 'dark',
);

const tEmail = 'test@example.com';
const tPassword = 'password123';
const tDisplayName = 'Test User';
