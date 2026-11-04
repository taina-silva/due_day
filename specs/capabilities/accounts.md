# Accounts

## Purpose
Say where money is spent from. Accounts have no balance (D2).

## Requirements

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
