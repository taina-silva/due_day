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

Follow this sequence to implement a feature cleanly:

### Step 1: Define Domain Layer
1.  **Entity:** Create `domain/entities/my_feature_entity.dart`. Declare fields, add a `const` constructor, and extend `Equatable` to support structural comparison.
2.  **Repository Contract:** Create `domain/repositories/my_feature_repository.dart`. Write abstract methods returning `Either<Failure, T>`.
3.  **Use Cases:** Create focused use cases in `domain/usecases/`. E.g., `do_feature_action.dart` must have a callable `call(...)` method:
    ```dart
    class DoFeatureAction {
      final MyFeatureRepository repository;
      DoFeatureAction(this.repository);

      Future<Either<Failure, SuccessType>> call(Params params) async {
        return repository.executeAction(params);
      }
    }
    ```

### Step 2: Implement Data Layer
1.  **Model:** Create `data/models/my_feature_model.dart`. Use `freezed` and `@freezed` to write models with serialization support. Provide mapping helpers:
    - `factory MyFeatureModel.fromEntity(MyFeatureEntity entity)`
    - `MyFeatureEntity toEntity()`
2.  **DataSource:** Create interfaces and implementation files in `data/datasources/`. Fetch raw data, e.g., from Firestore, throwing `ServerException` on errors.
3.  **Repository Implementation:** Create `data/repositories/my_feature_repository_impl.dart`. Implement the domain contract interface, catch exceptions, and return `Left(Failure)` or `Right(Data)`.

### Step 3: Implement Presentation Layer
1.  **BLoC:** Design Events (User Interactions) and States (UI Screen representation) in `presentation/bloc/`. Use `MyFeatureBloc` to consume UseCases.
2.  **Pages/Widgets:** Build screens under `presentation/pages/` using `DueDayTheme` tokens, localizations, and `NumExtension` for responsiveness. Consome bloc state using `BlocBuilder` or `BlocConsumer`.

---

## 💉 3. Dependency Injection Registration

Features must register their services inside the `lib/core/injection/` directory:
1.  Create `lib/core/injection/my_feature_injection.dart`.
2.  Define an `initMyFeature()` function registering the BLoC, UseCases, Repositories, and DataSources:
    ```dart
    final sl = GetIt.instance;

    void initMyFeature() {
      // Presentation (BLoCs)
      sl.registerFactory(() => MyFeatureBloc(doFeatureAction: sl()));

      // UseCases
      sl.registerLazySingleton(() => DoFeatureAction(sl()));

      // Repository
      sl.registerLazySingleton<MyFeatureRepository>(
        () => MyFeatureRepositoryImpl(remoteDataSource: sl()),
      );

      // DataSources
      sl.registerLazySingleton<MyFeatureRemoteDataSource>(
        () => MyFeatureRemoteDataSourceImpl(firestore: sl()),
      );
    }
    ```
3.  Call `initMyFeature()` inside the central setup file `lib/core/injection/injection_container.dart`.

---

## 🔀 4. Route Registration

Integrate the new screen into the global router file `lib/core/navigation/app_router.dart`:
1.  Determine if the page is placed inside the bottom navigation shell (`StatefulShellRoute`) or acts as a standalone route.
2.  Declare the route path using `GoRoute` and configure the page builder:
    ```dart
    GoRoute(
      path: '/my-feature',
      name: 'my_feature',
      builder: (context, state) => const MyFeaturePage(),
    )
    ```

---

## 🌍 5. String Localizations

1.  Add needed labels to the translations catalog:
    - `/lib/core/l10n/app_en.arb`
    - `/lib/core/l10n/app_pt.arb`
2.  Run the code generator:
    ```bash
    fvm flutter gen-l10n
    ```
3.  Implement translations in your widgets using `AppLocalizations.of(context)`.

---

## ⚡ 6. Code Generation Checklist

Run code generation to resolve Freezed models or JSON serializers:
```bash
# Run one-time build
fvm flutter pub run build_runner build --delete-conflicting-outputs

# Watch files and rebuild on save
fvm flutter pub run build_runner watch --delete-conflicting-outputs
```
Ensure no compilation or analyzer warnings remain before merging the new feature.

---

## 🧪 7. Feature Testing Strategy (4-Phase Cycle)

When implementing a feature, you must implement the corresponding tests according to the following cycle:

```
[Phase 1: Domain & Tests] ➔ [Phase 2: Data & Mocks] ➔ [Phase 3: BLoC & bloc_test] ➔ [Phase 4: UI & Widget Tests]
```

### Phase 1: Domain & Unit Tests
- **UseCase Tests:** Create unit tests under `test/features/my_feature/domain/usecases/my_usecase_test.dart` to verify logic.
- Assert that successful executions return a `Right` type and error states return a `Left` type wrapping a subclass of `Failure`.

### Phase 2: Data & Repository Tests (with Mocks)
- **Repository Tests:** Create repository implementation tests under `test/features/my_feature/data/repositories/my_repository_impl_test.dart`.
- Mock remote/local DataSources using mockito or mocktail to verify error handling and conversion from data Models to Domain Entities.

### Phase 3: BLoC & `bloc_test`
- **BLoC Tests:** Create BLoC tests under `test/features/my_feature/presentation/bloc/my_bloc_test.dart` using the `bloc_test` package:
  ```dart
  blocTest<MyBloc, MyState>(
    'emits [MyLoading, MyLoaded] on success',
    build: () {
      when(() => mockUseCase(any())).thenAnswer((_) async => Right(testData));
      return MyBloc(useCase: mockUseCase);
    },
    act: (bloc) => bloc.add(const FetchEvent()),
    expect: () => [
      MyLoading(),
      MyLoaded(testData),
    ],
  );
  ```
- **Resource Cleanup:** Always close stream controllers or manual subscriptions created in `setUp` during `tearDown` to avoid memory leaks.

### Phase 4: UI & Widget Tests
- **Widget Smoke Tests:** Verify screen elements render correctly and respond to user clicks.
- Wrap tested widgets inside a mock environment using `MultiBlocProvider`, a localized `MaterialApp` with `DueDayTheme`, and `AppLocalizations`.
- **Localization:** Search elements and assert labels using translation keys from `AppLocalizations` instead of hardcoded strings.

### 📈 7.5. Code Coverage Standards
Every new or modified file must reach a minimum of **80% code coverage** (excluding generated files like `.freezed.dart` or `.g.dart`).

```bash
# Run tests and collect coverage info
fvm flutter test --coverage

# Generate visual HTML report
genhtml coverage/lcov.info -o coverage/html
```
Open `coverage/html/index.html` in a browser to review coverage details.
