---
name: create-firestore-query
description: Use when writing or optimizing Firestore queries and data streams in DueDay. Covers user-scoped security paths, real-time snapshot streams, composite indexing, and batch/transactional writes.
---

# Standard Procedure: Create Firestore Query

This guide describes how to construct optimized Firestore queries and handle data streams in **DueDay**.

---

## 🛠️ Query Implementation Checklist

1.  **Strict Security Scopes:** Always root queries inside the user's document path `/users/{userId}` to prevent unauthorized access.
2.  **Use Streams (`snapshots`):** Stream updates to the UI in real-time. This ensures that when a transaction is added, it appears instantly on the dashboard.
3.  **Establish Indices:** Compound queries (e.g. filtering transactions by date range AND sorting by creation time) require a custom index. Run the query in debug mode first to generate the console URL and click it to create the index in Firebase.

---

## 📝 Query Implementations

### Real-Time Stream Query
```dart
Stream<List<TransactionModel>> getFilteredTransactions({
  required String userId,
  required DateTime startDate,
  required DateTime endDate,
  String? categoryId,
}) {
  Query query = firestore
      .collection('users')
      .doc(userId)
      .collection('transactions')
      .where('dueDate', isGreaterThanOrEqualTo: startDate)
      .where('dueDate', isLessThanOrEqualTo: endDate);

  if (categoryId != null) {
    query = query.where('category', isEqualTo: categoryId);
  }

  // Order transactions chronologically
  query = query.orderBy('dueDate', descending: true);

  return query.snapshots().map((snapshot) {
    return snapshot.docs
        .map((doc) => TransactionModel.fromJson(doc.data()..['id'] = doc.id))
        .toList();
  });
}
```

### Batch Document Write
Always execute batch writes or transactional blocks when updating multiple documents simultaneously:
```dart
Future<void> executeInterAccountTransfer({
  required String userId,
  required String fromAccountId,
  required String toAccountId,
  required double amount,
  required Map<String, dynamic> transactionData,
}) async {
  final batch = firestore.batch();
  
  final transRef = firestore
      .collection('users')
      .doc(userId)
      .collection('transactions')
      .doc();

  final fromRef = firestore
      .collection('users')
      .doc(userId)
      .collection('accounts')
      .doc(fromAccountId);

  final toRef = firestore
      .collection('users')
      .doc(userId)
      .collection('accounts')
      .doc(toAccountId);

  batch.set(transRef, transactionData);
  batch.update(fromRef, {'balance': FieldValue.increment(-amount)});
  batch.update(toRef, {'balance': FieldValue.increment(amount)});

  await batch.commit();
}
```
