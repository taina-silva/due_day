# 0001 — Reliable numbers

Status: done

## Why

The numbers can't be trusted, so the app isn't used:

- The dashboard groups by `createdAt` (when the document was written) with no upper date bound (`lib/features/dashboard/domain/usecases/get_dashboard_summary.dart`). Importing 3 months today counts them all as "this month". There is no way to look at another month.
- Account balances need manual reconciliation (D2). Balance math is duplicated in `transaction_usecases.dart`, `sync_recurring_transactions.dart`, and `statement_import_repository_impl.dart` (`_applyNetBalanceDelta`), and shown in `accounts_page.dart`, `account_card.dart`, `financial_health_card.dart`, and the account picker.
- `transfer` still exists as a type (`transaction_entity.dart`, form, filter bar) although it is neither spending nor income without balances (D3).
- Account types (`investments`, `savings`, `daily_use`, `credit_card` in `account_category.dart`) don't match how money is spent; investment destinations are categories now (D6).
- OFX import fails on Android: `FileType.custom` + `'ofx'` needs a MIME type Android doesn't know, and files are always decoded as UTF-8 (`lib/core/services/statement_file_picker_service.dart`). Format is chosen by file extension (`statement_import_repository_impl.dart`).
- The Nubank card bill CSV (`date,title,amount`) is rejected: only the checking header `Data,Valor,Identificador,Descrição` is accepted (`csv_statement_parser.dart`).
- A new user has no categories, and nothing distinguishes *Investment* or *Ignored* from spending.
- There is no way to start from scratch (D10): "Delete account" in the profile is a dev stub (`account_actions.dart`).

Smallest slice that lets the user start from scratch and import 2–3 months correctly, even with the current UI.

## What

- **Dashboard:** group by effective date (`paidDate`, else `dueDate`, else `createdAt`), bounded to the selected month; simple month selector (previous / next) on the current dashboard. Spent excludes *Investment* and *Ignored*; Invested is shown. The balance card (`FinancialHealthCard`) is removed.
- **No balances:** removed from the account entity/model, forms, cards, pickers, transaction use cases, recurring sync, import, and dashboard. Legacy `balance` fields in Firestore are ignored.
- **No `transfer`:** can't be created or filtered; legacy transfers still load and are excluded from every total.
- **Account types:** `checking`, `credit_card` (due day), `cash`. Legacy values read as `checking`.
- **Category `kind`:** `spending` (default) / `investment` / `ignored`. System *Investment* and *Ignored* are auto-created (fixed ids), shown with localized names, and can't be renamed or deleted.
- **Default categories** on first use (no categories at all): Food, Groceries, Transport, Housing, Bills, Health, Leisure, Shopping, Subscriptions, Education, Other; Salary, Other income — named in the current app language.
- **Import fixes:** pick any file, then validate by content; UTF-8 with Latin-1 fallback; detect the format (Nubank OFX, checking CSV, card bill CSV) by content and list accounts of the matching type first.
- **Card bill CSV parser:** ISO dates; positive = purchase (expense), negative = credit (income); dedup id = date + title + amount + occurrence index; dated on purchase; installment `N/M` is dated purchase date + (N−1) months so it counts in the month it's billed.
- **Pre-categorized to *Ignored*:** card bill payment in the checking statement and "payment received" in the card bill. Card refunds arrive as uncategorized income.
- **"Delete all my data"** in the profile (current settings screen), with confirmation: deletes accounts, categories, and transactions; keeps login and profile.
- Legacy documents without the new fields still render.

## Out of scope

Learned rules, matching, "Open with", "+ New account" in import (`0002`); new navigation, Home layout, Planned, vs last month, category drill-down, insight card removal (`0003`); description field and new form, reminders (`0004`). Fixing the unused `createdAt` string filters in `TransactionRemoteDataSource.getTransactions` (the dashboard filters in memory). Firebase Auth account deletion.

## Impacted capabilities

`dashboard`, `accounts`, `categories`, `transactions`, `statement-import`, `settings` (all created here).

## Docs to update

`.claude/docs/firestore.md` (schema: accounts without `balance`, new account types, category `kind`, transaction `type` without `transfer`, delete-all batch). No other doc mentions balances or transfers.
