# Spec delta — 0002 Frictionless import

Builds on `0001`'s delta (capabilities created there). `schedule-and-reminders` is new.

---

# Capability: Categories (`categories.md`)

## ADDED

### CAT-005: Memo normalization
A statement memo is normalized into a rule key by:
1. lowercasing and removing accents;
2. removing a known Nubank prefix: `compra no debito -`, `transferencia enviada pelo pix -`, `transferencia recebida pelo pix -`, `pagamento de boleto efetuado -`, `transferencia enviada -`, `transferencia recebida -`;
3. keeping only the text before the first ` - ` (the main merchant or person);
4. removing digits and the installment marker `N/M`;
5. replacing every non-letter with a space, collapsing spaces, and trimming.

The key is prefixed with the direction: `expense:` or `income:`. A memo that normalizes to empty has no key.

#### Scenario: Pix to a person
- **Given** the checking memo "Transferência enviada pelo Pix - JOÃO DA SILVA - •••.123.456-•• - NU PAGAMENTOS"
- **Then** the key is `expense:joao da silva`

#### Scenario: card installment
- **Given** the card title "Loja X - Parcela 3/10" as a purchase
- **Then** the key is `expense:loja x`

#### Scenario: same name, other direction
- **Given** a Pix received from "JOÃO DA SILVA"
- **Then** the key is `income:joao da silva`, a different rule from the expense

### CAT-006: Learned categorization rules
A categorization rule maps a key (CAT-005) to a category id. Rules belong to the user and are synced. There are no built-in seed rules.

#### Scenario: first import
- **Given** a new user
- **Then** they have no rules and every item without a built-in category (IMP-008) arrives uncategorized

---

# Capability: Statement import (`statement-import.md`)

## ADDED

### IMP-011: Items arrive pre-categorized by learned rules
When the review list is built, each new item whose key has a rule pointing to an existing category arrives with that category. A learned rule wins over the built-in *Ignored* suggestion (IMP-008). A rule pointing to a deleted category is ignored. Already-imported items aren't categorized.

#### Scenario: known merchant
- **Given** a rule `expense:padaria sao joao` → Food
- **When** a statement with "Compra no débito - PADARIA SAO JOAO" is parsed
- **Then** the item arrives in Food

#### Scenario: category deleted
- **Given** a rule `expense:cinema` → Leisure and Leisure was deleted
- **Then** the "Cinema" item arrives uncategorized

### IMP-012: Confirming an import teaches rules
On confirm, every imported or matched item with a category saves (creates or overwrites) the rule for its key, in the same batch as the transactions. Items left uncategorized, items without a key, and unselected items don't change rules.

#### Scenario: correcting a suggestion
- **Given** a rule `expense:uber` → Transport
- **When** the user changes an "Uber" item to Leisure and confirms
- **Then** the rule becomes `expense:uber` → Leisure and the next import suggests Leisure

#### Scenario: left uncategorized
- **Given** a rule `expense:amazon` → Shopping
- **When** the user clears the category of an "Amazon" item and confirms
- **Then** the rule stays `expense:amazon` → Shopping

### IMP-013: Review list order
The review list shows, in order: **Uncategorized** (selected new items without a category, with a count), **Categorized** (other new items, including matches), then **Already imported**. Assigning a category moves the item out of Uncategorized. The confirm button stays enabled with uncategorized items.

#### Scenario: mixed import
- **Given** 40 new items, 32 pre-categorized, and 5 already imported
- **Then** the first section reads "Uncategorized (8)"

#### Scenario: confirm with uncategorized
- **Given** 3 uncategorized items
- **When** the user confirms
- **Then** they are saved without category

### IMP-014: Match candidates
A new imported **expense** has as candidates every transaction that is an expense, unpaid, not a recurring template (`isRecurring == false`), with due date within ±5 days of the item's date and amount within ±15% of the item's amount. Candidates are sorted by date distance, then amount distance. A scheduled item can be matched by only one item in the same import; the closest item (same sort) gets it. Income items are never matched.

#### Scenario: electricity bill
- **Given** an unpaid "Electricity" R$ 180 due 2026-09-10
- **When** a statement line of −R$ 192.40 on 2026-09-12 is reviewed
- **Then** the item shows a match with "Electricity"

#### Scenario: out of range
- **Given** an unpaid R$ 180 due 2026-09-10
- **Then** a line of −R$ 210 (+16.7%) or one dated 2026-09-16 (6 days) has no match

#### Scenario: recurring template
- **Given** a monthly recurring template due 2026-09-10 and no generated instance
- **Then** the template is not a candidate

### IMP-015: Default action on a match
An item with candidates is pre-linked to the first one and shown as "Pays <description/category> · <due date>". On confirm, the scheduled transaction is updated instead of a new one being created: `paid = true`, `paidDate` and amount from the statement, account = import account, `externalId` and `importSource` set; its category is kept unless the user changed the item's category. Re-importing the same file creates nothing (IMP-006 dedup via `externalId`).

#### Scenario: confirming a match
- **Given** the Electricity match above
- **When** the import is confirmed
- **Then** Electricity is paid on 2026-09-12 for R$ 192.40, no new transaction exists, and the summary counts it as "matched"

### IMP-016: Choosing or refusing a match
Tapping the match lets the user pick another candidate (when there are several) or choose "Not this one", which imports the item as a new transaction. The choice applies only to that item.

