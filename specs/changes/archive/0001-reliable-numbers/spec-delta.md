# Spec delta — 0001 Reliable numbers

All capabilities are new; every requirement is ADDED.

---

# Capability: Transactions (`transactions.md`)

## Purpose
Record what was spent or received, on which date, from which account, and in which category.

## ADDED

### TRX-001: Only income and expense can be created
A transaction is either income or expense. `transfer` can't be chosen in the form or in the history filter.

#### Scenario: creating a transaction
- **Given** the transaction form is open
- **When** the user opens the type selector
- **Then** only Income and Expense are offered

### TRX-002: Legacy transfers load but count nowhere
Stored documents with `type: transfer` still load and appear in history, and are excluded from every dashboard total.

#### Scenario: a legacy transfer in the month
- **Given** a paid transfer of R$ 500 dated in the selected month
- **When** the dashboard is computed
- **Then** Spent, Income, and Invested don't change because of it

### TRX-003: Effective date
A transaction's effective date is `paidDate`; if missing, `dueDate`; if both are missing, `createdAt`. Month grouping uses the effective date only.

#### Scenario: imported last quarter, written today
- **Given** a transaction with `paidDate` 2026-07-10 and `createdAt` 2026-10-04
- **When** the effective date is computed
- **Then** it is 2026-07-10

#### Scenario: legacy document without dates
- **Given** a transaction with no `paidDate` and no `dueDate`, `createdAt` 2026-05-02
- **Then** its effective date is 2026-05-02

### TRX-004: Transactions don't touch accounts
Adding, editing, deleting, or generating (recurrence) a transaction never reads or writes an account document.

#### Scenario: adding a paid expense
- **Given** a checking account
- **When** a paid expense on that account is added
- **Then** only the transaction (and its category counter) is written

---

# Capability: Accounts (`accounts.md`)

## Purpose
Say where money is spent from. Accounts have no balance (D2).

## ADDED

### ACC-001: Account types
An account is `checking`, `credit_card`, or `cash`. A credit card has a due day (1–31); other types don't.

#### Scenario: creating a credit card
- **Given** the account form with type Credit card
- **When** the user saves without a due day
- **Then** the form asks for a due day between 1 and 31

#### Scenario: creating cash
- **Given** the account form with type Cash
- **Then** no due day field is shown

### ACC-002: Legacy account types read as checking
Stored `category`/type values other than the three types (`investments`, `savings`, `daily_use`, unknown) load as `checking` instead of failing.

#### Scenario: old savings account
- **Given** a stored account with type `savings`
- **When** accounts load
- **Then** it appears as a Checking account and the list doesn't error

### ACC-003: No balance
Accounts have no balance field: none is asked in the form, shown in the list, card, or account pickers, or totaled anywhere. A stored `balance` field is ignored on read and not written.

#### Scenario: account list
- **Given** two accounts
- **When** the accounts screen opens
- **Then** each shows name and type (and due day for cards), with no amount and no total

---

# Capability: Categories (`categories.md`)

## Purpose
Group transactions so spending can be read by category.

## ADDED

### CAT-001: Category kind
Each category has a `kind`: `spending`, `investment`, or `ignored`. A category without `kind` reads as `spending`. User-created categories are always `spending`.

#### Scenario: legacy category
- **Given** a stored category with no `kind`
- **When** categories load
- **Then** it is a spending category

### CAT-002: System categories exist
*Investment* (`kind: investment`) and *Ignored* (`kind: ignored`) always exist with fixed ids. If missing when categories are loaded, they are created. Their names are shown localized from the kind, not from the stored name.

