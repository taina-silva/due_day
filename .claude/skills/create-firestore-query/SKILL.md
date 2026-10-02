---
name: create-firestore-query
description: Use when writing or optimizing Firestore queries and data streams in DueDay. Covers user-scoped security paths, real-time snapshot streams, composite indexing, and batch/transactional writes.
---

# Create Firestore Query

Rules and schema: [firestore.md](../../docs/firestore.md).

- Always start from `/users/{userId}`.
- Live lists use `.snapshots()`.
- Compound filters need a composite index (follow the link in the debug console error).
- Multi-document writes use `batch()` or `runTransaction()`.

## Stream with filters

```dart
Stream<List<TransactionModel>> watchTransactions(String userId, DateTime start, DateTime end, {String? categoryId}) {
  Query<Map<String, dynamic>> q = firestore
      .collection('users').doc(userId).collection('transactions')
      .where('dueDate', isGreaterThanOrEqualTo: start)
      .where('dueDate', isLessThanOrEqualTo: end);
  if (categoryId != null) q = q.where('category', isEqualTo: categoryId);

  return q.orderBy('dueDate', descending: true).snapshots().map(
        (s) => s.docs.map((d) => TransactionModel.fromJson(d.data()..['id'] = d.id)).toList(),
      );
}
```

## Batch Document Write

```dart
final batch = firestore.batch();
final userRef = firestore.collection('users').doc(userId);

batch.set(userRef.collection('transactions').doc(tx.id), tx.toJson());
batch.update(userRef.collection('categories').doc(tx.category), {'transactionCount': FieldValue.increment(1)});

await batch.commit();
```
