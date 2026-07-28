import 'package:bloc_test/bloc_test.dart';
import 'package:due_day/features/categories/domain/entities/category_entity.dart';
import 'package:due_day/features/categories/presentation/bloc/category_load_bloc.dart';
import 'package:due_day/features/categories/presentation/bloc/category_load_event.dart';
import 'package:due_day/features/categories/presentation/bloc/category_load_state.dart';
import 'package:due_day/features/schedule/domain/entities/schedule_summary.dart';
import 'package:due_day/features/schedule/domain/usecases/get_schedule_data.dart';
import 'package:due_day/features/schedule/presentation/bloc/schedule_action_bloc.dart';
import 'package:due_day/features/schedule/presentation/bloc/schedule_action_event.dart';
import 'package:due_day/features/schedule/presentation/bloc/schedule_action_state.dart';
import 'package:due_day/features/schedule/presentation/bloc/schedule_load_bloc.dart';
import 'package:due_day/features/schedule/presentation/bloc/schedule_load_event.dart';
import 'package:due_day/features/schedule/presentation/bloc/schedule_load_state.dart';
import 'package:due_day/features/transactions/domain/entities/transaction_entity.dart';
import 'package:due_day/features/transactions/domain/repositories/transaction_repository.dart';
import 'package:due_day/features/transactions/domain/usecases/transaction_usecases.dart';
import 'package:mocktail/mocktail.dart';

class MockTransactionRepository extends Mock implements TransactionRepository {}

class MockGetScheduleData extends Mock implements GetScheduleData {}

class MockUpdateTransaction extends Mock implements UpdateTransaction {}

// BLoC Mocks
class MockScheduleLoadBloc
    extends MockBloc<ScheduleLoadEvent, ScheduleLoadState>
    implements ScheduleLoadBloc {}

class MockScheduleActionBloc
    extends MockBloc<ScheduleActionEvent, ScheduleActionState>
    implements ScheduleActionBloc {}

class MockCategoryLoadBloc
    extends MockBloc<CategoryLoadEvent, CategoryLoadState>
    implements CategoryLoadBloc {}

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

final tIncomeTransactions = [
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
];

final tExpenseTransactions = [
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

final tTransactionsList = [...tIncomeTransactions, ...tExpenseTransactions];

final tScheduleSummary = ScheduleSummary(
  totalAmount: 300.0,
  totalPaid: 200.0,
  totalToPay: 100.0,
  transactions: [
    tExpenseTransactions[0], // sorted by due date
    tExpenseTransactions[1],
  ],
  nextIncomeAmount: 1500.0,
  nextIncomeDate: tDateTime.add(const Duration(days: 3)),
);

final tScheduleSummaryNoIncome = ScheduleSummary(
  totalAmount: tScheduleSummary.totalAmount,
  totalPaid: tScheduleSummary.totalPaid,
  totalToPay: tScheduleSummary.totalToPay,
  transactions: tScheduleSummary.transactions,
);
