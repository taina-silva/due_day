# Tasks — 0003

Prerequisite: `0001` and `0002` applied.

## 1. Domain
- [ ] 1.1 Month helpers in `core/utils/extensions/date_extension.dart`: month start/end, `MonthKind` (past/current/future) vs today, same-period range in the previous month with day clamping (DSH-008, DSH-009)
- [ ] 1.2 `ProjectRecurringOccurrences(templates, transactions, month)`: pure; monthly/yearly expense templates with `spending`/uncategorized kind; day clamping; skip months with an instance or before the start; returns unsaved `TransactionEntity`s marked as projected (e.g. id `projected:<templateId>:<yyyy-MM>`) (DSH-011)
- [ ] 1.3 `DashboardSummary` rewrite: `monthKind`, `spent`, `previousSpent?`, `income`, `invested`, `plannedPendingAmount`, `plannedPendingCount`, `planned`, `uncategorizedCount`, `spendingByCategory` as a sorted list (`categoryId?`, amount, share), `upcomingDues`; remove `DashboardInsight` (DSH-008…DSH-010, DSH-012, DSH-013, DSH-015, DSH-016)
- [ ] 1.4 `GetDashboardSummary(month, today, transactions, categories)`: same-period comparison; Planned with unpaid bills in month + projections; uncategorized count (missing/deleted category); upcoming dues (overdue + 10 days, max 5, real + projected, current month only); drop `_classifyInsight` (DSH-009…DSH-013, DSH-015, DSH-016)
- [ ] 1.5 `GetCategoryDetail(month, today, categoryId?, transactions, categories)` → total, previous total (DSH-009 rules), counted transactions newest first; `null` id = Uncategorized group (DSH-014)
- [ ] 1.6 `TransactionFilter` entity (`month?` null = all months, `categoryId?`, `uncategorizedOnly`, `accountId?`, `type?`, `query`) + `FilterTransactions(transactions, categories, filter)`: effective date, AND, account matches `accountFrom`/`accountTo`, accent/case-insensitive query over notes (fallback category name), newest first (TRX-005…TRX-007)
- [ ] 1.7 Move the accent-folding function from `0002`'s `normalizeMemoKey` into `core/utils` so the domain search and memo normalization share it (TRX-007)

## 2. Data
- [ ] 2.1 None. `TransactionRemoteDataSource.getTransactions` is no longer called with filters; leave it as is

## 3. Presentation
- [ ] 3.1 `app_router.dart`: branches `/dashboard` (+ `category` with `extra`), `/transactions` (history), `/schedule`, `/settings` (+ `accounts`, `categories`); remove `/transactions/history`, `/transactions/schedule`, `/accounts` and `/categories` tabs, `/profile`; redirect any leftover `/profile` push to `/settings` (NAV-001, NAV-003)
- [ ] 3.2 `FloatingBottomNav`: 4 tab items + central "+" button (not a branch, ≥44×44, semantics label); `MainWrapperPage` maps item index to branch index (NAV-001, NAV-002)
- [ ] 3.3 `AddActionSheet`: "Import statement" → `context.push('/transactions/import')`; "Add manually" → `AddEditTransactionBottomSheet` (root navigator) (NAV-002)
- [ ] 3.4 Delete `TransactionsPage` and `TransactionNavigationButtons`; schedule "see all" (`timeline_section.dart`) → `context.go('/transactions')` (TRX-005)
- [ ] 3.5 `DashboardAppBar`: remove avatar; bell only. Other tabs use `CustomAppBar` (NAV-003)
- [ ] 3.6 `DashboardBloc`: drop accounts stream and account filter; combine transactions + categories; keep `selectedMonth` (from `0001`); emit the new summary (DSH-008, DSH-016)
- [ ] 3.7 Home widgets: `SpentCard` (amount + comparison), Income/Invested row, `PlannedCard`, `UncategorizedBanner` (→ `/transactions` with preset filter), `CategorySpendingList` (all rows, share, tap → `/dashboard/category`, "Manage categories" → `/settings/categories`), upcoming dues with "See all" → `/schedule` and empty text; layout by `monthKind`; delete `InsightCard`, `dashboard/.../account_selection_bottom_sheet.dart`, and greeting (DSH-008…DSH-016)
- [ ] 3.8 `CategoryDetailPage` + `CategoryDetailBloc` (Load BLoC on `GetTransactions` + `GetCategoryDetail`): total, comparison, list (tap → `TransactionDetailsBottomSheet`), Edit (hidden for Uncategorized; CAT-003 for system) (DSH-014)
- [ ] 3.9 `TransactionHistoryBloc` (Load BLoC on unfiltered `GetTransactions` + `FilterTransactions`; events for each filter, query (300 ms debounce), clear, preset). The page stops sending filtered `LoadTransactions` to the global `TransactionLoadBloc` (TRX-005, TRX-006)
- [ ] 3.10 History page: month stepper with "All months", category sheet with "Uncategorized" option, account sheet, type chips, search field, clear-all; empty state "No transactions found"; reads preset filter from `extra`; drop frequency and date-range filters (TRX-006, TRX-007)
- [ ] 3.11 `SettingsPage` (in `profile` feature, reusing its widgets): header, Accounts/Categories tiles, Notifications, Appearance, Security, Data (delete all), Sign out; `AccountsPage`/`CategoriesPage` as sub-pages with back (SET-003, SET-001, NAV-003)
- [ ] 3.12 `SchedulePage` as a tab root: bottom padding for the bar, no back button (NAV-001)

