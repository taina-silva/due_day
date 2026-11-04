# 0004 — Manual entry and reminders

Status: approved

Depends on: `0001`–`0003`. Requirement IDs continue from their deltas.

## Why

Manual entry is now the exception (D4), but when it's needed it must be fast, and the bills it creates must remind the user on time. Today:

- **The form asks too much and stores the wrong thing.** `TransactionCreateForm` (`lib/features/transactions/presentation/widgets/form/transaction_create_form.dart`) has separate "from" and "to" account fields, 5 frequencies (`transaction_frequency_selector.dart`), and only an optional `notes` field. There is no description. Nothing is focused when the form opens.
- **Paid items never get a `paidDate`.** `_submit` sets `dueDate` and the `paid` switch but never `paidDate`, and `paid` defaults to true even for a future date. Spent (DSH-003) and the effective date (TRX-003) depend on both.
- **No description.** The model has no `description` (`transaction_model.dart`). Imports put the memo in `notes` (`confirm_import.dart`), and lists, schedule, and reminders read `notes` with a generic fallback (`transaction_item.dart`, `schedule_item_card.dart`, `transaction_load_bloc.dart`).
- **Recurring bills stop after one copy.** `SyncRecurringTransactions` always computes the next date from the template's own `dueDate`, so it creates one instance and then stops (`sync_recurring_transactions.dart` `_calculateNextDate`). It only creates an instance after its due date, so the "due tomorrow" reminder never fires for recurring bills. The instance copies the template's `paid`, so an "auto-paid" bill counts as Spent before it happens and is duplicated by the import. It still adjusts account balances (removed in `0001`). It runs only when the dashboard opens (`dashboard_page.dart`).
- **Templates and occurrences disagree across changes.** A recurring template is its own first occurrence (it has a due date and counts in Spent when paid), but `0002` IMP-014 excludes templates from matching and `0003` DSH-010 excludes them from Planned. An unpaid first rent therefore counts nowhere and can't be matched.
- **Reminders.** Bill reminders fire at 08:00 and are scheduled inside `TransactionLoadBloc` (`transaction_load_bloc.dart`) only when its stream emits. They aren't refreshed on language change, sign-out, or the push toggle, they use sequential ids after `cancelAll()`, and they format amounts with a `$` symbol. The Android channel name and description are hardcoded in Portuguese (`lib/core/services/notification_service.dart`). There is no credit card due-day reminder, although accounts have `dueDay` (`account_entity.dart`).

## What

- **Form** (sheet from the "+" → "Add manually", `0003` NAV-002), in order: Expense | Income → amount (autofocus) → **description** (required; suggests a category from learned rules, CAT-006) → category → **account** (single field, defaults to the last used one) → date (today) → **Paid** switch derived from the date (≤ today = paid, future = scheduled; can be overridden) → repeat (Doesn't repeat / Monthly / Yearly) → notes under "More options".
- **Paid** items store `paidDate` = the date. Unpaid items have no `paidDate`.
- **Description** is a new stored field. Imports store the memo as description. Old items without one show `notes`, then the category name.
- **Recurring (decision):** a template is the first occurrence. On app start, every missing occurrence due up to the **end of next month** is created, **always unpaid**. The import's match (IMP-014) marks it paid. Unpaid templates count in Planned and can be matched.
- **Reminders:**
  - unpaid expenses: 1 day before and on the day, 09:00;
  - credit card bill **(decision):** 3 days before and on the account's due day, 09:00, no amount;
  - rescheduled on app start, after transaction or account changes, on language change, and on the push toggle; cancelled on sign-out;
  - localized channel and texts; amounts in R$.

## Out of scope

- Push/FCM; notifications inbox changes (reminders keep adding entries as today).
- Learning rules from the manual form or from category edits; rule management screen.
- Weekly / bi-weekly recurrence (legacy templates stop generating).
- Editing or deleting a whole series at once. Editing a template affects only occurrences created after the edit.
- Bill amounts in the card reminder (no balances, D2).
- Per-account reminder settings.

## Impacted capabilities

`transactions`, `schedule-and-reminders`, `statement-import`, `dashboard`.

## Docs to update

- `.claude/docs/notifications.md`: bill and card reminders, times, stable ids, refresh triggers, localized channel, `cancelBillReminders` scope.
- `.claude/skills/add-notification/SKILL.md`: if the scheduling recipe changes (stable ids, localized channel).
- `.claude/docs/firestore.md`: transaction `description` field; recurring occurrences are always created unpaid.
