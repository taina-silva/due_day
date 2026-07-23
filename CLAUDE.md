# DueDay — Project Context (CLAUDE.md)

This document is the high-level entry point for Claude Code to understand the **DueDay** codebase, architecture, rules, and philosophy.

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
- **Language for Code & Docs:** English is mandatory everywhere in the codebase — code comments, identifiers, exception/log messages, commit messages, and all `.claude/` documentation (`docs/`, `references/`, `skills/`, `agents/`, `plans/`). The **only** place pt-BR text is justified is inside `app_pt.arb` and other localization catalogs, since that content is meant to be read by end users in Portuguese.

---

## 📖 Documentation Organization

The project's AI context documentation lives under `.claude/` and is divided into four main directories:

### 1. `docs/` — Conceptual Manuals

_How does this project work?_ Refer to these for architectural patterns, standards, and rules.

- [architecture.md](.claude/docs/architecture.md) — Clean Architecture layers, SOLID principles, and anti-patterns.
- [coding_standards.md](.claude/docs/coding_standards.md) — Code style, errors, imports, and naming standards.
- [feature_development.md](.claude/docs/feature_development.md) — Directory layout and feature development workflow.
- [firestore.md](.claude/docs/firestore.md) — Firestore collections, queries, subcollections, rules, and pagination.
- [navigation.md](.claude/docs/navigation.md) — GoRouter setup, bottom nav state, and guards.
- [design_system.md](.claude/docs/design_system.md) — Full Design System specs, tokens, typography, colors, spacing, components, and code template.
- [notifications.md](.claude/docs/notifications.md) — FCM and local notifications handling.
- [observability.md](.claude/docs/observability.md) — Logging, error capture, and event tracking (`core/observability`).
- [testing.md](.claude/docs/testing.md) — Unit, widget, and integration testing strategies.

### 2. `references/` — Project Truth Maps

_Where is the official data or structure?_ Quick reference tables, schemas, and mapping.

- [project_structure.md](.claude/references/project_structure.md) — Entire folder mapping.
- [dependency_map.md](.claude/references/dependency_map.md) — Layer imports flow and feature boundaries.
- [firestore_schema.md](.claude/references/firestore_schema.md) — Database schema definitions.
- [dependency_injection.md](.claude/references/dependency_injection.md) — GetIt service locator mapping.
- [localization.md](.claude/references/localization.md) — Translation setups.
- [firebase_setup.md](.claude/references/firebase_setup.md) — Firebase CLI setup, environment options, and rules initialization.
- [security_hardening.md](.claude/references/security_hardening.md) — Native configurations and services for biometrics and app privacy.
- [glossary.md](.claude/references/glossary.md) — Domain definitions.

### 3. `skills/` — Action Recipes

_How do I perform task X following project standards?_ Each skill is invocable directly (e.g. `/create-bloc`) and is auto-loaded by Claude Code when its `description` matches the task at hand.

- [create-usecase](.claude/skills/create-usecase/SKILL.md) — Write a Domain UseCase.
- [create-datasource](.claude/skills/create-datasource/SKILL.md) — Create a DataSource.
- [create-repository](.claude/skills/create-repository/SKILL.md) — Implement contracts.
- [create-model](.claude/skills/create-model/SKILL.md) — Build Freezed models.
- [create-bloc](.claude/skills/create-bloc/SKILL.md) — Set up state management.
- [create-screen](.claude/skills/create-screen/SKILL.md) — Assemble widgets and UI.
- [create-firestore-query](.claude/skills/create-firestore-query/SKILL.md) — Build optimized Firestore queries/streams.
- [add-route](.claude/skills/add-route/SKILL.md) — Register and navigate GoRouter routes.
- [add-notification](.claude/skills/add-notification/SKILL.md) — Schedule/record local and push notifications.
- [add-test-coverage-existing-feature](.claude/skills/add-test-coverage-existing-feature/SKILL.md) — Close coverage gaps on an existing feature.
- [refactor-feature](.claude/skills/refactor-feature/SKILL.md) — Safely refactor without regressions.
- [debug-feature](.claude/skills/debug-feature/SKILL.md) — Investigate bugs and state issues.
- [review-feature](.claude/skills/review-feature/SKILL.md) — Checklist for reviewing a feature submission.

### 4. `agents/` — Subagent Personas

_Who is specialized in Y?_ Custom subagents invocable via the Agent/Task tool with `subagent_type` set to the name below.

- [flutter-architect](.claude/agents/flutter-architect.md) — Layer compliance and architecture decisions.
- [flutter-developer](.claude/agents/flutter-developer.md) — Feature code and UI details.
- [firebase-engineer](.claude/agents/firebase-engineer.md) — DB setup and rules.
- [code-reviewer](.claude/agents/code-reviewer.md) — Style and debt inspections.
- [debugger](.claude/agents/debugger.md) — Error investigation.
- [testing-architect](.claude/agents/testing-architect.md) — Test planning.
- [testing-engineer](.claude/agents/testing-engineer.md) — Writing test suites.
- [testing-reviewer](.claude/agents/testing-reviewer.md) — Reviewing test patterns.

### 5. `plans/` — Scratch Planning Docs

Working plan documents (e.g. `plans/auth/`) used while designing a feature. Gitignored — not part of the committed documentation set.
