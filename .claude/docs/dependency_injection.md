# Dependency Injection

GetIt service locator (`sl`), set up in `lib/core/injection/`.

## Init order

1. `main.dart` registers `ObservabilityService` **before** Firebase and `di.init()` (captures bootstrap errors). See [observability.md](observability.md).
2. `di.init()` (`injection_container.dart`): core services → Hive → `initAuth` → `initProfile` → settings → `initAccounts`, `initCategories`, `initTransactions`, `initStatementImport`, `initNotifications`, `initSchedule`, `initDashboard`.

## Core services

| Service | Lifetime |
| :--- | :--- |
| `ObservabilityService` | `registerSingleton` (in `main.dart`) |
| `NotificationService`, `SecurityService`, `FlutterSecureStorage`, `LocalAuthentication` | `registerLazySingleton` |
| `SettingsBloc` | `registerSingleton` |

## Lifetimes

- **BLoCs:** `registerFactory` (both Load and Action blocs).
- **Use cases, repositories, datasources:** `registerLazySingleton` (stateless).
- Every repository receives `observability: sl()`.

## Feature module

One `*_injection.dart` per feature. Reference: `categories`.

```dart
void initCategories() {
  sl.registerFactory(() => CategoryLoadBloc(getCategories: sl()));
  sl.registerFactory(() => CategoryActionBloc(addCategory: sl(), updateCategory: sl(), deleteCategory: sl()));

  sl.registerLazySingleton(() => GetCategories(sl()));
  sl.registerLazySingleton(() => AddCategory(sl()));
  // ...

  sl.registerLazySingleton<CategoryRepository>(() => CategoryRepositoryImpl(remoteDataSource: sl(), observability: sl()));
  sl.registerLazySingleton<CategoryRemoteDataSource>(() => CategoryRemoteDataSourceImpl(firestore: sl(), firebaseAuth: sl()));
}
```

All feature blocs are provided globally in `main.dart`'s root `MultiBlocProvider`:

```dart
BlocProvider(create: (_) => di.sl<CategoryLoadBloc>()),
BlocProvider(create: (_) => di.sl<CategoryActionBloc>()),
```
