import 'package:due_day/features/accounts/domain/entities/account_category.dart';
import 'package:due_day/features/accounts/domain/entities/account_entity.dart';
import 'package:due_day/features/accounts/domain/usecases/account_usecases.dart';
import 'package:due_day/features/auth/domain/entities/user_entity.dart';
import 'package:due_day/features/auth/domain/usecases/auth_usecases.dart';
import 'package:due_day/features/dashboard/domain/entities/dashboard_summary.dart';
import 'package:due_day/features/dashboard/domain/usecases/get_dashboard_summary.dart';
import 'package:due_day/features/transactions/domain/entities/transaction_entity.dart';
import 'package:due_day/features/transactions/domain/usecases/sync_recurring_transactions.dart';
import 'package:due_day/features/transactions/domain/usecases/transaction_usecases.dart';
import 'package:mocktail/mocktail.dart';

// Usecase Mocks
class MockGetAccounts extends Mock implements GetAccounts {}

class MockGetTransactions extends Mock implements GetTransactions {}

class MockGetCurrentUser extends Mock implements GetCurrentUser {}

class MockGetDashboardSummary extends Mock implements GetDashboardSummary {}

class MockSyncRecurringTransactions extends Mock
    implements SyncRecurringTransactions {}

// Test Data
final tDateTime = DateTime(2026, 7, 7);

final tUserEntity = UserEntity(
  uid: 'user-1',
  email: 'user@dueday.com',
  name: 'DueDay User',
  createdAt: tDateTime,
);

final tAccount1 = AccountEntity(
  id: 'acc-1',
  userId: 'user-1',
  name: 'Checking Account',
  category: AccountCategory.dailyUse,
  balance: 1000.0,
  createdAt: tDateTime,
);

final tAccount2 = AccountEntity(
  id: 'acc-2',
  userId: 'user-1',
  name: 'Savings',
  category: AccountCategory.savings,
  balance: 5000.0,
  createdAt: tDateTime,
);

final tIncomeTx = TransactionEntity(
  id: 'tx-1',
  userId: 'user-1',
  type: TransactionType.income,
  amount: 200.0,
  paid: true,
  isRecurring: false,
  createdAt: tDateTime,
  accountTo: 'acc-1',
  notes: 'Salary bonus',
);

final tExpenseTx = TransactionEntity(
  id: 'tx-2',
  userId: 'user-1',
  type: TransactionType.expense,
  amount: 50.0,
  paid: true,
  isRecurring: false,
  createdAt: tDateTime,
  accountFrom: 'acc-1',
  category: 'cat-1',
  notes: 'Coffee',
);

final tUnpaidExpenseTx = TransactionEntity(
  id: 'tx-3',
  userId: 'user-1',
  type: TransactionType.expense,
  amount: 100.0,
  paid: false,
  isRecurring: false,
  createdAt: tDateTime,
  dueDate: DateTime(2026, 7, 15),
  accountFrom: 'acc-1',
  category: 'cat-2',
  notes: 'Electricity bill',
);

final tDashboardSummary = DashboardSummary(
  currentBalance: 6000.0,
  projectedBalance: 5900.0,
  monthlyIncome: 200.0,
  monthlyExpenses: 50.0,
  upcomingDues: [tUnpaidExpenseTx],
  spendingByCategory: const {'cat-1': 50.0},
);
