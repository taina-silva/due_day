---
name: create-usecase
description: Use when creating a Domain-layer UseCase in DueDay. Covers the pure-Dart, single-responsibility, callable-class (call(...)) pattern returning Future<Either<Failure, T>>.
---

# Create UseCase

## Rules

- Lives in `domain/usecases/`. Pure Dart: no Flutter, no Firebase.
- One action per class (`AddAccount`, `GetAccounts`).
- Callable: `call(...)` returns `Future<Either<Failure, T>>` (or a `Stream` of it for live lists).
- Repository injected through the constructor.
- Several params → an `Equatable` params class.

## Template

```dart
class AddTransaction {
  final TransactionRepository repository;
  const AddTransaction(this.repository);

  Future<Either<Failure, void>> call(TransactionEntity transaction) =>
      repository.addTransaction(transaction);
}
```

Pure calculations with no I/O (e.g. `GetDashboardSummary`) can return the value directly.
