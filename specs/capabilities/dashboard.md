# Dashboard

## Purpose
Answer "how much did I spend this month, on what?" with numbers that only count what happened in that month.

## Requirements

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
