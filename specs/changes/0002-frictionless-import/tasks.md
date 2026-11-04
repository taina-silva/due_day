# Tasks — 0002

Prerequisite: `0001` applied.

## 1. Domain
- [ ] 1.1 `normalizeMemoKey(memo, isExpense)` in `statement_import/domain/utils` (pure, accent/prefix/installment rules) (CAT-005)
- [ ] 1.2 `CategoryRuleEntity { key, categoryId, updatedAt }` + `CategoryRuleRepository` contract: `getRules()`, rule writes go through the import batch (CAT-006)
- [ ] 1.3 `ImportReviewItem`: add `ruleKey`, `matchCandidates` (List<TransactionEntity>), `matchedTransactionId` (null = import as new); copyWith able to clear nullable fields (IMP-014…IMP-016)
- [ ] 1.4 `FindMatchCandidates` pure helper: expense, unpaid, `!isRecurring`, ±5 days on `dueDate`, ±15% amount, sort by date then amount distance; one-to-one assignment across items (IMP-014)
- [ ] 1.5 `BuildReviewList`: inject `CategoryRuleRepository`, `CategoryRepository`, `TransactionRepository`; apply rules over IMP-008 suggestion, drop rules to deleted categories, attach candidates and pre-link first (IMP-011, IMP-014, IMP-015)
- [ ] 1.6 `ConfirmImport`: split into create vs. mark-paid (statement date, amount, account, `externalId`, `importSource`; keep category unless changed); collect rules for categorized items with a key (IMP-012, IMP-015, IMP-010)
- [ ] 1.7 `StatementImportRepository.confirmImport(toCreate, toMarkPaid, rules)` contract; `ImportSummary.matchedCount` (IMP-010, IMP-019)
- [ ] 1.8 `ImportReminderSettings` contract (`isEnabled`, `setEnabled`) + `ScheduleImportReminder` / `CancelImportReminder` use cases (SCH-001, SET-002)
- [ ] 1.9 `DeleteAllUserData`: include `categoryRules` (SET-001)

## 2. Data
- [ ] 2.1 `CategoryRuleModel` (freezed/json) + `CategoryRuleRemoteDataSource` at `/users/{uid}/categoryRules/{key}` (key encoded as doc id: replace `/` and `:` safely or hash) (CAT-006)
- [ ] 2.2 `StatementImportRepositoryImpl.confirmImport`: one batch (≤450 writes, chunked) with creates, `update` of matched docs, rule `set`s, category counters (IMP-010, IMP-012, IMP-015)
- [ ] 2.3 `UserDataRemoteDataSource.deleteAll` also deletes `categoryRules` (SET-001)
- [ ] 2.4 `ImportReminderSettingsLocalDataSource` on a Hive box `settings_box` (default `true`) (SET-002)
- [ ] 2.5 `NotificationService`: `scheduleWeeklyImportReminder(title, body)` (fixed id, `dayOfWeekAndTime`, `inexactAllowWhileIdle`, payload `import`); `cancelImportReminder()`; `cancelBillReminders()` replacing `cancelAll()` in bill rescheduling; `onDidReceiveNotificationResponse` + `getNotificationAppLaunchDetails` exposed as a payload stream; `requestPermission()`; localized channel for this reminder (SCH-001…SCH-003)
- [ ] 2.6 Android: intent filters (`VIEW`, `SEND`) in `AndroidManifest.xml`; `MainActivity.kt` `MethodChannel` `dueday/incoming_file` returning `{name, bytes}` for initial and new intents (`onNewIntent`), read via `contentResolver` (IMP-017)
- [ ] 2.7 `IncomingFileService` (Dart side of the channel) decoding with the same UTF-8/Latin-1 helper as the picker (IMP-017, IMP-002)