#### Scenario: existing user without system categories
- **Given** a user with categories but no *Investment*/*Ignored*
- **When** categories load
- **Then** both are created once and listed

#### Scenario: language switch
- **Given** the app in Portuguese
- **Then** the system categories read "Investimento" and "Ignorado"

### CAT-003: System categories are protected
*Investment* and *Ignored* can't be renamed or deleted. Color and icon can be changed.

#### Scenario: trying to delete Ignored
- **Given** the categories screen
- **When** the user opens *Ignored*
- **Then** no delete action and no name field are available

### CAT-004: Default categories on first use
When a user has no categories at all, the app creates, in one batch, the system categories plus spending categories Food, Groceries, Transport, Housing, Bills, Health, Leisure, Shopping, Subscriptions, Education, Other, Salary, Other income, named in the current app language. This never runs again once any category exists.

#### Scenario: new user
- **Given** a user with no categories, app in English
- **When** categories load
- **Then** 15 categories exist: the 13 defaults in English plus *Investment* and *Ignored*

#### Scenario: user deleted some defaults
- **Given** a user who deleted Education
- **When** categories load again
- **Then** Education is not recreated

---

# Capability: Dashboard (`dashboard.md`)

## Purpose
Answer "how much did I spend this month, on what?" with numbers that only count what happened in that month.

## ADDED

### DSH-001: Month selector
The dashboard shows one calendar month, the current one by default. The user can step to the previous or next month; the title shows the month and year.

#### Scenario: going back
- **Given** the dashboard on October 2026
- **When** the user taps "previous month"
- **Then** every total is recomputed for September 2026

### DSH-002: Totals are bounded to the selected month
Only transactions whose effective date (TRX-003) is within the selected month (first day 00:00 to last day 23:59:59, local time) count in that month's totals and category breakdown.

#### Scenario: importing three months at once
- **Given** today is 2026-10-04 and July, August, and September statements were imported today
- **When** the dashboard shows October 2026
- **Then** none of those transactions count
- **And** September 2026 shows only September's transactions

### DSH-003: Spent
Spent = sum of **paid** expenses in the month whose category kind is `spending`. Uncategorized expenses count as spending. Unpaid expenses don't count.

#### Scenario: mixed month
- **Given** paid expenses R$ 100 Food, R$ 50 uncategorized, R$ 1,000 *Investment*, R$ 2,000 *Ignored*, and an unpaid R$ 300 Bills due this month
- **Then** Spent is R$ 150

### DSH-004: Income
Income = sum of paid income in the month whose category kind isn't `ignored`.

#### Scenario: card refund left uncategorized
- **Given** a paid salary R$ 5,000 and an uncategorized card refund R$ 40 in the month
- **Then** Income is R$ 5,040

### DSH-005: Invested
Invested = sum of paid expenses in the month with an `investment` category. It is shown on the dashboard and never added to Spent.

#### Scenario: monthly investment
- **Given** paid expenses R$ 1,000 *Investment* and R$ 200 Food
- **Then** Invested is R$ 1,000 and Spent is R$ 200

### DSH-006: Spending by category
The category breakdown includes only what counts in Spent (DSH-003), grouped by category; uncategorized expenses form their own group.

#### Scenario: Ignored doesn't appear
- **Given** a paid R$ 2,000 card bill payment in *Ignored*
- **Then** *Ignored* is not in the breakdown

### DSH-007: No balances on the dashboard
The dashboard shows no account balance or projected balance.

#### Scenario: opening the dashboard
- **Then** no "current balance" or "projected balance" is shown

---

# Capability: Statement import (`statement-import.md`)

## Purpose
Bring Nubank statements into the app with the least effort and without duplicates.

## ADDED

### IMP-001: Any file can be picked
The picker accepts any file. The format is validated after reading; a file that isn't a supported statement shows "unsupported file" and nothing is imported.

#### Scenario: OFX on Android
- **Given** an Android device and a Nubank `.ofx` file
- **When** the user opens the picker
- **Then** the file can be selected and is parsed

#### Scenario: a PDF
- **When** the user picks a `.pdf`
- **Then** an "unsupported file" error is shown

### IMP-002: Encoding fallback
File bytes are decoded as UTF-8 (BOM removed); if that fails, as Latin-1.

#### Scenario: Latin-1 CSV
- **Given** a CSV saved in Latin-1 with "Descrição" and "Padaria São João"
- **When** it is imported
- **Then** the header is recognized and the memo reads "Padaria São João"

### IMP-003: Format detected by content
The format is detected from the content, not the file name:
- **Checking OFX:** contains `<OFX>` (or `OFXHEADER`).
- **Checking CSV:** header `Data,Valor,Identificador,Descrição`.
- **Card bill CSV:** header `date,title,amount`.

Anything else is unsupported (IMP-001).

#### Scenario: renamed file
- **Given** a card bill CSV renamed to `fatura.txt`
- **When** it is imported
- **Then** it is parsed as a card bill

### IMP-004: Matching account type first
After parsing, the account picker lists accounts of the matching type first: `checking` for checking OFX/CSV, `credit_card` for card bills. Other accounts are still selectable.

#### Scenario: card bill
- **Given** accounts "Nubank" (checking) and "Nubank card" (credit card)
- **When** a card bill is parsed
- **Then** "Nubank card" is listed first

### IMP-005: Card bill lines
In a card bill CSV, `date` is `yyyy-MM-dd` and `amount` uses `.` as decimal separator. A positive amount is a purchase (expense); a negative amount is a credit (income). Rows with an invalid date or amount are skipped.

#### Scenario: purchase and refund
- **Given** rows `2026-09-03,Padaria,25.90` and `2026-09-05,Estorno Loja,-40.00`
- **Then** an expense of R$ 25.90 on 2026-09-03 and an income of R$ 40.00 on 2026-09-05 are listed

### IMP-006: Card bill dedup id
A card bill line's external id is built from its raw date, title, amount in cents, and its occurrence index among identical (date, title, amount) lines in the same file. Re-importing the same file creates nothing new; two identical purchases on the same day are both kept.

#### Scenario: two coffees
- **Given** two rows `2026-09-03,Cafe,8.00`
- **When** the file is imported twice
- **Then** the first import creates 2 transactions and the second creates none

### IMP-007: Card purchases dated on purchase, installments by month billed
Card purchases are paid transactions dated on the line's date. A title with an installment marker `N/M` (e.g. `Loja X - Parcela 3/10`) is dated line date + (N−1) months (day clamped to the month's last day). The external id still uses the raw line date.

#### Scenario: third installment
- **Given** row `2026-06-15,Loja X - Parcela 3/10,100.00`
- **Then** the expense is dated 2026-08-15

#### Scenario: day clamping
- **Given** row `2026-01-31,Loja Y - Parcela 2/3,50.00`
- **Then** the expense is dated 2026-02-28

### IMP-008: Bill payment pre-categorized as Ignored
The card bill payment in a checking statement (memo starting with "Pagamento de fatura") and the payment received in a card bill (title starting with "Pagamento recebido") arrive in the review list already categorized as *Ignored*, case- and accent-insensitive. The user can change it.

#### Scenario: checking statement
- **Given** a checking line "Pagamento de fatura" of −R$ 2,000
- **Then** it appears in review as an expense in *Ignored*

#### Scenario: card bill
- **Given** a card line `2026-09-10,Pagamento recebido,-2000.00`
- **Then** it appears in review as income in *Ignored*

### IMP-009: Other card credits arrive uncategorized
Negative card lines that aren't the bill payment (refunds, chargebacks) arrive as uncategorized income.

#### Scenario: refund
- **Given** `2026-09-05,Estorno Loja,-40.00`
- **Then** it is listed as uncategorized income

### IMP-010: Import doesn't touch accounts
Confirming an import writes only transactions (and category counters). The chosen account is stored on each transaction; no account document changes.

#### Scenario: confirming 30 items
- **When** an import of 30 items is confirmed
- **Then** 30 transactions are written and no account document is updated

---

# Capability: Settings (`settings.md`)

## Purpose
Let the user control their data and app preferences.

## ADDED

### SET-001: Delete all my data
The settings (profile) screen has "Delete all my data". After a confirmation dialog that states it can't be undone, every account, category, and transaction of the user is deleted. Login, profile, and app preferences stay. On the next category load, defaults are created again (CAT-004). All scheduled local reminders are cancelled.

#### Scenario: confirming
- **Given** a user with accounts, categories, and 300 transactions
- **When** they tap "Delete all my data" and confirm
- **Then** their accounts, categories, and transactions are deleted, they stay signed in, and the dashboard shows zero totals

#### Scenario: cancelling
- **When** they tap "Delete all my data" and cancel
- **Then** nothing is deleted

#### Scenario: failure
- **Given** the delete returns an error
- **Then** an error message is shown, the user stays on the screen, and can retry
