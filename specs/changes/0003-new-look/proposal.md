# 0003 — New look

Status: approved

Depends on: `0001` (effective date, month selector, Spent / Income / Invested, category `kind`, no balances), `0002` (import entry points, accent folding helper). Requirement IDs continue from `0001`/`0002` deltas; `navigation` is a new capability with prefix `NAV`.

## Why

Navigation follows database entities, not user tasks, and Home still answers the old "bank mirror" question:

- **Tabs are entities.** `FloatingBottomNav` has Home · Add · Accounts · Categories (`lib/core/design_system/components/navbar/floating_bottom_nav.dart`, branches in `lib/core/navigation/app_router.dart`). Accounts and Categories take 2 of 4 tabs but are rarely edited.
- **The Transactions tab opens the create form** (`transactions_page.dart` → `TransactionCreateForm`); History and Schedule are buttons inside it (`transaction_navigation_buttons.dart` → `/transactions/history`, `/transactions/schedule`).
- **Import, the main input (D4), is 3 taps deep:** Add tab → History → upload icon (`transaction_history_page.dart`).
- **Home doesn't answer "vs last month" or "what's still coming".** `dashboard_page.dart` shows a greeting, the account filter, Income/Expenses, an `InsightCard` (budget/category warnings computed in `get_dashboard_summary.dart` `_classifyInsight`), the top 4 categories only (`category_spending_list.dart` `take(4)`), and the next 5 dues. There is no comparison, no Planned (D8), no uncategorized warning, and categories can't be opened.
- **Planned would miss recurring bills.** `SyncRecurringTransactions` only creates an instance once its due date has passed, so next month's rent doesn't exist yet when Home computes Planned.
- **History can't find anything.** Filters are type, category, frequency, and a date range on `createdAt` sent to Firestore (`TransactionRemoteDataSource.getTransactions`), and they reload the app-wide `TransactionLoadBloc`, the same stream that drives bill reminders. There is no search, no account filter, and no "uncategorized" filter.
- **Settings is a pushed profile page** (`/profile` via the avatar in `dashboard_app_bar.dart`), separate from accounts and categories.

## What

- **Tabs:** Home · Transactions · **"+"** · Schedule · Settings. "+" opens a sheet with **Import statement** first, then **Add manually** (today's form; it's redesigned in `0004`).
- **Home** (current month by default):
  1. Month selector (`0001`).
  2. **Spent in <month>** with "↑/↓ N% vs <previous month>": **same period** for the current month (day 1 to today vs day 1 to the same day), full month for past months. Income and Invested below.
  3. **Planned** (current and future months): "Planned by month end: R$ X (+ R$ Y in N bills)". Unpaid bills due in the month plus **recurring bills estimated on the fly** from monthly/yearly templates when the real instance doesn't exist yet (not saved anywhere; the real transaction replaces the estimate). Future months show only Planned.
  4. "N uncategorized" warning (only if N > 0) → Transactions filtered to that month + Uncategorized.
  5. Spending by category: all groups, sorted, with bar and share → **category detail** (total, vs previous month, transactions, edit). "Manage categories" at the end.
  6. Upcoming dues: overdue + next 10 days (current month only), "See all" → Schedule.
  - Removed: insight card, greeting, Home account filter, avatar in the app bar. The notifications bell stays on Home.
- **Transactions tab:** history is the main screen. Filters (month, with "All months"; category incl. Uncategorized; account; type) and **search by description**, all applied in memory on the effective date by a use case, in its own BLoC (reminders' `TransactionLoadBloc` is no longer reloaded with filters).
- **Schedule tab:** the current schedule screen, moved to a tab.
- **Settings tab:** profile header (frozen) + Accounts, Categories, Notifications, Theme, Language, Biometrics, Delete all my data, Sign out. Accounts and Categories open as sub-pages.

## Out of scope

- Transaction form redesign, description field, card due-day reminders, fixing `SyncRecurringTransactions` (`0004`). Search uses the stored memo (`notes`) until `0004` adds `description`.
- Saving projected recurring occurrences; projecting weekly/bi-weekly templates.
- Schedule screen content changes.
- Budgets, goals, charts; redesign of frozen features (login, notifications inbox, profile photo, theme/language, biometrics).
- Fixing the unused Firestore filters in `TransactionRemoteDataSource.getTransactions` (no longer called with filters).

## Impacted capabilities

`navigation` (new), `dashboard`, `transactions`, `settings`.

## Docs to update

- `.claude/docs/navigation.md`: new tabs and paths, central "+" (not a branch), `/settings/accounts`, `/settings/categories`, `/dashboard/category`, `/profile` removed, preset filters via `extra`.
- `.claude/skills/add-route/SKILL.md`: only if its examples reference removed paths.
- `specs/README.md`: add the `NAV` prefix.
