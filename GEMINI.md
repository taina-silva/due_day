# Gemini AI Context Structure - Entry Point (GEMINI.md)

Welcome! This document serves as the high-level entry point for AI models to understand the **DueDay** codebase, architecture, rules, and philosophy.

---

## 🎯 Project Overview

**DueDay** is a personal financial control and planning mobile application designed exclusively for **Android** and **iOS** platforms. It allows users to:

1. Manage bank accounts/credit cards.
2. Register and filter transactions (Income, Expense, Transfer).
3. Organize transactions into custom user categories.
4. Schedule payment due dates and receive integrated local and push notifications.

---

## 🛠️ Technology Stack

- **Framework:** Flutter SDK `3.41.6` (via FVM)
- **Language:** Dart SDK `3.11.4`
- **State Management:** BLoC (`flutter_bloc` & `rxdart`)
- **Routing:** GoRouter (`go_router` v14+)
- **Dependency Injection:** Service Locator (`get_it`)
- **Functional Programming:** `fpdart` & `equatable`
- **Backend Services:** Firebase (Auth, Firestore, Cloud Messaging)
- **Local Security:** Biometric Authentication (`local_auth`) & Secure Storage (`flutter_secure_storage`)
- **Code Generation:** `freezed`, `json_serializable`, and `build_runner`

---

## 🏗️ Architecture & Philosophy

DueDay follows **Clean Architecture** and **SOLID** principles.
Dependency flow points strictly inwards:
`Presentation (UI/BLoC) ➔ Domain (Use Cases/Entities) 🠔 Data (Models/DataSources/Repositories)`

### Core Philosophies

1. **No Layer Bypassing:** The UI never queries DataSources or Repositories directly. It sends events to BLoCs, which invoke UseCases.
2. **KISS Principle (Keep It Simple, Stupid):** Avoid over-engineering. Do not create redundant aggregation tables or repositories. Combine multiple UseCases inside BLoCs to aggregate data (e.g., `DashboardBloc` consumes `GetAccounts` and `GetTransactions` to calculate balance totals).
3. **Imutability:** Use `@freezed` models and `const` constructors where possible.
4. **Controlled Errors:** Do not let raw exceptions propagate to the UI. Repositories must catch exceptions and return `Either<Failure, T>` using `fpdart`.

---

## 📐 Global Development Rules

- **Formatting & Style:** Strictly use `snake_case` for filenames. Use standard suffixes: `*_entity.dart`, `*_model.dart`, `*_remote_data_source.dart`, `*_local_data_source.dart`, `*_repository_impl.dart`, `*_bloc.dart`, `*_page.dart`, `*_widget.dart`.
- **Acessibility:** Element touch target must be at least **44x44px**. Use **WCAG AA** color contrast.
- **Design Tokens:** Always utilize `DueDayTheme` for typography, colors, and sizes. No hardcoded colors (`Colors.white`) or absolute sizes.
- **Responsive Layout:** Apply `.w`, `.h`, `.sp`, or `.fs` from `NumExtension` to all numerical dimension values.
- **Localization:** No user-facing hardcoded text. Always use translation keys from `AppLocalizations.of(context)` defined in `app_en.arb` and `app_pt.arb`.

---

## 📖 Documentation Organization

The project's AI context documentation is divided into four main directories:

### 1. `docs/` — Conceptual Manuals

_How does this project work?_ Refer to these for architectural patterns, standards, and rules.

- [architecture.md](.gemini/docs/architecture.md) — Clean Architecture layers, SOLID principles, and anti-patterns.
- [coding_standards.md](.gemini/docs/coding_standards.md) — Code style, errors, imports, and naming standards.
- [feature_development.md](.gemini/docs/feature_development.md) — Directory layout and feature development workflow.
- [firestore.md](.gemini/docs/firestore.md) — Firestore collections, queries, subcollections, rules, and pagination.
- [navigation.md](.gemini/docs/navigation.md) — GoRouter setup, bottom nav state, and guards.
- [design_system.md](.gemini/docs/design_system.md) — Full Design System specs, tokens, typography, colors, spacing, components, and code template.
- [notifications.md](.gemini/docs/notifications.md) — FCM and local notifications handling.
- [testing.md](.gemini/docs/testing.md) — Unit, widget, and integration testing strategies.

### 2. `references/` — Project Truth Maps

_Where is the official data or structure?_ Quick reference tables, schemas, and mapping.

- [project_structure.md](.gemini/references/project_structure.md) — Entire folder mapping.
- [dependency_map.md](.gemini/references/dependency_map.md) — Layer imports flow and feature boundaries.
- [firestore_schema.md](.gemini/references/firestore_schema.md) — Database schema definitions.
- [dependency_injection.md](.gemini/references/dependency_injection.md) — GetIt service locator mapping.
- [localization.md](.gemini/references/localization.md) — Translation setups.
- [firebase_setup.md](.gemini/references/firebase_setup.md) — Firebase CLI setup, environment options, and rules initialization.
- [security_hardening.md](.gemini/references/security_hardening.md) — Native configurations and services for biometrics and app privacy.
- [glossary.md](.gemini/references/glossary.md) — Domain definitions.


### 3. `skills/` — Action Recipes

_How do I perform task X following project standards?_ Structured step-by-step procedures.

- [create_usecase.md](.gemini/skills/create_usecase.md) — Write a Domain UseCase.
- [create_datasource.md](.gemini/skills/create_datasource.md) — Create a DataSource.
- [create_repository.md](.gemini/skills/create_repository.md) — Implement contracts.
- [create_model.md](.gemini/skills/create_model.md) — Build Freezed models.
- [create_bloc.md](.gemini/skills/create_bloc.md) — Set up state management.
- [create_screen.md](.gemini/skills/create_screen.md) — Assemble widgets and UI.

### 4. `agents/` — Assistant Personas

_Who is specialized in Y?_ Custom instructions for targeted agent roles.

- [flutter_architect.md](.gemini/agents/flutter_architect.md) — Layer compliance and architecture decisions.
- [flutter_developer.md](.gemini/agents/flutter_developer.md) — Feature code and UI details.
- [firebase_engineer.md](.gemini/agents/firebase_engineer.md) — DB setup and rules.
- [code_reviewer.md](.gemini/agents/code_reviewer.md) — Style and debt inspections.
- [debugger.md](.gemini/agents/debugger.md) — Error investigation.
- [testing_architect.md](.gemini/agents/testing_architect.md) — Test planning.
- [testing_engineer.md](.gemini/agents/testing_engineer.md) — Writing test suites.
- [testing_reviewer.md](.gemini/agents/testing_reviewer.md) — Reviewing test patterns.
