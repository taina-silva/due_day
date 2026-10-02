# DueDay

Personal **spending tracker** for Android and iOS. It answers *"how much did I spend this month, on what, vs last month?"*, using Nubank statement import as the main input, plus on-device bill reminders.

- **Product, scope, decisions, glossary:** [specs/product.md](specs/product.md). Read it before feature work.
- **Current phase:** MVP via changes `0001`–`0004` in [specs/changes/](specs/changes/). Don't refactor or polish code the active change doesn't require.

## Stack

Flutter `3.41.6` / Dart `3.11.4` (FVM) · `flutter_bloc` · `go_router` · `get_it` · `fpdart` + `equatable` · `freezed` + `json_serializable` · Firebase Auth + Firestore · Hive (notifications inbox) · `flutter_local_notifications` (no push/FCM) · `local_auth` + `flutter_secure_storage`.

## Core rules

- **Clean Architecture** `Presentation → Domain ← Data`. UI → BLoC → UseCase; repositories return `Either<Failure, T>`; no raw exceptions in UI.
- **KISS:** no aggregation collections or repositories; aggregate in use cases.
- **Files** `snake_case` with role suffixes (`_entity`, `_model`, `_repository_impl`, `_bloc`, `_page`, …).
- **UI:** `DueDayTheme` tokens only; `.w` / `.h` / `.sp` / `.fs` on every dimension; touch targets ≥ 44x44; WCAG AA.
- **Texts:** always `AppLocalizations` (`app_en.arb` + `app_pt.arb`).
- **English** for code, comments, logs, commits, and all docs. pt-BR only in `app_pt.arb`.

## Workflow (spec-driven)

Details: [specs/README.md](specs/README.md).

1. Behavior changes go through `specs/changes/NNNN-slug/`: [`/spec-propose`](.claude/skills/spec-propose/SKILL.md), then user approval, then [`/spec-apply`](.claude/skills/spec-apply/SKILL.md). Bug fixes use a lightweight change (proposal + tasks + regression test). Copy, visual-only, and typo fixes don't need one.
2. Code, specs, and docs change in the same commit.
3. Archiving merges the delta into `specs/capabilities/`.
4. `.claude/docs/` changes only when the *how* changes.
5. One source per topic: link, don't copy.
6. Review blocks on missing requirements or stale docs.

## Docs map

| Where | What |
| :--- | :--- |
| `specs/` | **What/why**: [product.md](specs/product.md), `capabilities/` (current behavior), `changes/` |
| [architecture.md](.claude/docs/architecture.md) | Layers, boundaries, Load/Action BLoC, layout, workflow |
| [coding_standards.md](.claude/docs/coding_standards.md) | Naming, error handling, imports, environment, checklist |
| [design_system.md](.claude/docs/design_system.md) | Tokens, typography, components, `AppMessenger` |
| [localization.md](.claude/docs/localization.md) | ARB catalogs and keys |
| [dependency_injection.md](.claude/docs/dependency_injection.md) | GetIt order and lifetimes |
| [firestore.md](.claude/docs/firestore.md) | Rules, queries, schema |
| [navigation.md](.claude/docs/navigation.md) | GoRouter, guards, tabs |
| [notifications.md](.claude/docs/notifications.md) | Local reminders and Hive inbox |
| [observability.md](.claude/docs/observability.md) | Logging and error capture |
| [testing.md](.claude/docs/testing.md) | Test patterns and coverage |
| `.claude/docs/setup/` | [Firebase setup](.claude/docs/setup/firebase_setup.md), [security hardening](.claude/docs/setup/security_hardening.md) |

**Skills** (`.claude/skills/`): `spec-propose`, `spec-apply`; recipes `create-usecase`, `create-model`, `create-datasource`, `create-repository`, `create-firestore-query`, `create-bloc`, `create-screen`, `add-route`, `add-notification`; `add-test-coverage-existing-feature`, `refactor-feature`, `debug-feature`, `review-feature`.

**Agents** (`.claude/agents/`): `flutter-architect`, `flutter-developer`, `firebase-engineer`, `code-reviewer`, `debugger`, `testing-architect`, `testing-engineer`, `testing-reviewer`.
