# Spec delta — 0003 New look

Builds on `0001` and `0002` deltas. `navigation` is new (prefix `NAV`).

Terms used below:
- **Month kind:** relative to today, the selected month is *past*, *current*, or *future*.
- **Counts as spending:** a paid expense whose category kind is `spending`, or that has no category or a category that no longer exists (DSH-003).
- **Unpaid bill:** an unpaid expense (not a recurring template) whose category kind is `spending` or that is uncategorized.

---

# Capability: Navigation (`navigation.md`)

## Purpose
Organize the app around the user's tasks: see spending, find a transaction, see what's due, change settings, and add data from anywhere.

## ADDED

### NAV-001: Tabs
The bottom bar shows, in order: **Home**, **Transactions**, a central **"+"**, **Schedule**, **Settings**. The app opens on Home. Each tab keeps its own state when switching. Accounts and Categories aren't tabs.

#### Scenario: opening the app
- **Given** a signed-in user
- **When** the app starts
- **Then** Home is selected and the bar shows Home, Transactions, "+", Schedule, Settings

#### Scenario: tab state is kept
- **Given** the Transactions tab filtered by "Food"
- **When** the user goes to Home and back to Transactions
- **Then** the "Food" filter is still applied

### NAV-002: Central "+"
Tapping "+" opens a sheet with **Import statement** (first) and **Add manually**. Import opens the import screen full screen (same flow as IMP-001…IMP-019). Add manually opens the transaction form as a sheet. Closing the sheet keeps the current tab. "+" never becomes the selected tab.

#### Scenario: importing from Home
- **Given** Home is open
- **When** the user taps "+" then "Import statement"
- **Then** the file picker of the import screen opens

#### Scenario: manual entry
- **When** the user taps "+" then "Add manually"
- **Then** the transaction form opens, and after saving the user is back on the same tab

### NAV-003: Settings holds accounts and categories
The Settings tab replaces the profile screen. Accounts and Categories open from Settings as pages with a back action, under the bottom bar. There is no avatar shortcut in the app bars; the notifications bell is on Home's app bar only.

#### Scenario: editing an account
- **Given** the Settings tab
- **When** the user taps "Accounts"
- **Then** the accounts list opens, and back returns to Settings

---

# Capability: Dashboard (`dashboard.md`)

## ADDED

### DSH-008: Home layout by month kind
Home shows, top to bottom:
1. Month selector (DSH-001).
2. Spent with comparison (DSH-009); Income and Invested below it.
3. Planned (DSH-010).
4. Uncategorized warning (DSH-012).
5. Spending by category (DSH-013).
6. Upcoming dues (DSH-015).

Past months show 1, 2, 4, 5. The current month shows all. Future months show 1 and 3 only.

#### Scenario: past month
- **Given** today is 2026-10-06
- **When** Home shows September 2026
- **Then** Spent, comparison, Income, Invested, warning (if any), and categories are shown, and Planned and dues are not

#### Scenario: future month
- **When** Home shows November 2026
- **Then** only the month selector and Planned are shown

### DSH-009: Spent vs previous month
Below Spent, Home shows "↑ N% vs <previous month>" when Spent is higher, "↓ N%" when lower, "Same as <previous month>" when N rounds to 0. N = |Spent − Previous| / Previous × 100, rounded to an integer.

*Previous* is what counted as Spent in the previous month:
- **current month:** day 1 through today's day of month, limited to the previous month's last day; Spent covers day 1 through today;
- **past month:** the full previous month.

When Previous is 0, no comparison is shown.

#### Scenario: same period mid-month
- **Given** today is 2026-10-06, R$ 600 spent Oct 1–6, R$ 500 spent Sep 1–6, R$ 3,000 spent in all of September
- **Then** Home shows "↑ 20% vs September"

#### Scenario: past month
- **Given** August Spent R$ 4,000 and September Spent R$ 3,000
- **When** Home shows September
- **Then** it shows "↓ 25% vs August"

#### Scenario: short previous month
- **Given** today is 2026-03-31
- **Then** Previous covers all of February

#### Scenario: nothing last month
- **Given** no spending in the previous month
- **Then** no comparison is shown

