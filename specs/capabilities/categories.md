# Categories

## Purpose
Group transactions so spending can be read by category.

## Requirements

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
