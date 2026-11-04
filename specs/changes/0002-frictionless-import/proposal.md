# 0002 — Frictionless import

Status: approved

Depends on: `0001` (system categories, card bill parser, format detection, no balances). Requirement IDs continue from `0001`'s delta.

## Why

Import is the main input (D4) and should take ~5 minutes a week. Today it costs much more:

- Every new item arrives uncategorized: `BuildReviewList` only sets the duplicate status (`lib/features/statement_import/domain/usecases/build_review_list.dart`). 60 card purchases mean 60 taps, every week, for the same merchants.
- The review list shows new items in file order (`import_review_list.dart`); the ones that still need a category are mixed with the rest.
- Scheduled bills are duplicated: `ConfirmImport` always creates new transactions (`confirm_import.dart`), so a bill registered as unpaid stays unpaid and the statement line is added next to it. Planned and Spent both drift.
- Getting the file in takes several steps: Transactions → History → Import (`transaction_history_page.dart`) → system picker → find the file. The manifest has no intent filter for statements (`android/app/src/main/AndroidManifest.xml`).
- Nothing prompts the weekly habit. `NotificationService` only schedules one-off bill reminders, has no tap handling, and Android 13+ notification permission is never requested (`lib/core/services/notification_service.dart`).
- The import account picker can't create an account (`account_selection_bottom_sheet.dart`); a new user has to leave the flow, create it, and start over.

## What

- **Learned rules (D7):** confirming an import saves `direction + normalized memo → category` for every categorized item. Future imports arrive pre-categorized; a different choice overwrites the rule. Stored in Firestore under the user (synced, removed by "Delete all my data"). **No investment seeds** (decision: Pix to merchants often goes through Mercado Pago, so a memo seed would misfire); the bill payment stays covered by IMP-008.
- **Review list:** "Uncategorized" section first with its count; then categorized; then already imported. Uncategorized imports are still allowed.
- **Matching (D9):** an imported expense matches an unpaid, non-template scheduled expense due within ±5 days and with amount within ±15%. Default: mark the scheduled item paid (statement date, amount, and account; keep category; store `externalId`). Several candidates → user picks; "Not this one" → import as new.
- **Open with / Share to DueDay (Android):** intent filters for `ACTION_VIEW` and `ACTION_SEND` of CSV/OFX files; the app opens the import with the file already loaded (straight to the account picker). Native `MethodChannel` in `MainActivity`, no new dependency.
- **Sunday reminder:** weekly local notification Sunday 19:00 that opens the import; on by default; toggle in Settings stored on-device (Hive). Android notification permission is requested.
- **"+ New account"** at the end of the import account picker; the created account is selected and the import continues.

## Out of scope

Rule management screen and learning from category edits outside the import (`0004` uses rules in the manual form); iOS "Open with"; other banks; matching income or recurring templates; matching against items already paid; bill reminder changes (`0004`); new navigation and the central "+" (`0003`).

## Impacted capabilities

`statement-import`, `categories`, `schedule-and-reminders` (created here), `settings`.

## Docs to update

- `.claude/docs/firestore.md`: `categoryRules/{key}` collection; delete-all includes it.
- `.claude/docs/notifications.md`: weekly import reminder (id, schedule mode), tap payload routing, Android permission request, bill reschedule no longer cancels everything.
- `.claude/docs/navigation.md`: incoming file and notification tap → `/transactions/import`.
