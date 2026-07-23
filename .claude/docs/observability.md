# Observability (observability.md)

This document describes how logging, error capture, and flow/event tracking are handled in **DueDay**, via `lib/core/observability/`. Today the only backend is a console sink used for local debugging; the module is designed so a real backend (Crashlytics, Analytics, Sentry, ...) can be added later without touching any call site.

---

## 🧱 1. Architecture

```
lib/core/observability/
├── log_level.dart                    # LogLevel enum (debug/info/warning/error/fatal)
├── observability_sink.dart           # ObservabilitySink — the backend contract
├── observability_service.dart        # ObservabilityService (+ Impl) — what the app depends on
├── app_bloc_observer.dart            # Global BlocObserver wired in main.dart
└── sinks/
    └── console_observability_sink.dart
```

`ObservabilityService` is what every layer depends on (BLoCs, repositories, `core/services/*`). It never talks to a backend directly — it fans out to whatever `ObservabilitySink`s it was constructed with:

```dart
final observability = ObservabilityServiceImpl(sinks: [ConsoleObservabilitySink()]);
```

This mirrors the `SecurityService` convention (abstract interface + `Impl`, `registerLazySingleton`), not `NotificationService`'s bare-class shape, because it needs to be swapped for a no-op double in tests.

Registration is special-cased in `main.dart` (not `injection_container.dart`): it's constructed and registered into `sl` **before** `Firebase.initializeApp`/`di.init()` run, so bootstrap failures are captured too. `injection_container.dart` only resolves `sl<ObservabilityService>()`.

---

## 📊 2. Log Levels & Usage

| Level     | When to use                                                                                               |
| --------- | --------------------------------------------------------------------------------------------------------- |
| `debug`   | Bloc lifecycle, verbose flow tracing — noisy, dev-only signal.                                            |
| `info`    | Notable but expected flow milestones.                                                                     |
| `warning` | Something failed but was handled/recovered silently (e.g. `SecurityServiceImpl.setBiometricsEnabled`).    |
| `error`   | An operation failed and surfaced as a `Failure` to the caller (the repository catch-block pattern below). |
| `fatal`   | Uncaught errors — Flutter framework errors, platform errors, async zone errors (`main.dart`).             |

`trackEvent(name, {parameters})` exists separately for flow/analytics-style events (e.g. `transaction_created`), independent of log levels — it maps directly onto `FirebaseAnalytics.logEvent` once that sink exists.

**`tag`** is the feature name (`auth`, `accounts`, `categories`, `transactions`, `notifications`, `bloc`, `security`, `flutter`, `platform`, `zone`) — always pass it so logs can be filtered by area.

**Never log full entities/states.** DueDay handles financial data (balances, transaction amounts). Pass short messages and structured `context`/`error` values — never `state.toString()` or a full entity dump. This is why `AppBlocObserver` only logs bloc _type_ names on `onCreate`/`onClose`/`onError`, and never overrides `onChange`/`onEvent`.

---

## 🗂️ 3. Repository Instrumentation Pattern

Every `*_repository_impl.dart` catch block logs before mapping the exception to a `Failure`, since that's the single point where `ServerException`/`CacheException` messages — already required by `coding_standards.md` to be technical English strings "for debugging/Crashlytics/Sentry logs" — are available:

```dart
} on ServerException catch (e) {
  observability.error('signInWithEmail failed', tag: 'auth', error: e, stackTrace: StackTrace.current);
  return Left(_mapException(e));
} catch (e, stackTrace) {
  observability.error('signInWithEmail unexpected failure', tag: 'auth', error: e, stackTrace: stackTrace);
  return Left(GenericFailure(e.toString()));
}
```

Only the repository layer logs — not the data sources underneath. Data sources already wrap platform exceptions (`FirebaseAuthException`, etc.) into `ServerException`/`CacheException` with the original message/code preserved, so logging at the repository catch block captures the same information without double-logging the same failure.

When adding a new repository, inject `ObservabilityService observability` in its constructor and follow this pattern for every catch block.

---

## 🌐 4. Global Error Capture

`main.dart` wraps the whole app in `runZonedGuarded`, and sets `FlutterError.onError` / `PlatformDispatcher.instance.onError` to route uncaught errors through `observability.fatal(...)` before `Firebase.initializeApp`/`di.init()` run. `Bloc.observer = AppBlocObserver(...)` reports bloc lifecycle events and `onError` globally.

---

## 🧪 5. Testing

`ObservabilityServiceImpl(sinks: const [])` is a real, no-op instance (empty sink list) — pass it directly in repository/service tests instead of mocking `ObservabilityService` with mocktail. It's a void-returning cross-cutting dependency injected into nearly every repository, so a null-object avoids boilerplate stubbing across ~46 catch blocks.

---

## 🔌 6. Adding a Real Backend Later (Crashlytics / Analytics / Sentry)

No call site changes are needed. To wire in a real backend:

1. Add the package to `pubspec.yaml` (e.g. `firebase_crashlytics`, `firebase_analytics`).
2. Implement `ObservabilitySink` (e.g. `CrashlyticsObservabilitySink`), mapping `error`/`fatal` levels to `FirebaseCrashlytics.instance.recordError(...)` and `trackEvent` to `FirebaseAnalytics.instance.logEvent(...)`.
3. Add the new sink to the `sinks: [...]` list passed to `ObservabilityServiceImpl` in `main.dart`.

That's it — every `observability.error(...)`/`trackEvent(...)` call across the app starts reaching the new backend automatically.
