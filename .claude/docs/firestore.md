# Cloud Firestore Documentation (firestore.md)

This document describes the database architecture, collections, queries, pagination, batch transactions, security rules, and conventions for **Cloud Firestore** in the **DueDay** project.

---

## 🗄️ 1. Subcollection-Based Database Architecture

To ensure strict data isolation and security, DueDay isolates all user data under the authenticated user's root document. This guarantees that a user can never access or modify another user's financial details.

```
/users/{userId}
  ├── accounts/{accountId}
  ├── transactions/{transactionId}
  └── categories/{categoryId}
```

### Collections & Documents Map

#### 1. Users Collection (`/users/{userId}`)
Stores general user profiles and settings:
- **Field Details:**
  - `email` (String)
  - `displayName` (String)
  - `photoUrl` (String)
  - `createdAt` (Timestamp)

#### 2. Accounts Collection (`/users/{userId}/accounts/{accountId}`)
Stores financial bank accounts, credit cards, or cash wallets:
- **Field Details:**
  - `name` (String) — e.g., "Nubank"
  - `type` (String) — e.g., "savings", "investments", "daily_use", "credit_card"
  - `balance` (Double) — e.g., `3450.00`
  - `dueDate` (Timestamp) — Optional, used for card statements
  - `createdAt` (Timestamp)

#### 3. Transactions Collection (`/users/{userId}/transactions/{transactionId}`)
Stores revenues, expenses, and inter-account transfers:
- **Field Details:**
  - `type` (String) — "income", "expense", "transfer"
  - `amount` (Double)
  - `category` (String) — Reference ID to category document
  - `accountFrom` (String) — Source account ID (for expense/transfer)
  - `accountTo` (String) — Destination account ID (for income/transfer)
  - `dueDate` (Timestamp) — Optional, due date for schedules
  - `paidDate` (Timestamp) — Optional, date transaction was executed
  - `paid` (Boolean) — Execution status
  - `isRecurring` (Boolean)
  - `description` (String)
  - `createdAt` (Timestamp)

#### 4. Categories Collection (`/users/{userId}/categories/{categoryId}`)
Stores custom financial categories defined by the user:
- **Field Details:**
  - `name` (String) — e.g., "Dining Out"
  - `color` (String) — Hex color code (e.g., "#FF5722")
  - `icon` (String) — Glyphs or icon names
  - `createdAt` (Timestamp)

---

## 🛡️ 2. Security Rules (`firestore.rules`)

The security settings are written in `/Users/tainass/Personal/Projetos Pessoais/due_day/firestore.rules`.
Access is restricted strictly using `request.auth.uid == userId`. No document reads or writes can bypass this rule.

```firestore
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Matches the root user document
    match /users/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;

      // Restricts access to user's nested accounts
      match /accounts/{accountId} {
        allow read, write: if request.auth != null && request.auth.uid == userId;
      }

      // Restricts access to user's transactions
      match /transactions/{transactionId} {
        allow read, write: if request.auth != null && request.auth.uid == userId;
      }

      // Restricts access to user's custom categories
      match /categories/{categoryId} {
        allow read, write: if request.auth != null && request.auth.uid == userId;
      }
    }
  }
}
```

---

## 🔍 3. Queries, Filtering & Indexing

- **Real-Time Data Flow:** Data sources must use `.snapshots()` to stream updates directly to BLoCs, enabling real-time visual synchronization on screen.
- **Index Optimization:** Compound queries (e.g., filtering transactions by date range AND category ID) require custom Firestore indexes. Ensure indexes are created by running the app and clicking the generated link in the debug console if a `QueryRequiredException` occurs.
- **Query Guidelines:**
  ```dart
  FirebaseFirestore.instance
      .collection('users')
      .doc(userId)
      .collection('transactions')
      .where('dueDate', isGreaterThanOrEqualTo: startDate)
      .where('dueDate', isLessThanOrEqualTo: endDate)
      .orderBy('dueDate', descending: true);
  ```

---

## 🔄 4. Batch Operations & Transactions

- **Inter-Account Transfers:** When creating a "transfer" type transaction, always run a **Firestore Transaction** or **Batch** write to modify both accounts' balances together. If one operation fails, the transaction reverts to keep balance statements accurate.
- **Transaction Guideline:**
  ```dart
  final batch = firestore.batch();
  batch.set(transactionRef, transactionData);
  batch.update(accountFromRef, {'balance': FieldValue.increment(-amount)});
  batch.update(accountToRef, {'balance': FieldValue.increment(amount)});
  await batch.commit();
  ```

---

## ⚡ 5. Offline Support

Firestore is configured with offline caching enabled. When the device is offline:
1. Writes are stored locally and synced immediately upon reconnecting.
2. Read operations fetch cached queries automatically.
3. Handle stream synchronization issues in BLoCs to keep progress spinners from running infinitely.
