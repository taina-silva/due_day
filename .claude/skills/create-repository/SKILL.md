---
name: create-repository
description: Use when implementing a repository in DueDay that bridges the Data and Domain layers. Covers separating the domain-facing interface from the data-layer implementation and converting exceptions into Either<Failure, T>.
---

# Create Repository

## Rules

- **Contract** in `domain/repositories/`: entities only, no models or Firebase.
- **Implementation** in `data/repositories/`: calls datasources, converts models to entities, catches exceptions and returns `Left(Failure)`.
- Injects `ObservabilityService observability` and logs in **every** catch block ([observability.md](../../docs/observability.md)).
- Fallback failure per operation: reads → `ServerFailure`; add/update → `XSaveFailure`; delete → `XDeleteFailure` ([coding_standards.md](../../docs/coding_standards.md#error-handling)).

## Template

```dart
// domain/repositories/account_repository.dart
abstract class AccountRepository {
  Future<Either<Failure, List<AccountEntity>>> getAccounts(String userId);
}

// data/repositories/account_repository_impl.dart
class AccountRepositoryImpl implements AccountRepository {
  final AccountRemoteDataSource remoteDataSource;
  final ObservabilityService observability;

  const AccountRepositoryImpl({required this.remoteDataSource, required this.observability});

  @override
  Future<Either<Failure, List<AccountEntity>>> getAccounts(String userId) async {
    try {
      final models = await remoteDataSource.getAccounts(userId);
      return Right(models.map((m) => m.toEntity()).toList());
    } on ServerException catch (e) {
      observability.error('getAccounts failed', tag: 'accounts', error: e, stackTrace: StackTrace.current);
      return Left(ServerFailure(e.message));
    } catch (e, st) {
      observability.error('getAccounts unexpected failure', tag: 'accounts', error: e, stackTrace: st);
      return Left(GenericFailure(e.toString()));
    }
  }
}
```
