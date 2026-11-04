# Tasks — 0001

## 1. Domain
- [x] 1.1 `AccountCategory` → `checking` / `credit_card` / `cash` with `@JsonValue` + `unknownEnumValue: checking` on the model field; update `localizedName` / `icon` (ACC-001, ACC-002)
- [x] 1.2 Remove `balance` from `AccountEntity` (ACC-003)
- [x] 1.3 Add `CategoryKind { spending, investment, ignored }` and `kind` to `CategoryEntity` (default `spending`); system ids as constants (CAT-001, CAT-002)
- [x] 1.4 `TransactionEntity.effectiveDate` getter (`paidDate ?? dueDate ?? createdAt`) (TRX-003)
- [x] 1.5 Remove balance logic from `AddTransaction` / `UpdateTransaction` / `DeleteTransaction` (drop `AccountRepository` dependency) and from `SyncRecurringTransactions` (TRX-004)
- [x] 1.6 `EnsureCategories` use case: no categories → batch-create 13 localized defaults + system; else create missing system categories (CAT-002, CAT-004). Localized default names are passed in, not read from l10n inside the domain.
- [x] 1.7 `DeleteCategory` / `UpdateCategory` reject system categories (delete; rename) with a `CategoryFailure` (CAT-003)
- [x] 1.8 Rewrite `GetDashboardSummary(month, transactions, categories)`: month bounds on `effectiveDate`; Spent / Income / Invested / spending by category per kind; skip `transfer`; drop balances, `projectedBalance` (DSH-002…DSH-007, TRX-002)
- [x] 1.9 `ParsedStatementTransaction`: add `format` (`nubankOfx`, `checkingCsv`, `cardBillCsv`) and optional `suggestedCategoryKind` (IMP-003, IMP-008)
- [x] 1.10 `BuildReviewList`: pre-select *Ignored* for bill-payment items (IMP-008); refunds stay uncategorized (IMP-009)
- [x] 1.11 `ConfirmImport` / `StatementImportRepository.confirmImport`: no balance update; contract without balance wording (IMP-010)
- [x] 1.12 `DeleteAllUserData` use case + `UserDataRepository` contract (SET-001)

## 2. Data
- [x] 2.1 `AccountModel`: drop `balance`; tolerant enum read (ACC-002, ACC-003); regenerate freezed/json
- [x] 2.2 `CategoryModel`: `kind` with `@Default('spending')`/tolerant enum; regenerate (CAT-001)
- [x] 2.3 `CategoryRemoteDataSource`: `addCategoriesBatch` and `ensureSystemCategories` using fixed doc ids (CAT-002, CAT-004)
- [x] 2.4 `StatementFilePickerService`: `FileType.any`; decode UTF-8 strict (strip BOM) with Latin-1 fallback (IMP-001, IMP-002)
- [x] 2.5 `StatementImportRepositoryImpl.parseStatement`: detect format by content (IMP-003); unsupported → `UnsupportedFileFormatFailure`; remove `_applyNetBalanceDelta` and `AccountRepository` dependency (IMP-010)
- [x] 2.6 `CardBillCsvStatementParser`: `date,title,amount`, sign rules, occurrence-index external id, installment date shift with clamping (IMP-005, IMP-006, IMP-007)
- [x] 2.7 Bill-payment memo detection helper in `domain/utils` (accent/case-insensitive) used by both parsers' output (IMP-008)
- [x] 2.8 `UserDataRemoteDataSource.deleteAll`: delete `accounts`, `categories`, `transactions` under `/users/{uid}` in ≤450-write batches; repository maps to `Either` (SET-001)

## 3. Presentation
- [x] 3.1 Account form: type selector with 3 types, no balance field, due day only for credit card (ACC-001, ACC-003)
- [x] 3.2 Accounts page / `AccountCard` / account pickers (transactions + dashboard): remove balance and total (ACC-003)
- [x] 3.3 Transaction type selector and filter bar: remove Transfer; details sheet still renders legacy transfers (TRX-001, TRX-002)
- [x] 3.4 Categories: system categories show localized name, no delete action, name read-only (CAT-002, CAT-003)
- [x] 3.5 `CategoryLoadBloc` triggers `EnsureCategories` once per session after the first load (CAT-002, CAT-004)
- [x] 3.6 `DashboardBloc`: `selectedMonth` state + `DashboardMonthChanged` event; combine categories stream (DSH-001)
- [x] 3.7 Dashboard page: month header with previous/next (≥44×44 targets), remove `FinancialHealthCard`, cards Spent / Income / Invested, breakdown with "Uncategorized" group (DSH-001, DSH-003…DSH-007)
- [x] 3.8 Import page: account picker lists matching type first (IMP-004)
- [x] 3.9 Profile: "Delete all my data" tile + confirm dialog; action BLoC (or `ProfileBloc` event) with loading / success / error via `AppMessenger`; cancel reminders on success (SET-001)

