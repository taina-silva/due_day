# Project Glossary (glossary.md)

This reference defines the business and technical terminology used in **DueDay** to ensure consistency across specifications, code, database schemas, and documentation.

---

## 💰 1. Financial Domain Vocabulary

- **Account:** A representation of a money storage location, such as a bank account, credit card, cash wallet, or investment portfolio.
- **Transaction:** An entry recording a movement of money. Transactions have three types:
  - `Income`: Incoming money that increases an account's balance.
  - `Expense`: Outgoing money that decreases an account's balance.
  - `Transfer`: Movement of money from a source account (`accountFrom`) to a destination account (`accountTo`).
- **Current Balance:** The actual sum of money in a user's accounts at the present moment.
- **Projected Balance:** The calculated balance estimation that takes into account pending or future scheduled transactions due on or before today.
- **Schedule:** A planned future transaction containing a due date (`dueDate`). Used for tracking bills and sending reminders before the deadline.
- **Category:** A label (e.g. Food, Rent, Transport) used to categorize incomes and expenses for statistics and filters.
- **Paid:** A status indicating whether a transaction has been executed.

---

## 🏗️ 2. Architectural Terminology

- **Entity:** Domain-layer representation of business concepts, free from framework annotations or databases.
- **Model:** Data-layer representation of an entity, adding serialization capabilities (`fromJson`/`toJson`).
- **DataSource:** Classes responsible for fetching raw data from a source (Firestore, SecureStorage, external APIs).
- **Repository:** Bridge pattern implementing domain interfaces to orchestrate data fetches and map raw exceptions to controlled failures.
- **UseCase:** Single-purpose domain classes representing business actions (e.g., `AddAccount`).
- **Failure:** Domain-layer objects representing errors returned to the UI instead of throwing exceptions.
- **BLoC (Business Logic Component):** Presentation-layer component that acts as a state machine. It consumes events and yields states.
