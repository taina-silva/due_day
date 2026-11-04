# Tasks — 0004

Prerequisite: `0001`, `0002`, and `0003` applied.

## 1. Domain
- [ ] 1.1 `TransactionEntity.description` (nullable) + `displayName(categoryName)` helper (description → notes → category name → null for the "Transaction" fallback in the UI) (TRX-013)
- [ ] 1.2 `ResolveTransactionDates(date, paid)` pure helper → `dueDate`, `paid`, `paidDate` (TRX-010)
- [ ] 1.3 `SuggestCategory(description, type)` use case: `normalizeMemoKey` + `CategoryRuleRepository.getRules()` + existing-category check (TRX-009)
- [ ] 1.4 `LastUsedAccountSettings` contract (`get`, `set`) (TRX-012)
- [ ] 1.5 `SyncRecurringTransactions` rewrite: pure `PlanRecurringOccurrences(templates, transactions, today)` (monthly/yearly, after template month, clamp, ≤ end of next month, skip months with an occurrence) + creation always unpaid; drop the `AccountRepository` dependency and the balance code; return created occurrences (TRX-014)
- [ ] 1.6 Reminder planning: extend `ClassifyTransactionReminders` to 09:00 and stable keys (include templates/occurrences, skip past times) (SCH-004); add `PlanCardBillReminders(accounts, now)` → next two due dates, −3 days and on the day, 09:00, skip past (SCH-005)
- [ ] 1.7 Update `0002`'s `FindMatchCandidates` filter: exclude only weekly/bi-weekly templates (IMP-014)
- [ ] 1.8 Update `0003`'s `GetDashboardSummary` unpaid-bill predicate to include unpaid monthly/yearly templates (DSH-010, DSH-015)
- [ ] 1.9 Update `0003`'s `FilterTransactions` query to use the display name (TRX-007)

## 2. Data
- [ ] 2.1 `TransactionModel.description` (freezed/json) + mapping (TRX-013)
- [ ] 2.2 `ConfirmImport` / import mapping: memo → `description`, `notes` null; matched items keep their description (IMP-020)
- [ ] 2.3 `LastUsedAccountLocalDataSource` on `settings_box` (from `0002`) (TRX-012)
- [ ] 2.4 `NotificationService`: localized channel name/description passed in (re-created on language change); `scheduleReminder(id, …)` with stable ids derived from transaction/account id + kind (hash into an id range distinct from the weekly reminder id); `cancelBillReminders()` cancels the bill and card id ranges via `pendingNotificationRequests` (SCH-002, SCH-004, SCH-005, SCH-007)

## 3. Presentation
- [ ] 3.1 `TransactionCreateForm` rewrite (TRX-008…TRX-012): type segmented control (Expense | Income), amount autofocus, description `AppTextField` with validation + suggestion on focus loss/submit, category, single account field, date, Paid switch derived from the date, repeat (Doesn't repeat / Monthly / Yearly), collapsible "More options" with notes; save via `TransactionActionBloc`; store last used account on success. Remove `TransactionNavigationButtons` usage if `0003` left any
- [ ] 3.2 Delete unused widgets: `transaction_frequency_selector.dart`, `frequency_selection_bottom_sheet.dart`, `type_selection_bottom_sheet.dart` (if unused) (TRX-011)
- [ ] 3.3 Show the display name in `transaction_item.dart`, `transaction_details_bottom_sheet.dart`, `schedule_item_card.dart`, category detail, upcoming dues, and the import match chip (TRX-013)
- [ ] 3.4 `RemindersBloc` (app-wide, in `MainWrapperPage`): listens to transactions, accounts, settings (language, push), and auth; recomputes SCH-004/SCH-005 with `cancelBillReminders()` + schedule; cancels on sign-out; adds the existing inbox entries. Remove reminder code from `TransactionLoadBloc` (SCH-004…SCH-006)
- [ ] 3.5 Move `SyncRecurringTransactionsRequested` from `dashboard_page.dart` to app start after sign-in; remove `_notifyRecurringDebited` (occurrences are never auto-paid) (TRX-014)

## 4. Wiring & l10n
- [ ] 4.1 DI: `SuggestCategory`, last used account datasource/repository, `PlanRecurringOccurrences`, `PlanCardBillReminders`, `RemindersBloc`; `SyncRecurringTransactions` without `AccountRepository`
- [ ] 4.2 ARB (en + pt): description label/hint/error, "Paid", repeat options, "More options", card reminder title/body (account, date; today variant), bill channel name/description; update due today/tomorrow bodies to use the display name; remove frequency keys for weekly/bi-weekly and unused form keys

## 5. Tests
- [ ] 5.1 `resolve_transaction_dates_test`: past/today/future, override both ways (TRX-010)
- [ ] 5.2 `suggest_category_test`: rule hit, direction, deleted category, empty key (TRX-009)
- [ ] 5.3 `plan_recurring_occurrences_test` / `sync_recurring_transactions_test`: every TRX-014 scenario; weekly ignored; always unpaid; no account writes
- [ ] 5.4 `classify_transaction_reminders_test` (09:00, past skipped, templates included) and `plan_card_bill_reminders_test` (each SCH-005 scenario)
- [ ] 5.5 `reminders_bloc_test`: refresh on transactions/accounts/language/push change, cancel on sign-out, weekly reminder untouched (SCH-002, SCH-006)
- [ ] 5.6 Update `find_match_candidates_test` (unpaid template matches; weekly excluded), `get_dashboard_summary_test` (template in Planned), `filter_transactions_test` (display name), `confirm_import_test` (description) (IMP-014, DSH-010, TRX-007, IMP-020)
- [ ] 5.7 Widget tests for the form: field order, autofocus, description required, suggestion, Paid follows date, income maps to `accountTo`, last used account prefilled (TRX-008…TRX-012)
- [ ] 5.8 Model test: `description` round-trip; legacy document without it loads (TRX-013)

## 6. Docs & specs
- [ ] 6.1 `.claude/docs/notifications.md`: `RemindersBloc`, bill/card reminders at 09:00, stable ids and ranges, refresh triggers, localized channel, sign-out cancel
- [ ] 6.2 `.claude/skills/add-notification/SKILL.md`: stable ids and localized channel in the recipe
- [ ] 6.3 `.claude/docs/firestore.md`: `description` field; occurrences created unpaid
- [ ] 6.4 Merge delta into `specs/capabilities/{transactions,statement-import,dashboard,schedule-and-reminders}.md`
- [ ] 6.5 Move change to `specs/changes/archive/`, `Status: done`

## 7. Verification
- [ ] 7.1 `fvm dart run build_runner build --delete-conflicting-outputs`
- [ ] 7.2 `fvm dart format .` and `fvm flutter analyze` clean
- [ ] 7.3 `fvm flutter test` green
- [ ] 7.4 Manual on Android: add an expense in under 10 seconds (amount → description → save); future date saves as scheduled; monthly rent creates occurrences through next month; import the rent payment → matched, no duplicate; set the device clock to the day before a bill at 08:59 → reminder at 09:00 in the app language; card with due day in 3 days → reminder; switch language → channel and texts update; sign out → no pending reminders
