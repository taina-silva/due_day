import 'package:due_day/features/categories/domain/entities/category_entity.dart';
import 'package:due_day/features/categories/domain/usecases/category_usecases.dart';
import 'package:due_day/features/schedule/domain/entities/schedule_summary.dart';
import 'package:due_day/features/schedule/domain/usecases/get_schedule_data.dart';
import 'package:due_day/features/transactions/domain/entities/transaction_entity.dart';
import 'package:due_day/features/transactions/domain/repositories/transaction_repository.dart';
import 'package:due_day/features/transactions/domain/usecases/transaction_usecases.dart';
import 'package:mocktail/mocktail.dart';

class MockTransactionRepository extends Mock implements TransactionRepository {}

class MockGetScheduleData extends Mock implements GetScheduleData {}

class MockGetCategories extends Mock implements GetCategories {}

class MockUpdateTransaction extends Mock implements UpdateTransaction {}

// Helper test data
final tDateTime = DateTime(2026, 7, 7);

final tCategoryIncome = CategoryEntity(
  id: 'cat-income',
  userId: 'user-1',
  name: 'Salary',
  icon: 'work',
  color: '0xFF4CAF50',
  createdAt: tDateTime,
);

final tCategoryExpense = CategoryEntity(
  id: 'cat-expense',
  userId: 'user-1',
  name: 'Bills',
  icon: 'receipt',
  color: '0xFFF44336',
  createdAt: tDateTime,
);

final tTransactionsList = [
  TransactionEntity(
    id: 'tx-1',
    userId: 'user-1',
    type: TransactionType.income,
    amount: 1500.0,
    paid: false,
    dueDate: tDateTime.add(const Duration(days: 3)),
    isRecurring: false,
    createdAt: tDateTime,
    category: 'cat-income',
  ),
  TransactionEntity(
    id: 'tx-2',
    userId: 'user-1',
    type: TransactionType.expense,
    amount: 200.0,
    paid: true,
    dueDate: tDateTime.add(const Duration(days: 2)),
    isRecurring: false,
    createdAt: tDateTime,
    category: 'cat-expense',
  ),
  TransactionEntity(
    id: 'tx-3',
    userId: 'user-1',
    type: TransactionType.expense,
    amount: 100.0,
    paid: false,
    dueDate: tDateTime.add(const Duration(days: 5)),
    isRecurring: false,
    createdAt: tDateTime,
    category: 'cat-expense',
  ),
];

final tScheduleSummary = ScheduleSummary(
  totalAmount: 300.0,
  totalPaid: 200.0,
  totalToPay: 100.0,
  transactions: [
    tTransactionsList[1], // sorted by due date
    tTransactionsList[2],
  ],
  nextIncomeAmount: 1500.0,
  nextIncomeDate: tDateTime.add(const Duration(days: 3)),
);
