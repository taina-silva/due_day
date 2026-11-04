# Spec delta — 0004 Manual entry and reminders

Builds on the `0001`, `0002`, and `0003` deltas.

Terms used below:
- **Display name** of a transaction: its description; if empty, its `notes` (legacy); if empty, its category name (localized for system categories); otherwise "Transaction".
- **Template:** a transaction with `isRecurring == true` and no `parentRecurringId`. It is also the series' first occurrence.
- **Occurrence:** a transaction created from a template (`parentRecurringId` = template id, `isRecurring == false`).

---

# Capability: Transactions (`transactions.md`)

## ADDED

### TRX-008: Manual form fields and order
The manual form ("+" → "Add manually", and edit from details) shows, in order:
1. type: **Expense** (default) | **Income**;
2. amount, focused with the numeric keyboard when a new form opens;
3. **description** (required);
4. category (optional);
5. account (optional, one field for both types);
6. date (default today);
7. **Paid** switch (TRX-010);
8. repeat: Doesn't repeat (default) / Monthly / Yearly (TRX-011);
9. "More options", collapsed by default, containing notes.

Saving requires an amount > 0 and a non-blank description. Otherwise the field shows an error and nothing is saved. The account is stored as `accountFrom` for an expense and `accountTo` for an income; the other field is cleared. There is no transfer (TRX-001) and no separate "from"/"to" field.

#### Scenario: quick expense
- **Given** the form is open
- **When** the user types 25,90, description "Bakery", and saves
- **Then** a paid expense of R$ 25.90 dated today with description "Bakery" is saved

#### Scenario: missing description
- **When** the user enters an amount, leaves the description blank, and saves
- **Then** the description field shows "Enter a description" and nothing is saved

#### Scenario: switching to income
- **Given** an expense draft with account "Nubank"
- **When** the user switches to Income and saves
- **Then** the transaction has `accountTo` = Nubank and no `accountFrom`

### TRX-009: Category suggested from the description
While the user hasn't picked a category by hand, finishing the description (focus leaves the field or the user submits it) looks up the learned rule for its key (CAT-005, with the form's direction) and fills the category if the rule points to an existing category. Once the user picks or clears a category by hand, the description no longer changes it. The manual form never creates or changes rules.

#### Scenario: known merchant
- **Given** a rule `expense:padaria sao joao` → Food
- **When** the user types the description "Padaria São João" on an expense
- **Then** the category becomes Food

#### Scenario: user already chose
- **Given** the user picked Leisure first
- **When** they type a description with a rule to Food
- **Then** the category stays Leisure

#### Scenario: no rule
- **When** the description has no rule
- **Then** the category stays empty

### TRX-010: Paid is derived from the date
The Paid switch follows the date: on when the date is today or earlier, off when it is in the future. The user can flip it. Changing the date sets it again from the new date. On save:
- **paid:** `paid = true`, `paidDate` = the date, `dueDate` = the date;
- **not paid:** `paid = false`, no `paidDate`, `dueDate` = the date.

Editing an existing transaction opens with its stored paid state. The switch only changes when the user changes the date or flips it.

#### Scenario: future bill
- **Given** today is 2026-10-06
- **When** the user sets the date to 2026-10-20 and saves
- **Then** the transaction is unpaid, due 2026-10-20, with no `paidDate`

#### Scenario: past bill not yet paid
- **Given** the date is 2026-10-03 and the switch shows Paid
- **When** the user turns Paid off and saves
- **Then** the transaction is unpaid and due 2026-10-03 (overdue)

#### Scenario: paid today
- **When** the user saves with today's date
- **Then** `paid` is true and `paidDate` is today

### TRX-011: Repeat
Repeat offers Doesn't repeat, Monthly, and Yearly. Monthly or Yearly saves a template (`isRecurring = true`, that `frequency`) that is also the first occurrence on the chosen date (TRX-014). Legacy weekly/bi-weekly items open with "Doesn't repeat" selected.

#### Scenario: monthly rent
- **When** the user saves "Rent", R$ 2,000, 2026-10-10, Monthly
- **Then** one template due 2026-10-10 with frequency monthly is saved

### TRX-012: Last used account
A new form starts with the account used in the last manual save on this device, if it still exists. The value is stored on the device and survives restarts. With no stored account, the field starts empty.

#### Scenario: second entry
- **Given** the user saved an expense on "Nubank card"
- **When** they open a new form
- **Then** the account is "Nubank card"

#### Scenario: account deleted
- **Given** the last used account was deleted
- **When** a new form opens
- **Then** the account field is empty

### TRX-013: Description is stored and shown
Transactions have a `description` field. Lists, details, category detail, schedule, upcoming dues, match chips, and reminders show the display name.

