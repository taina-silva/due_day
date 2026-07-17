---
name: create-usecase
description: Use when creating a Domain-layer UseCase in DueDay. Covers the pure-Dart, single-responsibility, callable-class (call(...)) pattern returning Future<Either<Failure, T>>.
---

# Standard Procedure: Create UseCase

This guide describes how to create a Domain UseCase following the coding standards of the **DueDay** application.

---

## 🛠️ UseCase Creation Pattern

### Rule 1: Pure Dart
UseCases live inside the Domain layer. They must remain pure Dart files and contain no reference to Flutter, Firebase, or external UI modules.

### Rule 2: Single Responsibility
A UseCase must perform one specific task. Do not combine unrelated actions. E.g., create separate files for `AddAccount` and `GetAccounts`.

### Rule 3: Callable Class Interface
UseCases should be written as callable classes by implementing the `call(...)` method, allowing them to be invoked directly like a function (e.g. `useCase(params)`).

---

## 📝 UseCase Template

### 1. Define Parameters (Optional)
If the UseCase requires multiple parameters, define a simple parameter container class at the bottom of the file or in a separate params file:
```dart
import 'package:equatable/equatable.dart';

class AddTransactionParams extends Equatable {
  final String accountId;
  final double amount;

  const AddTransactionParams({
    required this.accountId,
    required this.amount,
  });

  @override
  List<Object?> get props => [accountId, amount];
}
```

### 2. Implement the UseCase
```dart
import 'package:fpdart/fpdart.dart';
import 'package:due_day/core/errors/failures.dart';
import 'package:due_day/features/transactions/domain/repositories/transaction_repository.dart';

class AddTransaction {
  final TransactionRepository repository;

  // Repository is injected via GetIt
  const AddTransaction(this.repository);

  // Implementing the callable 'call' signature returning fpdart Either
  Future<Either<Failure, void>> call(AddTransactionParams params) async {
    return repository.addTransaction(
      accountId: params.accountId,
      amount: params.amount,
    );
  }
}
```
