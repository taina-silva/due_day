# Feature Development Guide (feature_development.md)

This document provides a step-by-step developer guide to implementing new business features in the **DueDay** project.

---

## 📂 1. Feature Folder Structure

Each new feature must be placed inside the `lib/features/` directory and partitioned into Clean Architecture layers:

```
lib/features/my_feature/
├── domain/
│   ├── entities/
│   │   └── my_feature_entity.dart
│   ├── repositories/
│   │   └── my_feature_repository.dart
│   └── usecases/
│       └── do_feature_action.dart
│
├── data/
│   ├── models/
│   │   └── my_feature_model.dart
│   ├── datasources/
│   │   ├── my_feature_remote_data_source.dart
│   │   └── my_feature_local_data_source.dart
│   └── repositories/
│       └── my_feature_repository_impl.dart
│
└── presentation/
    ├── bloc/
    │   ├── my_feature_bloc.dart
    │   ├── my_feature_event.dart
    │   └── my_feature_state.dart
    ├── pages/
    │   └── my_feature_page.dart
    └── widgets/
        └── my_feature_card_widget.dart
```

---

## 🏗️ 2. Development Workflow

Follow this sequence to implement a feature cleanly. Each step links to the skill that owns its detailed pattern/template:

1.  **Domain:** entity → repository contract → use cases (`call(...)` returning `Future<Either<Failure, T>>`, see [create-usecase](../skills/create-usecase/SKILL.md)).
2.  **Data:** model ([create-model](../skills/create-model/SKILL.md)) → datasource ([create-datasource](../skills/create-datasource/SKILL.md)) → repository implementation ([create-repository](../skills/create-repository/SKILL.md)).
3.  **Presentation:** BLoC ([create-bloc](../skills/create-bloc/SKILL.md)) → page/widgets ([create-screen](../skills/create-screen/SKILL.md)).
4.  **Wiring:** register the feature module in `lib/core/injection/` — see [dependency_injection.md](../references/dependency_injection.md) for the pattern and lifetime rules.
5.  **Routing:** declare the `GoRoute` — see [add-route](../skills/add-route/SKILL.md).
6.  **Localization:** add keys to `app_en.arb`/`app_pt.arb` and run `fvm flutter gen-l10n` — see [localization.md](../references/localization.md).
7.  **Code generation:** run `build_runner` (commands in [coding_standards.md §6](coding_standards.md#-6-environment--code-generation)) whenever a `freezed`/`json_serializable` model changes.
8.  **Tests:** write Domain → Data → BLoC → Widget tests in that order, targeting 80% coverage — see [testing.md](testing.md).