#### Scenario: legacy imported item
- **Given** a stored transaction with no description and notes "Compra no débito - PADARIA"
- **Then** it is shown as "Compra no débito - PADARIA"

#### Scenario: legacy item without text
- **Given** a stored transaction with no description, no notes, and category Food
- **Then** it is shown as "Food"

### TRX-014: Recurring occurrences
On app start (after sign-in), for every monthly or yearly template, the app creates every missing occurrence:
- **monthly:** one per month after the template's due-date month; **yearly:** one per year after it, in the same calendar month;
- due on the template's day of month, clamped to the month's last day;
- up to the **last day of next month** (relative to today);
- skipped when an occurrence of that template already has a due date in that month.

Occurrences copy the template's type, amount, description, notes, category, and account. They are **always unpaid**, with no `paidDate`, and never touch accounts. Missed past months are created too, so they show as overdue. Weekly and bi-weekly templates don't generate occurrences. Deleting a template keeps its occurrences and stops new ones. Editing a template changes only occurrences created afterwards.

#### Scenario: rent through next month
- **Given** today is 2026-10-06 and a monthly template "Rent" due 2026-08-10 with no occurrences
- **When** the app starts
- **Then** unpaid Rent occurrences due 2026-09-10, 2026-10-10, and 2026-11-10 exist, and none for December

#### Scenario: no duplicates
- **Given** the September, October, and November occurrences exist
- **When** the app starts again on 2026-10-07
- **Then** nothing is created

#### Scenario: day clamping
- **Given** a monthly template due 2026-08-31
- **Then** the September occurrence is due 2026-09-30

#### Scenario: yearly
- **Given** today is 2026-10-06 and a yearly template "IPVA" due 2026-01-20
- **Then** no occurrence is created (next is January 2027, after the end of November 2026)

#### Scenario: template was paid
- **Given** a paid monthly template
- **When** the next occurrence is created
- **Then** it is unpaid

## MODIFIED

### TRX-007: Search by description
A search field filters the list, together with TRX-006, to transactions whose **display name** contains the text, case- and accent-insensitive. Empty text means no search filter. To search across months, the user picks "All months".

was: "…whose description contains the text… Until `0004`, the description is the stored memo/notes; transactions without one match their category name."

#### Scenario: accents and case
- **Given** a transaction with description "Compra no débito - PADARIA SÃO JOÃO"
- **When** the user types "padaria sao"
- **Then** it is listed

#### Scenario: legacy notes
- **Given** a legacy transaction with no description and notes "Uber trip"
- **When** the user types "uber"
- **Then** it is listed

---

# Capability: Statement import (`statement-import.md`)

## ADDED

### IMP-020: Memo is the description
Imported transactions store the statement memo (checking) or title (card bill) as `description`, and leave `notes` empty. A matched scheduled item (IMP-015) keeps its own description.

#### Scenario: card purchase
- **Given** card line `2026-09-03,Padaria,25.90`
- **When** it is imported
- **Then** the transaction's description is "Padaria" and notes are empty

## MODIFIED

### IMP-014: Match candidates
A new imported **expense** has as candidates every transaction that is an expense, unpaid, and **not a weekly/bi-weekly template**, with due date within ±5 days of the item's date and amount within ±15% of the item's amount. Unpaid monthly/yearly templates are candidates, because a template is its own first occurrence (TRX-014). Candidates are sorted by date distance, then amount distance. A scheduled item can be matched by only one item in the same import; the closest item (same sort) gets it. Income items are never matched.

was: "…every transaction that is an expense, unpaid, not a recurring template (`isRecurring == false`)…" with the scenario "a monthly recurring template due 2026-09-10 and no generated instance → the template is not a candidate".

#### Scenario: electricity bill
- **Given** an unpaid "Electricity" R$ 180 due 2026-09-10
- **When** a statement line of −R$ 192.40 on 2026-09-12 is reviewed
- **Then** the item shows a match with "Electricity"

#### Scenario: out of range
- **Given** an unpaid R$ 180 due 2026-09-10
- **Then** a line of −R$ 210 (+16.7%) or one dated 2026-09-16 (6 days) has no match

#### Scenario: unpaid first occurrence
- **Given** a new unpaid monthly template "Rent" R$ 2,000 due 2026-09-10
- **When** a statement line of −R$ 2,000 on 2026-09-10 is reviewed
- **Then** the item matches Rent, and confirming marks the template paid

---

# Capability: Dashboard (`dashboard.md`)

## MODIFIED

### DSH-010: Planned
For current and future months, Home shows "Planned by month end: R$ X (+ R$ Y in N bills)":
- Y = sum and N = count of unpaid bills with due date in the selected month (including overdue ones in that month) plus projected occurrences (DSH-011);
- X = Spent + Y.