## 4. Wiring & l10n
- [ ] 4.1 DI: `DashboardBloc` new deps, `ProjectRecurringOccurrences`, `GetCategoryDetail`, `FilterTransactions`, `CategoryDetailBloc` and `TransactionHistoryBloc` (factories)
- [ ] 4.2 ARB (en + pt): nav labels (Transactions, Schedule, Settings, Add), add sheet options, "Spent in {month}", "vs {month}" up/down/same, Planned with plural bills, "{count} uncategorized" plural, "Uncategorized", "Manage categories", category detail title/edit, dues "Overdue"/"See all"/empty, "All months", account filter, search hint, "No transactions found", clear filters, Settings section titles; remove unused insight, greeting, `navAccount`, `navCategory`, history/schedule button keys

## 5. Tests
- [ ] 5.1 `date_extension_test`: month kind, same-period range, Mar 31 → all of Feb (DSH-009)
- [ ] 5.2 `project_recurring_occurrences_test`: monthly next months, instance exists, yearly, clamping, before start, weekly ignored, investment/ignored ignored (DSH-011)
- [ ] 5.3 `get_dashboard_summary_test`: one test per DSH-009, DSH-010, DSH-012, DSH-013, DSH-015 scenario; month kinds; no insight (DSH-016)
- [ ] 5.4 `get_category_detail_test`: Food scenario, Uncategorized group incl. deleted category (DSH-014)
- [ ] 5.5 `filter_transactions_test`: each TRX-006/TRX-007 scenario, all months, effective date, legacy transfer still listed (TRX-002)
- [ ] 5.6 `dashboard_bloc_test`: no account stream; month change; categories update recomputes
- [ ] 5.7 `category_detail_bloc_test` and `transaction_history_bloc_test`: filter events, debounce, preset, clear; global `TransactionLoadBloc` not reloaded (TRX-006)
- [ ] 5.8 Widget tests: bottom nav items and "+" sheet (NAV-001, NAV-002); Home sections per month kind (DSH-008); uncategorized banner navigates with preset (DSH-012); Settings section order and Accounts sub-page (SET-003, NAV-003); history search empty state (TRX-007)
- [ ] 5.9 Update `main_wrapper_page_test`, `dashboard_app_bar_test`, `profile_page_test`, `schedule_page_test`, `accounts_page_test`, `categories_page_test` for the new routes/app bars; remove tests of deleted widgets

## 6. Docs & specs
- [ ] 6.1 `.claude/docs/navigation.md`: tabs, "+" sheet, new paths, sub-routes, preset filters via `extra`, `/profile` removed
- [ ] 6.2 `.claude/skills/add-route/SKILL.md`: update examples if they use removed paths
- [ ] 6.3 `specs/README.md`: add `NAV` prefix
- [ ] 6.4 Create `specs/capabilities/navigation.md`; merge delta into `dashboard.md`, `transactions.md`, `settings.md`
- [ ] 6.5 Move change to `specs/changes/archive/`, `Status: done`

## 7. Verification
- [ ] 7.1 `fvm dart run build_runner build --delete-conflicting-outputs`
- [ ] 7.2 `fvm dart format .` and `fvm flutter analyze` clean
- [ ] 7.3 `fvm flutter test` green
- [ ] 7.4 Manual on Android: "+" → Import from every tab; Home on past/current/future months matches the statements, comparison and Planned incl. a monthly template next month; uncategorized banner → filtered list → categorize → banner count drops; category detail; search "padaria" across all months; Settings → Accounts/Categories and delete all data; bill reminders unchanged after filtering history
