# Settings

## Purpose
Let the user control their data and app preferences.

## Requirements

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