### DSH-010: Planned
For current and future months, Home shows "Planned by month end: R$ X (+ R$ Y in N bills)":
- Y = sum and N = count of unpaid bills with due date in the selected month (including overdue ones in that month) plus projected occurrences (DSH-011);
- X = Spent + Y.

When N is 0, the parenthesis is omitted. Unpaid bills from earlier months and unpaid *Investment*/*Ignored* items aren't included. Past months show no Planned.

#### Scenario: current month
- **Given** today is 2026-10-06, Spent R$ 1,500, unpaid Electricity R$ 180 due Oct 20, unpaid Internet R$ 100 due Oct 3, unpaid Rent R$ 2,000 due Sep 28, unpaid R$ 1,000 *Investment* due Oct 15
- **Then** Home shows "Planned by month end: R$ 1,780 (+ R$ 280 in 2 bills)"

#### Scenario: nothing pending
- **Given** Spent R$ 900 and no unpaid bills in the month
- **Then** Home shows "Planned by month end: R$ 900"

### DSH-011: Recurring bills are estimated, not stored
For current and future months, every recurring expense template (`isRecurring`, no parent) with frequency monthly or yearly and kind `spending` (or uncategorized) adds one **projected occurrence** to the month when all of these hold:
- **monthly:** the month is after the template's due-date month;
- **yearly:** the month has the template's due-date calendar month, in a later year;
- the day is the template's due day, clamped to the month's last day;
- no transaction with `parentRecurringId` = template id has a due date in that month.

A projected occurrence is unpaid, has the template's amount, description, and category, and counts in Planned (DSH-010) and upcoming dues (DSH-015). It is computed each time and never written to Firestore or the device. It isn't listed in Transactions. Weekly and bi-weekly templates aren't projected.

#### Scenario: rent next month
- **Given** a monthly template "Rent" R$ 2,000 due 2026-08-10
- **When** Home shows November 2026
- **Then** Planned includes R$ 2,000 for Rent due Nov 10, counted as 1 bill

#### Scenario: instance already exists
- **Given** the same template and a generated instance due 2026-10-10
- **When** Home shows October 2026
- **Then** Rent is counted once, from the instance

#### Scenario: yearly
- **Given** a yearly template "IPVA" R$ 1,200 due 2026-01-20
- **Then** it is projected in January 2027 and in no other month of 2026 or 2027

#### Scenario: day clamping
- **Given** a monthly template due 2026-08-31
- **When** Home shows November 2026
- **Then** the occurrence is due Nov 30

### DSH-012: Uncategorized warning
When the selected month has N > 0 expenses counting as spending without a category (missing or deleted), Home shows "N uncategorized". Tapping it opens the Transactions tab filtered to that month and Uncategorized (TRX-006). It's hidden when N = 0 and on future months.

#### Scenario: after an import
- **Given** 8 uncategorized paid expenses in September
- **When** Home shows September and the user taps "8 uncategorized"
- **Then** Transactions shows September, Uncategorized, with those 8 items

### DSH-013: Spending by category list
Every group from DSH-006 is listed, sorted by amount (highest first). Each row shows the category name (localized for system categories, "Uncategorized" for the group without category), amount, share of Spent as a whole percent, and a bar proportional to that share. The list ends with "Manage categories", which opens Settings › Categories.

#### Scenario: twelve categories
- **Given** spending in 12 categories
- **Then** all 12 are listed, highest first

#### Scenario: share
- **Given** Spent R$ 2,000 and Food R$ 500
- **Then** the Food row shows R$ 500 and 25%

### DSH-014: Category detail
Tapping a row in DSH-013 opens the category detail for the selected month:
- the total;
- the comparison vs the previous month (DSH-009 rules, restricted to that category);
- the transactions counted in that total, newest effective date first.

Tapping a transaction opens its details. An "Edit" action opens the category form (system categories follow CAT-003). The Uncategorized group has no Edit.

#### Scenario: Food in September
- **Given** September Food R$ 800 in 12 transactions and August Food R$ 1,000
- **When** the user taps Food on Home showing September
- **Then** the detail shows R$ 800, "↓ 20% vs August", and the 12 transactions

#### Scenario: categorizing from the detail
- **Given** the Uncategorized detail with 3 items
- **When** the user opens one, assigns Food, and returns
- **Then** the detail lists 2 items and the total drops accordingly

### DSH-015: Upcoming dues
On the current month, Home lists unpaid bills, real and projected (DSH-011), that are overdue (any earlier date) or due from today through today + 10 days, sorted by due date, at most 5. Each shows description (or category name), amount, and "Overdue", "Today", "Tomorrow", or "In N days". "See all" opens the Schedule tab. When the list is empty, Home shows "Nothing due in the next 10 days".

#### Scenario: mixed dues
- **Given** today is 2026-10-06, unpaid Internet due Oct 3, unpaid Electricity due Oct 12, unpaid Gym due Oct 25
- **Then** Home lists Internet (Overdue) and Electricity (In 6 days), not Gym

### DSH-016: Nothing else on Home
Home shows no insight, budget, or "highest category" warning, no greeting, and no account filter. All totals cover every account.

#### Scenario: opening Home
- **Then** none of the removed elements are shown and totals include every account

---

# Capability: Transactions (`transactions.md`)

## ADDED

### TRX-005: History is the Transactions tab
The Transactions tab opens the transaction list, newest effective date (TRX-003) first, filtered to the current month by default. Tapping an item opens its details (view, edit, delete). There is no separate History screen and no create form on this tab (creating is via "+", NAV-002). Projected occurrences (DSH-011) aren't listed.

#### Scenario: opening the tab
- **Given** today is 2026-10-06
- **When** the user opens Transactions
- **Then** only transactions with effective date in October 2026 are listed, newest first

### TRX-006: Filters
The list can be filtered by:
- **month:** previous/next, or "All months";
- **category:** any one category, or Uncategorized (no category or deleted category);
- **account:** matches the account the money left from or arrived in;
- **type:** income or expense.

Filters combine with AND and use the effective date. Active filters are visible, and one action clears all of them back to the current month. Home can open the tab with filters preset (DSH-012). Filtering doesn't change bill reminders.

#### Scenario: combining filters
- **Given** September has 5 Food expenses on "Nubank card" and 2 Food expenses on "Nubank"
- **When** the user filters September, Food, and "Nubank card"
- **Then** 5 items are listed

#### Scenario: uncategorized
- **Given** a transaction whose category was deleted
- **When** the Uncategorized filter is applied
- **Then** that transaction is listed

#### Scenario: clearing
- **When** the user clears all filters
- **Then** the list shows the current month with no other filter

### TRX-007: Search by description
A search field filters the list, together with TRX-006, to transactions whose description contains the text, case- and accent-insensitive. Until `0004`, the description is the stored memo/notes; transactions without one match their category name. Empty text means no search filter. To search across months, the user picks "All months".

#### Scenario: accents and case
- **Given** a transaction with memo "Compra no débito - PADARIA SÃO JOÃO"
- **When** the user types "padaria sao"
- **Then** it is listed

#### Scenario: no results
- **When** the search matches nothing
- **Then** the list shows "No transactions found" and the clear-filters action

---

# Capability: Settings (`settings.md`)

## ADDED

### SET-003: Settings tab
The Settings tab shows, in order:
1. profile header (photo, name, email; unchanged behavior);
2. **Accounts** and **Categories** (NAV-003);
3. **Notifications** (push alerts, weekly import reminder SET-002);
4. **Appearance** (theme, language);
5. **Security** (biometrics);
6. **Data** (Delete all my data, SET-001);
7. Sign out.

#### Scenario: opening Settings
- **When** the user opens the Settings tab
- **Then** the sections appear in that order and each is reachable by scrolling

## MODIFIED

### SET-001: Delete all my data
The **Settings tab** has "Delete all my data". After a confirmation dialog that states it can't be undone, every account, category, transaction, and categorization rule of the user is deleted. Login, profile, and app preferences stay. On the next category load, defaults are created again (CAT-004). All bill reminders are cancelled; the weekly import reminder follows its toggle (SET-002).

was: "The settings (profile) screen has "Delete all my data"…"

#### Scenario: confirming
- **Given** a user with accounts, categories, and 300 transactions
- **When** they tap "Delete all my data" in the Settings tab and confirm
- **Then** their data is deleted, they stay signed in, and Home shows zero totals
