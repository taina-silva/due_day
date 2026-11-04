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
| `category` | String | Account type: `checking`, `credit_card`, `cash`. Legacy values (`investments`, `savings`, `daily_use`, unknown) read as `checking` |
| `dueDay` | Int? | Credit card bill day (1–31); only for `credit_card` |
| `createdAt` | Timestamp | |
| `deletedAt` | Timestamp? | Soft delete |

Accounts have **no balance**: a legacy `balance` field is ignored on read and not written. No transaction write ever touches an account document.

### `categories/{id}`

| Field | Type | Notes |
| :--- | :--- | :--- |
| `id`, `userId`, `name` | String | |
| `color` | String | Hex |
| `icon` | String | Icon id |
| `transactionCount` | Int | Counter kept in sync by batch writes; default 0 |
| `kind` | String | `spending` (default; missing or unknown reads as `spending`), `investment`, `ignored` |
| `createdAt` | Timestamp | |

Fixed document ids: system categories `system_investment` (`kind: investment`) and `system_ignored` (`kind: ignored`), created when missing; their stored `name` is a constant and the UI shows a localized name. Default categories seeded on first use (no categories at all) use `default_<key>` ids, written in one batch, so a repeated seed overwrites instead of duplicating.

### `transactions/{id}`

| Field | Type | Notes |
| :--- | :--- | :--- |
| `id`, `userId` | String | |
| `type` | String | `income`, `expense`. Legacy `transfer` still loads but can't be created and counts in no total |
| `amount` | Double | Always positive |
| `category` | String? | Category id |
| `accountFrom` / `accountTo` | String? | Source (expense) / destination (income); both on legacy transfers |
| `dueDate` / `paidDate` | Timestamp? | |
| `paid`, `isRecurring` | Boolean | |
| `frequency` | String? | `none`, `weekly`, `biWeekly`, `monthly`, `yearly` |
| `parentRecurringId` | String? | Recurring template id |
| `notes` | String? | Statement memo on imports |
| `externalId` | String? | Import dedup key: `rawIdentifier\|amountInCents` (OFX, checking CSV) or `card\|rawDate\|title\|amountInCents\|occurrence` (card bill CSV) |
| `importSource` | String? | `ofx`, `csv`, or null (manual) |
| `createdAt` | Timestamp | When written, **not** when the money moved. Month grouping uses `paidDate ?? dueDate ?? createdAt` |

## Delete all user data

"Delete all my data" deletes every document in `accounts`, `categories`, and `transactions` under `/users/{userId}` (soft-deleted accounts included) in batches of at most 450 writes, one collection at a time. The user document stays. Code: `UserDataRemoteDataSourceImpl`.
