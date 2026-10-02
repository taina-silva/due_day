# 0001 — Reliable numbers

Status: proposed (draft; `/spec-propose 0001` writes `spec-delta.md` and `tasks.md`)

## Why

The numbers can't be trusted, so the app isn't used:

- The dashboard groups by `createdAt` (when the document was written) with no upper date bound (`get_dashboard_summary.dart`). Importing 3 months today counts them all as "this month".
- Account balances need manual reconciliation (D2).
- OFX import fails on Android: `FileType.custom` + `'ofx'` needs a MIME type Android doesn't know, and files are always decoded as UTF-8 (`statement_file_picker_service.dart`).
- The Nubank card bill CSV (`date,title,amount`) is rejected (`csv_statement_parser.dart`).
- A new user has no categories.

Smallest slice that lets the user start from scratch and import 2–3 months correctly, even with the current UI.

## What

- **Dashboard:** group by effective date (`paidDate`, else `dueDate`), bounded to the selected month; add a month selector.
- **No balances:** remove from accounts, transactions, import, and dashboard.
- **No `transfer`:** legacy transfers are ignored in calculations.
- **Account types:** `checking`, `credit_card` (due day), `cash`; legacy values read tolerantly.
- **Category `kind`:** `spending` / `investment` / `ignored`. System *Investment* and *Ignored* are auto-created and can't be deleted. Spending excludes both; *Invested* is computed.
- **Default categories** on first use: Food, Groceries, Transport, Housing, Bills, Health, Leisure, Shopping, Subscriptions, Education, Other; Salary, Other income (localized).
- **Import fixes:** pick any file, then validate; UTF-8 with Latin-1 fallback; detect format by content and preselect the account type.
- **Card bill CSV parser:** ISO dates, positive = purchase; dedup id = date + title + amount + occurrence index; dated on purchase; installments count in the month they appear.
- Card bill payment in the checking statement → *Ignored*.
- **"Delete all my data"** in Settings, with confirmation.
- Legacy documents without the new fields still render.

## Out of scope

Learned rules, matching, "Open with" (`0002`); new navigation and dashboard (`0003`); description field and new form (`0004`).

## Impacted capabilities

`statement-import`, `dashboard`, `accounts`, `categories`, `transactions` (created here).

## Docs to update

`.claude/docs/firestore.md` (schema).
