# Cloud Firestore Documentation (firestore.md)

This document describes the database architecture, collections, queries, pagination, batch transactions, security rules, and conventions for **Cloud Firestore** in the **DueDay** project.

---

## 🗄️ 1. Subcollection-Based Database Architecture

To ensure strict data isolation and security, DueDay isolates all user data under the authenticated user's root document. This guarantees that a user can never access or modify another user's financial details.

```
/users/{userId}
  ├── accounts/{accountId}       — bank accounts, credit cards, cash wallets
  ├── transactions/{transactionId} — income, expense, and transfer records
  └── categories/{categoryId}    — user-defined transaction labels
```

Full field-by-field schema (types, descriptions, entity relationships) lives in [firestore_schema.md](../references/firestore_schema.md).

---

## 🛡️ 2. Security Rules (`firestore.rules`)

The canonical rules live in `firestore.rules` at the repo root — that file is the single source of truth; do not copy its contents into documentation. Access is restricted strictly using `request.auth.uid == userId` at the root `/users/{userId}` match and every nested subcollection (`accounts`, `transactions`, `categories`) inherits the same check. No document reads or writes can bypass this rule.

To deploy a change: `firebase deploy --only firestore:rules` (setup prerequisites in [firebase_setup.md](../references/firebase_setup.md)).

---

## 🔍 3. Queries, Filtering & Indexing

- **Real-Time Data Flow:** Data sources must use `.snapshots()` to stream updates directly to BLoCs, enabling real-time visual synchronization on screen.
- **Index Optimization:** Compound queries (e.g., filtering transactions by date range AND category ID) require custom Firestore indexes. Ensure indexes are created by running the app and clicking the generated link in the debug console if a `QueryRequiredException` occurs.

Full query template (filtering, ordering, stream mapping) lives in [create-firestore-query](../skills/create-firestore-query/SKILL.md).

---

## 🔄 4. Batch Operations & Transactions

- **Inter-Account Transfers:** When creating a "transfer" type transaction, always run a **Firestore Transaction** or **Batch** write to modify both accounts' balances together. If one operation fails, the transaction reverts to keep balance statements accurate.

Full batch-write template lives in [create-firestore-query §Batch Document Write](../skills/create-firestore-query/SKILL.md).

---

## ⚡ 5. Offline Support

Firestore is configured with offline caching enabled. When the device is offline:
1. Writes are stored locally and synced immediately upon reconnecting.
2. Read operations fetch cached queries automatically.
3. Handle stream synchronization issues in BLoCs to keep progress spinners from running infinitely.
