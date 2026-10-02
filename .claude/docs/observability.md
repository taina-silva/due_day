# Observability

Logging, error capture, and event tracking live in `lib/core/observability/`. Today the only backend is a console sink.

## Structure

- `ObservabilityService` (+ `Impl`): what every layer depends on. Fans out to a list of `ObservabilitySink`s.
- `ConsoleObservabilitySink`: the only sink today.
- `AppBlocObserver`: global, logs only bloc *type* names (create/close/error).
- Registered in `main.dart` **before** Firebase/DI init, so bootstrap failures are captured too.

## Levels

| Level | Use for |
| :--- | :--- |
| `debug` | Verbose flow tracing (dev only). |
| `info` | Expected milestones. |
| `warning` | Handled/recovered failures. |
| `error` | Failures returned as `Failure` (repository catch blocks). |
| `fatal` | Uncaught errors (`main.dart`: `runZonedGuarded`, `FlutterError.onError`, `PlatformDispatcher.onError`). |

`trackEvent(name, parameters:)` is for analytics-style events (e.g. `transaction_created`).

## Rules

- Always pass `tag` (feature name: `auth`, `transactions`, …).
- **Never log entities, states, or amounts.** This is financial data. Log short messages plus the error.
- Only **repositories** log, inside every catch block, before mapping to `Failure`. DataSources don't (avoids double logging).

```dart
} on ServerException catch (e) {
  observability.error('signInWithEmail failed', tag: 'auth', error: e, stackTrace: StackTrace.current);
  return Left(_mapException(e));
}
```

## Tests

Use a real no-op instance instead of a mock: `ObservabilityServiceImpl(sinks: const [])`.

## Adding a backend later

Implement `ObservabilitySink` (e.g. Crashlytics) and add it to the `sinks` list in `main.dart`. No call site changes.