#### Scenario: two subscriptions
- **Given** two unpaid R$ 39.90 subscriptions due 2026-09-08 and 2026-09-09
- **When** the user picks the second one for a line dated 2026-09-08
- **Then** the second is marked paid and the first stays unpaid

#### Scenario: not this one
- **When** the user chooses "Not this one"
- **Then** a new transaction is created and the scheduled item stays unpaid

### IMP-017: Open with / Share to DueDay (Android)
DueDay is offered when the user opens or shares a CSV/OFX file (`ACTION_VIEW` and `ACTION_SEND`; MIME `text/csv`, `text/comma-separated-values`, `application/x-ofx`, `application/ofx`, `text/plain`, `application/octet-stream`). The app opens the import with that file already read, skipping the file picker; the normal flow follows (format validation IMP-001/IMP-003, account picker, review). If the user isn't signed in (or the app is locked), the file is kept and the import opens right after sign-in/unlock. Works from cold start and while the app is running.

#### Scenario: from a Gmail attachment
- **Given** the app is closed and the user is signed in
- **When** they tap "Open with → DueDay" on a Nubank `.ofx`
- **Then** the app opens on the import with the account picker for that file

#### Scenario: shared while running
- **Given** the app is open on the dashboard
- **When** the user shares a card bill CSV to DueDay
- **Then** the import opens with that file

#### Scenario: unsupported file
- **When** a `.txt` that isn't a statement is shared to DueDay
- **Then** the import shows "unsupported file" (IMP-001)

### IMP-018: Create an account from the import picker
The import account picker ends with "+ New account". It opens the account form with the type matching the file (IMP-004) preselected. After saving, the new account is selected and the import continues to review; cancelling returns to the picker.

#### Scenario: first import ever
- **Given** a user with no accounts
- **When** they parse a card bill and tap "+ New account", fill "Nubank card" with due day 7, and save
- **Then** the review list opens for "Nubank card"

### IMP-019: Import summary
The success message reports created, matched, already imported, and skipped counts.

#### Scenario: summary
- **Given** an import with 30 new, 2 matched, 5 already imported, 1 unselected
- **Then** the message states 30 imported, 2 matched, 5 already imported, 1 skipped

## MODIFIED

### IMP-010: Import doesn't touch accounts
Confirming an import writes only transactions (created and matched), category counters, and categorization rules, in one batch. The chosen account is stored on each transaction; no account document changes.

was: "Confirming an import writes only transactions (and category counters)…"

#### Scenario: confirming 30 items with 2 matches
- **When** an import of 28 new items and 2 matches is confirmed
- **Then** 28 transactions are created, 2 are updated, rules are written, and no account document is updated

---

# Capability: Schedule & reminders (`schedule-and-reminders.md`)

## Purpose
Remind the user of what's coming up and of the weekly import, using on-device notifications only.

## ADDED

### SCH-001: Weekly import reminder
When enabled (default), a local notification repeats every Sunday at 19:00 local time, titled and worded in the current app language ("Time to import your Nubank statement"). Tapping it opens the import screen (cold start or running). It is scheduled on app start and when enabled, cancelled when disabled, and rescheduled when the language changes.

#### Scenario: Sunday evening
- **Given** the reminder is enabled
- **When** it is Sunday 19:00
- **Then** the notification appears and tapping it opens the import

#### Scenario: disabled
- **Given** the user turned the reminder off
- **Then** no Sunday notification appears

### SCH-002: Bill reminder refresh keeps the import reminder
Rescheduling bill reminders (on transaction load) cancels only bill reminders, never the weekly import reminder.

#### Scenario: transactions reload
- **Given** the weekly reminder is scheduled
- **When** transactions load and bill reminders are rescheduled
- **Then** the weekly reminder is still scheduled

### SCH-003: Notification permission (Android 13+)
The app requests the notification permission once after sign-in, and again when the user enables the weekly reminder. If denied, the toggle stays as chosen and nothing breaks.

#### Scenario: first launch on Android 14
- **When** the user signs in for the first time
- **Then** the system notification permission dialog is shown

---

# Capability: Settings (`settings.md`)

## ADDED

### SET-002: Weekly import reminder toggle
Settings shows "Weekly import reminder (Sundays, 19:00)" with a switch, on by default. The value is stored on the device and survives restarts; it applies SCH-001 immediately.

#### Scenario: turning it off
- **When** the user turns the switch off and restarts the app
- **Then** the switch is still off and no reminder is scheduled

## MODIFIED

### SET-001: Delete all my data
The settings (profile) screen has "Delete all my data". After a confirmation dialog that states it can't be undone, every account, category, transaction, and categorization rule of the user is deleted. Login, profile, and app preferences stay. On the next category load, defaults are created again (CAT-004). All bill reminders are cancelled; the weekly import reminder follows its toggle (SET-002).

was: "…every account, category, and transaction of the user is deleted… All scheduled local reminders are cancelled."

#### Scenario: rules are deleted
- **Given** a user with 50 learned rules
- **When** they delete all data and import again
- **Then** every item arrives uncategorized (except IMP-008 items)

#### Scenario: weekly reminder survives
- **Given** the weekly reminder is enabled
- **When** the user deletes all data
- **Then** the weekly reminder is still scheduled
