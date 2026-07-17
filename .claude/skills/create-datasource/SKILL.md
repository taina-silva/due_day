---
name: create-datasource
description: Use when implementing a Remote or Local DataSource in DueDay's Data layer. Covers the abstract-contract-plus-concrete-implementation pattern and raw exception handling (ServerException/CacheException).
---

# Standard Procedure: Create DataSource

This guide describes how to implement a Remote or Local DataSource in the **Data Layer** of the **DueDay** application.

---

## 🛠️ DataSource Creation Pattern

### Rule 1: Abstract contract and concrete implementation
Always declare an abstract class interface to define the DataSource contract first, followed by the concrete framework-tied implementation class. This facilitates unit testing by allowing the DataSource interface to be easily mocked.

### Rule 2: Exception handling
DataSources deal with raw infrastructure exceptions (such as `FirebaseException` or local caching failures). They should not return `Either` or handle failures themselves. If an operation fails, the DataSource must throw a raw exception (e.g. `ServerException` or `CacheException`) using a technical English message for debugging/logging, and propagating the original or custom error code (`e.code`).

---

## 📝 Remote DataSource Template

### 1. Abstract Interface Contract
```dart
import 'package:due_day/features/accounts/data/models/account_model.dart';

abstract class AccountRemoteDataSource {
  /// Fetches accounts from Firestore.
  /// Throws [ServerException] on database errors.
  Future<List<AccountModel>> getAccounts(String userId);
}
```

### 2. Concrete Firebase Implementation
```dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:due_day/core/errors/exceptions.dart';
import 'package:due_day/features/accounts/data/models/account_model.dart';
import 'account_remote_data_source.dart';

class AccountRemoteDataSourceImpl implements AccountRemoteDataSource {
  final FirebaseFirestore firestore;

  const AccountRemoteDataSourceImpl({required this.firestore});

  @override
  Future<List<AccountModel>> getAccounts(String userId) async {
    try {
      final snapshot = await firestore
          .collection('users')
          .doc(userId)
          .collection('accounts')
          .get();

      return snapshot.docs
          .map((doc) => AccountModel.fromJson(doc.data()..['id'] = doc.id))
          .toList();
    } on FirebaseException catch (e) {
      // DataSources throw raw exceptions with technical English messages and error codes
      throw ServerException(e.message ?? 'Failed to fetch accounts.', e.code);
    } catch (e) {
      throw ServerException('Failed to fetch accounts: $e');
    }
  }
}
```
