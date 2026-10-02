# Architecture

Clean Architecture + BLoC. Product behavior lives in [`specs/`](../../specs/README.md); this file covers code structure only.

## Layers

`Presentation → Domain ← Data`

| Layer | Contains | May import |
| :--- | :--- | :--- |
| **Domain** | Entities (`Equatable`, `const`, `copyWith`), repository contracts, use cases (`call(...)` → `Future<Either<Failure, T>>`), failures | Domain, pure-Dart core. No Flutter, no Firebase. |
| **Data** | Models (`freezed`, `fromEntity`/`toEntity`), datasources (throw `ServerException`/`CacheException`), repository implementations (catch → `Either`) | Domain, Data, Core |
| **Presentation** | BLoCs, pages, widgets, `utils/` (failure → l10n) | Presentation, Domain, Core |

### Cross-feature

A feature may use another feature's **domain** (use cases, entities) only — never its data or presentation. Shared UI goes in `lib/core/design_system/`. Check:

```bash
grep -rhoE "package:due_day/features/[a-z_]+/[a-z]+" lib/features/<feature> | sort -u
```

Any `/data` or `/presentation` hit from another feature is a violation.

## Load / Action BLoC split

Default for any feature with a live list stream **and** add/update/delete:

- `XLoadBloc`: `LoadX` → `XInitial` / `XLoading` / `XLoaded` / `XError`. Driven only by the stream.
- `XActionBloc`: `Add/Update/DeleteXEvent` → `XActionInitial` / `XActionInProgress` / `XActionSuccess` / `XActionError`. Never holds the list.

**Why:** one combined bloc leaks action states to every screen that only reads the list, which then goes blank. Reference: `categories`. Template: [create-bloc](../skills/create-bloc/SKILL.md). A single bloc is fine only when there is no list stream.

## Layout

```
lib/
├── main.dart
├── core/          # design_system, errors, injection, l10n, navigation, observability, services, settings, utils
└── features/<feature>/
    ├── domain/        # entities, repositories, usecases, errors
    ├── data/          # models, datasources, repositories
    └── presentation/  # bloc, pages, widgets, utils
```

## Workflow for a feature or task

1. Domain: entity → contract → use case ([create-usecase](../skills/create-usecase/SKILL.md))
2. Data: model → datasource → repository ([create-model](../skills/create-model/SKILL.md), [create-datasource](../skills/create-datasource/SKILL.md), [create-repository](../skills/create-repository/SKILL.md))
3. Presentation: bloc → screen ([create-bloc](../skills/create-bloc/SKILL.md), [create-screen](../skills/create-screen/SKILL.md))
4. DI ([dependency_injection.md](dependency_injection.md)) · route ([add-route](../skills/add-route/SKILL.md)) · l10n ([localization.md](localization.md)) · `build_runner`
5. Tests: Domain → Data → BLoC → Widget ([testing.md](testing.md))

## Rules

- **KISS:** no aggregation collections or repositories. Aggregate in a domain use case fed by existing use cases (e.g. `GetDashboardSummary`).
- UI never touches Firestore, Auth, storage, datasources, or repositories.
- Use cases don't call each other; orchestrate in the BLoC or in a dedicated orchestrating use case.
- No `try/catch` for Firebase errors in UI; repositories return `Either`.
- **Bottom sheets with mutating actions** never `pop()` right after dispatching. Listen to the Action Bloc: pop on success; on error, `AppMessenger.showError` and keep the sheet open.
- Load and Action failures use different fallback texts ([coding_standards.md](coding_standards.md#error-handling)).
- SOLID: one responsibility per class; depend on abstractions; DI via GetIt.
