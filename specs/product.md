# DueDay — Product

Last reviewed: 2026-10-02.

## Vision

Help one person understand **where their money goes, simply**. In five seconds the app answers: *how much did I spend this month, on what, and compared with last month?* As a light complement, it reminds them of upcoming bills.

| Priority | Job |
| :--- | :--- |
| Primary | **Spending tracker**: monthly spending by category, month over month |
| Secondary (light) | **Due dates**: upcoming bills, card due day, "planned" spending for the month |
| Not a goal | **Bank mirror**: per-account balances. It needs constant reconciliation, which is why the app went unused. |

**User:** the author, on Android, paying almost everything with **Nubank** (checking + credit card). Mercado Pago, Inter, and XP are only investment destinations.

## Principles

1. **Import first.** Statement import is the main input; manual entry covers cash, bills, and income.
2. **Trustworthy numbers.** "Spent" counts only what happened, on the date it happened. Estimates are labeled "planned".
3. **Low effort.** Target: a ~5-minute weekly import.
4. **Learn, don't ask twice.** A categorized merchant is remembered.
5. **Use before polish.** No refactors until the MVP has been used for 4 weeks.

## Scope

**MVP** (changes `0001`–`0004`):
- Accounts without balance (checking, credit card with due day, cash). Income and expense only. Mandatory description. Monthly and yearly recurrence.
- System categories *Investment* and *Ignored*; default categories on first use.
- Import of Nubank checking (CSV/OFX) and card bill (CSV), with auto-detection, learned category rules, matching with scheduled items, and "Open with DueDay" on Android.
- Dashboard: month selector, Spent vs Planned, vs last month, Income, Invested, uncategorized warning, categories with drill-down.
- Tabs Home · Transactions · Schedule · Settings, plus a central "+" (Import / Manual).
- On-device reminders: bills, card due day, Sunday 19:00 import reminder.
- "Delete all my data".

**Frozen** (exists, no work planned): login, biometrics, profile photo, theme/language, notifications inbox, observability.

**Later:** app rename (after 1 month of use), iOS "Open with", budgets/goals/charts, rule management screen, other banks. Push/FCM is not planned.

**MVP done** = `0001`–`0004` shipped **and** 4 consecutive Sundays of imports.

## Decisions

| # | Decision | Why |
| :--- | :--- | :--- |
| D1 | Spending tracker first, due dates second | The goal is to understand spending simply |
| D2 | Accounts have no balance | Reconciling balances stopped the user from logging |
| D3 | No `transfer` type; card bill payment → *Ignored* | Transfers are neither spending nor income without balances |
| D4 | Import is the primary input | Lowest recurring effort |
| D5 | Import checking + card bill; card spending on purchase date | Category detail without double counting |
| D6 | *Investment* and *Ignored* as category `kind` | Survives renames and both languages |
| D7 | Learned merchant → category rules; uncategorized imports allowed | Fewer taps, never blocks an import |
| D8 | Spent = paid in month; Planned = Spent + unpaid due by month end (current/future months) | Real numbers separate from estimates |
| D9 | Match imports to unpaid scheduled items (±5 days, ±15%) | No duplicates |
| D10 | Start from scratch, no migration | Old data is incomplete |
| D11 | Spec-driven development | Clear target for every change |

## Glossary

| Term | Meaning |
| :--- | :--- |
| Account | Where money is spent from: checking, credit card (with due day 1–31), or cash. No balance. |
| Transaction | Income or expense with description, amount, date, account, and category. |
| Paid | Already happened. Default: date ≤ today. |
| Scheduled | Unpaid, future due date. |
| Recurring | Scheduled, repeats monthly or yearly. |
| Category `kind` | `spending` (default), `investment`, or `ignored`. |
| Investment | System category; shown as *Invested*, never counted as spending. |
| Ignored | System category; counts nowhere (card bill payment, money lent and returned). |
| Spent | Paid expenses with a `spending` category in the selected month. |
| Planned | Spent + unpaid expenses due by the end of the month (current/future months only). |
| Invested | Investment-category total in the month. |
| Review list | Screen where imported items are checked, categorized, and matched before saving. |
| Categorization rule | Learned normalized memo → category. |
| Match | Linking an import to an existing scheduled item instead of creating a duplicate. |
| External id | Dedup key for imports; re-importing a file creates nothing new. |
