import 'package:due_day/core/observability/log_level.dart';

/// Extension point for observability backends.
///
/// The console sink is the only implementation today. A future
/// Crashlytics/Analytics sink implements this same contract and is added to
/// the sink list in `main.dart` — no call site elsewhere needs to change.
abstract class ObservabilitySink {
  void log({
    required LogLevel level,
    required String message,
    String? tag,
    Object? error,
    StackTrace? stackTrace,
    Map<String, Object?>? context,
  });

  void trackEvent(String name, {Map<String, Object?>? parameters});
}
