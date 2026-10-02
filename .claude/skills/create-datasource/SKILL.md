---
name: create-datasource
description: Use when implementing a Remote or Local DataSource in DueDay's Data layer. Covers the abstract-contract-plus-concrete-implementation pattern and raw exception handling (ServerException/CacheException).
---

# Create DataSource

## Rules

- Abstract contract + `Impl` class, so it can be mocked.
- Returns models. Never returns `Either`.
- On failure, throws `ServerException` (remote) or `CacheException` (local) with a technical English message and the original `e.code`.
- No logging here; the repository logs.

## Template

```dart
abstract class AccountRemoteDataSource {
  Future<List<AccountModel>> getAccounts(String userId);
}

class AccountRemoteDataSourceImpl implements AccountRemoteDataSource {
  final FirebaseFirestore firestore;
  const AccountRemoteDataSourceImpl({required this.firestore});

  @override
  Future<List<AccountModel>> getAccounts(String userId) async {
    try {
      final snap = await firestore.collection('users').doc(userId).collection('accounts').get();
      return snap.docs.map((d) => AccountModel.fromJson(d.data()..['id'] = d.id)).toList();
    } on FirebaseException catch (e) {
      throw ServerException(e.message ?? 'Failed to fetch accounts.', e.code);
    } catch (e) {
      throw ServerException('Failed to fetch accounts: $e');
    }
  }
}
```
