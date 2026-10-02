# Firestore

Recipe: [create-firestore-query](../skills/create-firestore-query/SKILL.md). Keep the schema below in sync with `lib/features/*/data/models/` in the same change that alters a model.

## Rules

- All user data lives under `/users/{userId}/…`. `firestore.rules` (repo root, source of truth) allows access only when `request.auth.uid == userId`. Deploy: `firebase deploy --only firestore:rules`.
- Lists are streamed with `.snapshots()`.
- Writes touching more than one document use a **batch** or **transaction** (e.g. a transaction + its category counter, an import batch).
- Compound queries need composite indexes (follow the link in the debug console error).
- Offline cache is on: writes queue and sync later, reads serve cache. BLoCs must not spin forever while offline.
- References (`category`, `accountFrom`, `accountTo`) store raw document ids. Deleting an account or category must handle its transactions.
- The notifications inbox is in Hive, not Firestore.

## Schema

### `/users/{userId}`

`uid`, `email`, `name?`, `photoUrl?` (URL or inline compressed base64 JPEG, since there is no Storage), `themePreference?`, `createdAt`.

### `accounts/{id}`

| Field | Type | Notes |
| :--- | :--- | :--- |
| `id`, `userId`, `name` | String | |
| `category` | String | `investments`, `savings`, `daily_use`, `credit_card` |
| `balance` | Double | Adjusted by paid transactions |
| `dueDay` | Int? | Credit card bill day (1–31) |
| `createdAt` | Timestamp | |
| `deletedAt` | Timestamp? | Soft delete |

### `categories/{id}`

| Field | Type | Notes |
| :--- | :--- | :--- |
| `id`, `userId`, `name` | String | |
| `color` | String | Hex |
| `icon` | String | Icon id |
| `transactionCount` | Int | Counter kept in sync by batch writes; default 0 |
| `createdAt` | Timestamp | |

### `transactions/{id}`

| Field | Type | Notes |
| :--- | :--- | :--- |
| `id`, `userId` | String | |
| `type` | String | `income`, `expense`, `transfer` |
| `amount` | Double | Always positive |
| `category` | String? | Category id |
| `accountFrom` / `accountTo` | String? | Source (expense, transfer) / destination (income, transfer) |
| `dueDate` / `paidDate` | Timestamp? | |
| `paid`, `isRecurring` | Boolean | |
| `frequency` | String? | `none`, `weekly`, `biWeekly`, `monthly`, `yearly` |
| `parentRecurringId` | String? | Recurring template id |
| `notes` | String? | Statement memo on imports |
| `externalId` | String? | Import dedup key `rawIdentifier\|amountInCents` |
| `importSource` | String? | `ofx`, `csv`, or null (manual) |
| `createdAt` | Timestamp | When written, **not** when the money moved |
