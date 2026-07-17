# Dependency Injection Registry (dependency_injection.md)

This reference maps the Service Locator setup (`GetIt` injection container) and the lifetime management of global services, repositories, use cases, and BLoCs in the **DueDay** project.

---

## ⚙️ 1. Initialization Order (`injection_container.dart`)

Dependency injection (DI) is initialized synchronously during app startup in `lib/main.dart` via `await di.init()`. The registration steps are ordered as follows:

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
| `NotificationService` | `registerLazySingleton` | Handles time zones, channel declarations, and local payment alerts. |
| `FlutterSecureStorage`| `registerLazySingleton` | Platform keychain for storing credentials securely. |
| `LocalAuthentication` | `registerLazySingleton` | Platform biometric scanner (TouchID/FaceID/Fingerprint). |
| `SecurityService` | `registerLazySingleton` | Wraps biometric checking and secure credentials storage. |
| `SettingsBloc` | `registerSingleton` | App-wide theme and localization configurations. |

---

## 📦 3. Feature Registrations Pattern

Each feature directory (e.g., `lib/features/accounts`) implements a modular injection routine:

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
    () => AccountRepositoryImpl(remoteDataSource: sl()),
  );
  sl.registerLazySingleton<AccountRemoteDataSource>(
    () => AccountRemoteDataSourceImpl(firestore: sl()),
  );
}
```

### Lifetime Rules
- **BLoCs (`registerFactory`):** Blocs must be registered as factories so that when a page enters or exits, a fresh state-management instance is initialized (unless the BLoC is globally scoped like `AuthBloc` or `SettingsBloc`).
- **Use Cases & Repositories (`registerLazySingleton`):** These classes contain stateless logic, so they are shared as single instances across features to optimize memory usage.
