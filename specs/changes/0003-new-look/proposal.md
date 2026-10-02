# 0003 — New look

Status: proposed (draft; `/spec-propose 0003` writes `spec-delta.md` and `tasks.md`)

Depends on: `0001`, `0002`.

## Why

Navigation follows database entities, not user tasks. The Transactions tab opens the create form; History and Schedule are buttons inside it; Import (the main input) is 3 taps deep in History. Accounts and Categories take 2 of 4 tabs but are rarely edited. The dashboard still reflects the "bank mirror" focus.

## What

- **Tabs:** Home · Transactions · Schedule · Settings, plus a central **"+"** (Import first, then Manual).
- **Home:**
  1. Month selector.
  2. **Spent in <month>** with "↑/↓ N% vs <previous>"; Income and Invested below.
  3. **Planned** (current/future months): "Planned by month end: R$ X (+ R$ Y in N bills)". Future months show only Planned.
  4. "N uncategorized" warning (only if N > 0) → filtered list.
  5. Spending by category (bars, sorted) → **category detail** (total, comparison, transactions, edit); "Manage categories" at the end.
  6. Dues for the next 7–10 days.
  - Removed: financial health card, balances, insight card.
- **Transactions:** history as the main screen; filters (month, category, account, uncategorized) and **search by description**.
- **Settings:** accounts (rename, delete, type, due day), categories, notifications, theme, language, biometrics, delete data.

## Out of scope

Budgets, goals, charts; redesign of frozen features.

## Impacted capabilities

`dashboard`, `transactions`, `categories`, `accounts`, `settings`.
