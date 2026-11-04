# Transactions

## Purpose
Record what was spent or received, on which date, from which account, and in which category.

## Requirements

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
