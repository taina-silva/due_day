# Standard Procedure: Create Feature (create_feature.md)

This guide describes how to create and register a new business feature from scratch in the **DueDay** application.

---

## 🛠️ Step-by-Step Feature Creation Recipe

### Phase 1: Directory Setup
1.  Navigate to `lib/features/`.
2.  Create the feature root folder in `snake_case` (e.g., `my_feature`).
3.  Create the Clean Architecture layer folders:
    - `domain/entities/`, `domain/repositories/`, `domain/usecases/`
    - `data/models/`, `data/datasources/`, `data/repositories/`
    - `presentation/bloc/`, `presentation/pages/`, `presentation/widgets/`

### Phase 2: Domain Logic
1.  **Create the Entity:** Write `domain/entities/my_feature_entity.dart`. Extend `Equatable` and add a `const` constructor.
2.  **Create the Repository Contract:** Write `domain/repositories/my_feature_repository.dart` declaring the abstract class and required methods returning `Future<Either<Failure, T>>`.
3.  **Create Use Cases:** Write focused UseCase classes under `domain/usecases/` implementing the `call(...)` signature.

### Phase 3: Infrastructure Setup
1.  **Create the Model:** Write `data/models/my_feature_model.dart` using `freezed` and `@freezed` to add JSON serialization. Make sure to define `fromEntity` and `toEntity` conversions.
2.  **Create the DataSource:** Write `data/datasources/my_feature_remote_data_source.dart` with Firestore logic, throwing `ServerException` on operations errors.
3.  **Implement the Repository:** Write `data/repositories/my_feature_repository_impl.dart` to implement the Domain interface, catch DataSource exceptions, and return failures as `Left(Failure)`.

### Phase 4: State & Interface Setup
1.  **Create BLoC:** Design the Event, State, and BLoC classes in `presentation/bloc/`. Make sure events and states extend `Equatable`.
2.  **Create Page & Widgets:** Write the screen inside `presentation/pages/` consuming states with `BlocBuilder`. Ensure layouts use `DueDayTheme` tokens, localizations, and `.w`/`.h`/`.sp`/`.fs` scaling.

### Phase 5: System Registrations
1.  **Dependency Injection:** Create `lib/core/injection/my_feature_injection.dart` and register the components in `injection_container.dart` (BLoCs as factories, others as lazy singletons).
2.  **Routing:** Register the page in `lib/core/navigation/app_router.dart`.
3.  **Localization:** Define translations in `app_en.arb` and `app_pt.arb`, then run:
    ```bash
    fvm flutter gen-l10n
    ```
4.  **Code Generation:** Run the build runner to generate the Freezed models:
    ```bash
    fvm flutter pub run build_runner build --delete-conflicting-outputs
    ```
5.  **Run Tests:** Write and run unit tests for UseCases and BLoCs.
