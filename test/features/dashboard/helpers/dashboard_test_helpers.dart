import 'package:due_day/features/accounts/domain/entities/account_category.dart';
import 'package:due_day/features/accounts/domain/entities/account_entity.dart';
import 'package:due_day/features/accounts/domain/usecases/account_usecases.dart';
import 'package:due_day/features/categories/domain/entities/category_entity.dart';
import 'package:due_day/features/categories/domain/usecases/category_usecases.dart';
import 'package:due_day/features/dashboard/domain/entities/dashboard_summary.dart';
import 'package:due_day/features/dashboard/domain/usecases/get_dashboard_summary.dart';
import 'package:due_day/features/transactions/domain/entities/transaction_entity.dart';
import 'package:due_day/features/transactions/domain/usecases/transaction_usecases.dart';
import 'package:mocktail/mocktail.dart';

// Usecase Mocks
class MockGetAccounts extends Mock implements GetAccounts {}

class MockGetTransactions extends Mock implements GetTransactions {}

class MockGetDashboardSummary extends Mock implements GetDashboardSummary {}

class MockGetCategories extends Mock implements GetCategories {}

// Test Data
final tDateTime = DateTime(2026, 7, 7);

final tAccount1 = AccountEntity(
  id: 'acc-1',
  userId: 'user-1',
  name: 'Checking Account',
  category: AccountCategory.checking,
  createdAt: tDateTime,
);

final tAccount2 = AccountEntity(
  id: 'acc-2',
  userId: 'user-1',
  name: 'Savings',
  category: AccountCategory.checking,
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

final tCategory1 = CategoryEntity(
  id: 'cat-1',
  userId: 'user-1',
  name: 'Food',
  color: '#E63946',
  icon: '0xf0108',
  createdAt: tDateTime,
);

final tDashboardSummary = DashboardSummary(
  month: DateTime(2026, 7),
  spent: 50.0,
  income: 200.0,
  invested: 0,
  upcomingDues: [tUnpaidExpenseTx],
  spendingByCategory: const {'cat-1': 50.0},
  insight: const DashboardInsight(type: DashboardInsightType.healthy),
);
