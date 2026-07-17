---
name: create-repository
description: Use when implementing a repository in DueDay that bridges the Data and Domain layers. Covers separating the domain-facing interface from the data-layer implementation and converting exceptions into Either<Failure, T>.
---

# Standard Procedure: Create Repository

This guide describes how to implement a repository in the **DueDay** application, bridging the Data and Domain layers.

---

## 🛠️ Repository Creation Pattern

### Rule 1: Separation of Contract and Implementation
- **Repository Interface:** Lives in `domain/repositories/` and uses pure Domain entities (no Models or Firebase imports).
- **Repository Implementation:** Lives in `data/repositories/` and coordinates DataSources, converts Models into Entities, and handles error mapping.

### Rule 2: Exception Conversion
Repositories must never let raw infrastructure exceptions bubble up to UseCases or the UI. They are responsible for catching exceptions (like `ServerException`) and returning them as a `Left(Failure)`.

---

## 📝 Repository Implementation Template

### 1. Abstract Domain Interface (`domain/repositories/account_repository.dart`)
```dart
import 'package:fpdart/fpdart.dart';
import 'package:due_day/core/errors/failures.dart';
import 'package:due_day/features/accounts/domain/entities/account_entity.dart';

abstract class AccountRepository {
  Future<Either<Failure, List<AccountEntity>>> getAccounts(String userId);
}
```

### 2. Concrete Data Implementation (`data/repositories/account_repository_impl.dart`)
```dart
import 'package:fpdart/fpdart.dart';
import 'package:due_day/core/errors/exceptions.dart';
import 'package:due_day/core/errors/failures.dart';
import 'package:due_day/features/accounts/data/datasources/account_remote_data_source.dart';
import 'package:due_day/features/accounts/domain/entities/account_entity.dart';
import 'package:due_day/features/accounts/domain/repositories/account_repository.dart';

class AccountRepositoryImpl implements AccountRepository {
  final AccountRemoteDataSource remoteDataSource;

  const AccountRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, List<AccountEntity>>> getAccounts(String userId) async {
    try {
      final models = await remoteDataSource.getAccounts(userId);
      
      // Convert Data Models to Domain Entities
      final entities = models.map((model) => model.toEntity()).toList();
      
      return Right(entities);
    } on ServerException catch (e) {
      if (e.code == 'account-limit-exceeded') {
        return const Left(AccountLimitExceededFailure());
      }
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(GenericFailure(e.toString()));
    }
  }
}
```