An **unpaid bill** is an unpaid expense whose category kind is `spending` or that is uncategorized, **including unpaid monthly/yearly templates** (their first occurrence). Weekly/bi-weekly templates are excluded. The same definition applies to DSH-015. When N is 0, the parenthesis is omitted. Unpaid bills from earlier months and unpaid *Investment*/*Ignored* items aren't included. Past months show no Planned.

was: unpaid bill defined as "an unpaid expense (not a recurring template)…".

#### Scenario: current month
- **Given** today is 2026-10-06, Spent R$ 1,500, unpaid Electricity R$ 180 due Oct 20, unpaid Internet R$ 100 due Oct 3, unpaid Rent R$ 2,000 due Sep 28, unpaid R$ 1,000 *Investment* due Oct 15
- **Then** Home shows "Planned by month end: R$ 1,780 (+ R$ 280 in 2 bills)"

#### Scenario: new monthly template this month
- **Given** today is 2026-10-06, Spent R$ 500, and a new unpaid monthly template "Gym" R$ 100 due Oct 15
- **Then** Home shows "Planned by month end: R$ 600 (+ R$ 100 in 1 bill)"

---

# Capability: Schedule & reminders (`schedule-and-reminders.md`)

## ADDED

### SCH-004: Bill reminders
For every unpaid expense with a due date (including templates and occurrences), when push alerts are enabled, the app schedules a local notification at **09:00** local time **1 day before** the due date and another **on** the due date. Times already past are skipped. Each shows the display name and the amount formatted in R$, in the current app language. Overdue items get no OS notification. Inbox entries are added as today.

#### Scenario: electricity
- **Given** today is 2026-10-06 and an unpaid "Electricity" R$ 180 due 2026-10-12
- **Then** notifications are scheduled for 2026-10-11 09:00 ("due tomorrow") and 2026-10-12 09:00 ("due today"), each with "Electricity" and "R$ 180,00" (pt) / "R$180.00" (en)

#### Scenario: paid before the due date
- **Given** the reminders above
- **When** Electricity is marked paid
- **Then** both are cancelled

#### Scenario: due today after 09:00
- **Given** it is 2026-10-12 10:00 and an unpaid bill is due today
- **Then** no notification is scheduled for it

### SCH-005: Credit card bill reminders
For every `credit_card` account with a due day, when push alerts are enabled, the app schedules a local notification at **09:00** on **3 days before** and **on** each of the account's next two due dates (the due day clamped to the month's last day). Times already past are skipped. The text names the account and the due date, without an amount ("Nubank card bill due Oct 7" / "Nubank card bill due today"). Checking and cash accounts get none.

#### Scenario: due day 7
- **Given** today is 2026-10-02 and "Nubank card" with due day 7
- **Then** notifications are scheduled for Oct 4 and Oct 7 at 09:00, and for Nov 4 and Nov 7 at 09:00

#### Scenario: inside the window
- **Given** today is 2026-10-05 10:00 and due day 7
- **Then** Oct 7, Nov 4, and Nov 7 at 09:00 are scheduled, and Oct 4 is not

#### Scenario: due day 31
- **Given** due day 31 and today is 2026-11-01
- **Then** the due dates are Nov 30 and Dec 31

#### Scenario: due day removed
- **When** the account becomes checking
- **Then** its card reminders are cancelled

### SCH-006: When reminders are refreshed
Bill (SCH-004) and card (SCH-005) reminders are recomputed from the current transactions and accounts:
- on app start after sign-in;
- whenever transactions or accounts change (add, edit, delete, import, recurring generation);
- when the app language changes;
- when push alerts are turned on or off (off cancels them).

They are cancelled on sign-out and by "Delete all my data" (SET-001). Refreshing never cancels the weekly import reminder (SCH-002), and doesn't depend on any screen being open or on Transactions filters.

#### Scenario: language change
- **Given** a scheduled bill reminder in English
- **When** the user switches to Portuguese
- **Then** the reminder is rescheduled with Portuguese text

#### Scenario: sign-out
- **Given** scheduled bill and card reminders
- **When** the user signs out
- **Then** none of them remain

#### Scenario: push alerts off
- **When** the user turns push alerts off
- **Then** no bill or card reminder remains scheduled

### SCH-007: Localized notification channels
Android notification channels have names and descriptions in the current app language (bill reminders: "Bill reminders" / "Lembretes de contas"). No user-visible notification text is hardcoded.

#### Scenario: English app
- **Given** the app is in English
- **When** the user opens Android's notification settings for DueDay
- **Then** the bill channel reads "Bill reminders"