## 4. Wiring & l10n
- [x] 4.1 DI: update transaction, schedule, import injections (no `AccountRepository` where removed); register `EnsureCategories`, user-data datasource/repository/use case, card bill parser
- [x] 4.2 ARB (en + pt): account types, category kinds/system names, 13 default names, month navigation labels, Invested/Spent/Uncategorized, delete-all title/confirm/success/error, system-category protected message; remove unused balance / transfer / old account-type keys

## 5. Tests
- [x] 5.1 `get_dashboard_summary_test`: one test per DSH-002…DSH-006 scenario + legacy transfer (TRX-002) + effective date fallback (TRX-003)
- [x] 5.2 `transaction_usecases_test` / `sync_recurring_transactions_test`: no account calls (TRX-004)
- [x] 5.3 `account_model_test`: legacy types and stored `balance` ignored (ACC-002, ACC-003); category model `kind` default (CAT-001)
- [x] 5.4 `ensure_categories_test`: new user, missing system, deleted default not recreated (CAT-002, CAT-004); system delete/rename rejected (CAT-003)
- [x] 5.5 `card_bill_csv_statement_parser_test` + fixture `sample_nubank_card.csv`: signs, invalid rows, occurrence ids, installments and clamping (IMP-005…IMP-007)
- [x] 5.6 Repository parse tests: detection by content, renamed file, PDF/unknown → unsupported (IMP-001, IMP-003); Latin-1 fixture decoding (IMP-002)
- [x] 5.7 `build_review_list_test`: bill payment → *Ignored* for both formats; refund uncategorized (IMP-008, IMP-009)
- [x] 5.8 `confirm_import_test` / repository test: no account update (IMP-010)
- [x] 5.9 Delete-all: datasource batching, use case, BLoC states, dialog confirm/cancel widget test (SET-001)
- [x] 5.10 `dashboard_bloc_test`: month change recomputes (DSH-001); widget tests for accounts page and form without balance (ACC-001, ACC-003)
- [x] 5.11 Update helpers/fixtures that build `AccountEntity` with `balance` or `TransactionType.transfer`

## 6. Docs & specs
- [x] 6.1 `.claude/docs/firestore.md`: accounts schema (types, no `balance`), categories `kind` + system ids, transactions `type` (legacy `transfer`), delete-all batching
- [x] 6.2 Create `specs/capabilities/{transactions,accounts,categories,dashboard,statement-import,settings}.md` from this delta
- [x] 6.3 Move change to `specs/changes/archive/`, `Status: done`

## 7. Verification
- [x] 7.1 `fvm dart run build_runner build --delete-conflicting-outputs`
- [x] 7.2 `fvm dart format .` and `fvm flutter analyze` clean
- [x] 7.3 `fvm flutter test` green
- [ ] 7.4 Manual on Android: delete all data → defaults created; import a Nubank OFX and a card bill CSV covering 2–3 months; each month on the dashboard matches the statements; re-import creates nothing

## Follow-ups

Out of scope for 0001, found during review:

- **Seeding from an empty offline cache:** on an offline first launch, the first categories snapshot can be an empty cache for a user who has categories. The defaults would then be seeded next to theirs (fixed `default_*` ids reset `transactionCount`). Possible fix: skip seeding when the snapshot `isFromCache`.
- **Installment detection is loose:** any card title ending in `N/M` (N ≤ M) is shifted by N−1 months. A merchant name ending in something like `12/31` would be misdated. Consider anchoring to `Parcela N/M`.
- **Zero-amount card rows** become R$ 0 expenses; consider skipping them.
- **`AccountCategory` imports Flutter/l10n in the domain** (`localizedName`, `icon`); predates this change. Move both to a presentation extension.
- **IMP-006 end-to-end:** add a `BuildReviewList` test with card-bill ids to show a re-import marks every line "already imported".
- **7.4** (manual check on an Android device) is still to be done by the user.
