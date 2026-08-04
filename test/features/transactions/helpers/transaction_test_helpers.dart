// ignore_for_file: subtype_of_sealed_class

import 'package:bloc_test/bloc_test.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:due_day/core/services/notification_service.dart';
import 'package:due_day/core/settings/settings_bloc.dart';
import 'package:due_day/core/settings/settings_event.dart';
import 'package:due_day/core/settings/settings_state.dart';
import 'package:due_day/features/accounts/domain/entities/account_category.dart';
import 'package:due_day/features/accounts/domain/entities/account_entity.dart';
import 'package:due_day/features/accounts/domain/repositories/account_repository.dart';
import 'package:due_day/features/accounts/presentation/bloc/account_load_bloc.dart';
import 'package:due_day/features/accounts/presentation/bloc/account_load_event.dart';
import 'package:due_day/features/accounts/presentation/bloc/account_load_state.dart';
import 'package:due_day/features/auth/domain/entities/user_entity.dart';
import 'package:due_day/features/auth/domain/usecases/auth_usecases.dart';
import 'package:due_day/features/categories/domain/entities/category_entity.dart';
import 'package:due_day/features/categories/presentation/bloc/category_load_bloc.dart';
import 'package:due_day/features/categories/presentation/bloc/category_load_event.dart';
import 'package:due_day/features/categories/presentation/bloc/category_load_state.dart';
import 'package:due_day/features/notifications/domain/usecases/notification_usecases.dart';
import 'package:due_day/features/transactions/data/datasources/transaction_remote_data_source.dart';
import 'package:due_day/features/transactions/data/models/transaction_model.dart';
import 'package:due_day/features/transactions/domain/entities/transaction_entity.dart';
import 'package:due_day/features/transactions/domain/repositories/transaction_repository.dart';
import 'package:due_day/features/transactions/domain/usecases/classify_transaction_reminders.dart';
import 'package:due_day/features/transactions/domain/usecases/sync_recurring_transactions.dart';
import 'package:due_day/features/transactions/domain/usecases/transaction_usecases.dart';
import 'package:due_day/features/transactions/presentation/bloc/transaction_action_bloc.dart';
import 'package:due_day/features/transactions/presentation/bloc/transaction_action_event.dart';
import 'package:due_day/features/transactions/presentation/bloc/transaction_action_state.dart';
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

class MockWriteBatch extends Mock implements WriteBatch {}

// Core mocks
class MockTransactionRemoteDataSource extends Mock
    implements TransactionRemoteDataSource {}

class MockTransactionRepository extends Mock implements TransactionRepository {}

class MockAccountRepository extends Mock implements AccountRepository {}

class MockAddNotification extends Mock implements AddNotification {}

class MockNotificationService extends Mock implements NotificationService {}

class MockClassifyTransactionReminders extends Mock
    implements ClassifyTransactionReminders {}

class MockSyncRecurringTransactions extends Mock
    implements SyncRecurringTransactions {}

class MockGetCurrentUser extends Mock implements GetCurrentUser {}

class MockSettingsBloc extends MockBloc<SettingsEvent, SettingsState>
    implements SettingsBloc {}

// BLoC Mocks
class MockTransactionActionBloc
    extends MockBloc<TransactionActionEvent, TransactionActionState>
    implements TransactionActionBloc {}

class MockAccountLoadBloc extends MockBloc<AccountLoadEvent, AccountLoadState>
    implements AccountLoadBloc {}

class MockCategoryLoadBloc
    extends MockBloc<CategoryLoadEvent, CategoryLoadState>
    implements CategoryLoadBloc {}

// UseCases
class MockAddTransaction extends Mock implements AddTransaction {}

class MockUpdateTransaction extends Mock implements UpdateTransaction {}

class MockDeleteTransaction extends Mock implements DeleteTransaction {}

class MockGetTransactions extends Mock implements GetTransactions {}

// Test Data
final tDateTime = DateTime(2026, 7, 7);

final tTransactionEntity = TransactionEntity(
  id: 'transaction-1',
  userId: 'user-1',
  type: TransactionType.expense,
  amount: 50.0,
  category: 'category-1',
  accountFrom: 'acc-1',
  dueDate: tDateTime,
  paid: true,
  isRecurring: false,
  notes: 'Coffee',
  createdAt: tDateTime,
);

final tTransactionModel = TransactionModel(
  id: 'transaction-1',
  userId: 'user-1',
  type: 'expense',
  amount: 50.0,
  category: 'category-1',
  accountFrom: 'acc-1',
  dueDate: tDateTime,
  paid: true,
  isRecurring: false,
  frequency: 'none',
  notes: 'Coffee',
  createdAt: tDateTime,
);

final tAccountEntity = AccountEntity(
  id: 'acc-1',
  userId: 'user-1',
  name: 'Checking Account',
  category: AccountCategory.dailyUse,
  balance: 1000.0,
  createdAt: tDateTime,
);

final tCategoryExpense = CategoryEntity(
  id: 'category-1',
  userId: 'user-1',
  name: 'Groceries',
  icon: 'shopping_cart',
  color: '0xFFF44336',
  createdAt: tDateTime,
);

final tUserEntity = UserEntity(
  uid: 'user-1',
  email: 'user@dueday.com',
  name: 'DueDay User',
  createdAt: tDateTime,
);
