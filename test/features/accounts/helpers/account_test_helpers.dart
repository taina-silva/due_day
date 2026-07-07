// ignore_for_file: subtype_of_sealed_class

import 'package:bloc_test/bloc_test.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:due_day/features/accounts/data/datasources/account_remote_data_source.dart';
import 'package:due_day/features/accounts/data/models/account_model.dart';
import 'package:due_day/features/accounts/domain/entities/account_category.dart';
import 'package:due_day/features/accounts/domain/entities/account_entity.dart';
import 'package:due_day/features/accounts/domain/repositories/account_repository.dart';
import 'package:due_day/features/accounts/domain/usecases/account_usecases.dart';
import 'package:due_day/features/accounts/presentation/bloc/account_bloc.dart';
import 'package:due_day/features/accounts/presentation/bloc/account_event.dart';
import 'package:due_day/features/accounts/presentation/bloc/account_state.dart';
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
class MockAccountRemoteDataSource extends Mock
    implements AccountRemoteDataSource {}

class MockAccountRepository extends Mock implements AccountRepository {}

// UseCases
class MockAddAccount extends Mock implements AddAccount {}

class MockUpdateAccount extends Mock implements UpdateAccount {}

class MockDeleteAccount extends Mock implements DeleteAccount {}

class MockGetAccounts extends Mock implements GetAccounts {}

// BLoC Mock
class MockAccountBloc extends MockBloc<AccountEvent, AccountState>
    implements AccountBloc {}

// Test Data
final tDateTime = DateTime(2026, 7, 7);

final tAccountEntity = AccountEntity(
  id: 'account-1',
  userId: 'user-1',
  name: 'Checking Account',
  category: AccountCategory.dailyUse,
  balance: 1500.0,
  createdAt: tDateTime,
);

final tAccountModel = AccountModel(
  id: 'account-1',
  userId: 'user-1',
  name: 'Checking Account',
  category: AccountCategory.dailyUse,
  balance: 1500.0,
  createdAt: tDateTime,
);

final tCreditCardAccountEntity = AccountEntity(
  id: 'account-2',
  userId: 'user-1',
  name: 'Main Credit Card',
  category: AccountCategory.creditCard,
  balance: -500.0,
  dueDay: 15,
  createdAt: tDateTime,
);

final tCreditCardAccountModel = AccountModel(
  id: 'account-2',
  userId: 'user-1',
  name: 'Main Credit Card',
  category: AccountCategory.creditCard,
  balance: -500.0,
  dueDay: 15,
  createdAt: tDateTime,
);