## 3. Presentation
- [ ] 3.1 `StatementImportBloc`: `IncomingFileReceived(PickedStatementFile)` starts at parsing; `ItemMatchChanged(index, transactionId?)`; category assign clears from Uncategorized (IMP-013, IMP-016, IMP-017)
- [ ] 3.2 `ImportReviewList`: sections Uncategorized (count) → Categorized → Already imported, keeping original indices (IMP-013)
- [ ] 3.3 `ImportReviewItemTile`: match chip "Pays … · date"; tap → bottom sheet with candidates + "Not this one" (≥44×44, l10n) (IMP-015, IMP-016)
- [ ] 3.4 Import account picker: "+ New account" row → `AddEditAccountBottomSheet` with type preselected; returns the created account (IMP-018)
- [ ] 3.5 Success message with matched count (IMP-019)
- [ ] 3.6 Settings: "Weekly import reminder" switch in `NotificationSettings`, wired to `SettingsBloc` (persisted, schedules/cancels, requests permission) (SET-002, SCH-003)
- [ ] 3.7 Routing: incoming file and notification payload `import` → `/transactions/import` (with `extra` file); pending file held until authenticated/unlocked (IMP-017, SCH-001)

## 4. Wiring & l10n
- [ ] 4.1 DI: rule datasource/repository, `BuildReviewList` new deps, reminder settings, incoming file service, `settings_box` open in `injection_container.dart`
- [ ] 4.2 App start: schedule weekly reminder if enabled; request permission once after sign-in; reschedule on language change (SCH-001, SCH-003)
- [ ] 4.3 ARB (en + pt): Uncategorized/Categorized section titles, match chip, candidates sheet + "Not this one", "+ New account", summary with matched, reminder title/body/channel, settings toggle label/description

## 5. Tests
- [ ] 5.1 `normalize_memo_key_test`: each CAT-005 scenario + prefixes, digits, empty result
- [ ] 5.2 `find_match_candidates_test`: in/out of ±5 days and ±15% boundaries, income ignored, paid/template excluded, sorting, one-to-one assignment (IMP-014)
- [ ] 5.3 `build_review_list_test`: rule applied, rule beats IMP-008, deleted category ignored, duplicates untouched, first candidate pre-linked (IMP-011, IMP-015)
- [ ] 5.4 `confirm_import_test`: rules for categorized only, overwrite, uncategorized keeps rule, matched → mark-paid fields, "Not this one" creates, summary counts (IMP-012, IMP-015, IMP-016, IMP-019)
- [ ] 5.5 Repository/datasource tests: single batch with creates + updates + rules, chunking, no account writes (IMP-010); delete-all includes rules (SET-001)
- [ ] 5.6 `statement_import_bloc_test`: incoming file flow, match change, category assign (IMP-013, IMP-016, IMP-017)
- [ ] 5.7 Widget tests: section order and counts (IMP-013); match sheet (IMP-016); "+ New account" returns to review (IMP-018); settings toggle (SET-002)
- [ ] 5.8 Reminder: settings datasource default/persist; bill reschedule doesn't cancel the weekly id (SCH-002) with a mocked plugin wrapper

## 6. Docs & specs
- [ ] 6.1 `.claude/docs/firestore.md`: `categoryRules` schema, import batch content, delete-all
- [ ] 6.2 `.claude/docs/notifications.md`: weekly reminder, payload routing, permission, `cancelBillReminders`; `add-notification` skill if the recipe changes
- [ ] 6.3 `.claude/docs/navigation.md`: incoming file / notification → import
- [ ] 6.4 Merge delta into `specs/capabilities/{categories,statement-import,settings}.md`; create `schedule-and-reminders.md`
- [ ] 6.5 Move change to `specs/changes/archive/`, `Status: done`

## 7. Verification
- [ ] 7.1 `fvm dart run build_runner build --delete-conflicting-outputs`
- [ ] 7.2 `fvm dart format .` and `fvm flutter analyze` clean
- [ ] 7.3 `fvm flutter test` green
- [ ] 7.4 Manual on Android: open an OFX from Gmail (cold + warm) and share a CSV from Files; categorize, re-import a newer statement → same merchants pre-categorized; schedule a bill, import its payment → matched, no duplicate; set device to Sunday 18:59 → reminder appears and opens import; toggle off → none
