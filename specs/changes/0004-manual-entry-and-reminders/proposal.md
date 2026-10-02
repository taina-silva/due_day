# 0004 — Manual entry and reminders

Status: proposed (draft; `/spec-propose 0004` writes `spec-delta.md` and `tasks.md`)

Depends on: `0001`–`0003`.

## Why

Manual entry is now the exception but must be fast. The form has 3 types, separate from/to accounts, 5 frequencies, no description, and never sets `paidDate`. Reminders are rescheduled only when `TransactionLoadBloc` loads, and the Android channel name is hardcoded in Portuguese (`notification_service.dart`).

## What

- **Form**, in order: Expense | Income → amount (autofocus) → **description** (required; suggests a category from learned rules) → category → account (single field, defaults to last used) → date (today; **paid derived**: ≤ today = paid + `paidDate`, future = scheduled; toggle to override) → repeat (monthly / yearly) → notes under "More options".
- Imports use the memo as description; legacy items without one show the category name.
- **Reminders:**
  - unpaid scheduled expenses: 1 day before and on the day, 09:00;
  - card bill: N days before the account's due day;
  - rescheduled on app start and after transaction changes;
  - localized channel and texts.

## Out of scope

Push/FCM; inbox changes.

## Impacted capabilities

`transactions`, `schedule-and-reminders`.

## Docs to update

`.claude/docs/notifications.md`, `add-notification` skill.
