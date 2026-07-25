# Dependency Injection Registry (dependency_injection.md)

This reference maps the Service Locator setup (`GetIt` injection container) and the lifetime management of global services, repositories, use cases, and BLoCs in the **DueDay** project.

---

## ⚙️ 1. Initialization Order (`injection_container.dart`)

Dependency injection (DI) is initialized synchronously during app startup in `lib/main.dart` via `await di.init()`. One exception precedes it: `ObservabilityService` is registered manually in `main.dart` (`sl.registerSingleton<ObservabilityService>(...)`), before `Firebase.initializeApp`/`di.init()` run, so bootstrap failures are captured too. `injection_container.dart` never registers it — every other service/repository just resolves `sl<ObservabilityService>()`. See [observability.md](../docs/observability.md).

The remaining registration steps run inside `di.init()`, ordered as follows:

1.  **Core Services Registration:** Setup of system-level platform managers (e.g. notifications and security services).
2.  **Auth Injection Module (`initAuth`):** Sets up core user models and authentication layers.
3.  **Settings Initialization:** Configures the global `SettingsBloc` (manages Light/Dark themes and locales).
4.  **Feature Injection Modules:**
    - `initAccounts()`
    - `initCategories()`
    - `initTransactions()`
    - `initNotifications()`
    - `initSchedule()`
    - `initDashboard()`

---

## 🗂️ 2. Core Service Registrations

These services run throughout the app's lifetime. They are registered under `/lib/core/services/` or as third-party singletons:

| Service Type | GetIt Lifetime | Registration Signature |
| :--- | :--- | :--- |
| `ObservabilityService` | `registerSingleton` (in `main.dart`, before `di.init()`) | Logging, error capture, and event tracking. Fans out to `ObservabilitySink`s (console today). |
| `NotificationService` | `registerLazySingleton` | Handles time zones, channel declarations, and local payment alerts. |
| `FlutterSecureStorage`| `registerLazySingleton` | Platform keychain for storing credentials securely. |
| `LocalAuthentication` | `registerLazySingleton` | Platform biometric scanner (TouchID/FaceID/Fingerprint). |
| `SecurityService` | `registerLazySingleton` | Wraps biometric checking and secure credentials storage. Depends on `ObservabilityService`. |
| `SettingsBloc` | `registerSingleton` | App-wide theme and localization configurations. |

---

## 📦 3. Feature Registrations Pattern

Each feature directory (e.g., `lib/features/accounts`) implements a modular injection routine. `accounts` predates the Load Bloc/Action Bloc split (see [architecture.md](../docs/architecture.md#load-bloc--action-bloc-separation-standard-for-streamed-features)) and still registers one combined bloc:

```dart
final sl = GetIt.instance;

void initAccounts() {
  // 1. Presentation Layer (Factory)
  sl.registerFactory(() => AccountBloc(
        addAccount: sl(),
        getAccounts: sl(),
        updateAccount: sl(),
        deleteAccount: sl(),
      ));

  // 2. Domain Layer (Lazy Singletons)
  sl.registerLazySingleton(() => AddAccount(sl()));
  sl.registerLazySingleton(() => GetAccounts(sl()));
  sl.registerLazySingleton(() => UpdateAccount(sl()));
  sl.registerLazySingleton(() => DeleteAccount(sl()));

  // 3. Data Layer (Lazy Singletons)
  sl.registerLazySingleton<AccountRepository>(
    () => AccountRepositoryImpl(remoteDataSource: sl(), observability: sl()),
  );
  sl.registerLazySingleton<AccountRemoteDataSource>(
    () => AccountRemoteDataSourceImpl(firestore: sl()),
  );
}
```

New features that follow the Load Bloc/Action Bloc standard register **two** bloc factories instead of one — `categories` is the reference:

```dart
void initCategories() {
  // 1. Presentation Layer (Factory) — two blocs, split by concern
  sl.registerFactory(() => CategoryLoadBloc(getCategories: sl()));
  sl.registerFactory(
    () => CategoryActionBloc(
      addCategory: sl(),
      updateCategory: sl(),
      deleteCategory: sl(),
    ),
  );

  // 2. Domain Layer (Lazy Singletons)
  sl.registerLazySingleton(() => AddCategory(sl()));
  sl.registerLazySingleton(() => UpdateCategory(sl()));
  sl.registerLazySingleton(() => DeleteCategory(sl()));
  sl.registerLazySingleton(() => GetCategories(sl()));

  // 3. Data Layer (Lazy Singletons)
  sl.registerLazySingleton<CategoryRepository>(
    () => CategoryRepositoryImpl(remoteDataSource: sl(), observability: sl()),
  );
  sl.registerLazySingleton<CategoryRemoteDataSource>(
    () => CategoryRemoteDataSourceImpl(firestore: sl(), firebaseAuth: sl()),
  );
}
```

Both blocs are then provided in `main.dart`'s root `MultiBlocProvider`, exactly like any other feature bloc:
```dart
BlocProvider(create: (_) => di.sl<CategoryLoadBloc>()),
BlocProvider(create: (_) => di.sl<CategoryActionBloc>()),
```
Every feature bloc in DueDay is provided globally at the app root (none are scoped locally to a single route) — the Action Bloc is no exception, even though today only its own feature's bottom sheet reads it.

### Lifetime Rules
- **BLoCs (`registerFactory`):** Blocs must be registered as factories so that when a page enters or exits, a fresh state-management instance is initialized (unless the BLoC is globally scoped like `AuthBloc` or `SettingsBloc`). This applies to both the Load Bloc and the Action Bloc when a feature is split.
- **Use Cases & Repositories (`registerLazySingleton`):** These classes contain stateless logic, so they are shared as single instances across features to optimize memory usage.
- **Repositories & `ObservabilityService`:** Every repository implementation takes an `ObservabilityService observability` constructor param (resolved via `sl()`) and logs in its catch blocks. See [observability.md](../docs/observability.md).
