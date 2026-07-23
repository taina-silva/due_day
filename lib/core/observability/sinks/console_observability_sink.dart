import 'dart:developer' as developer;

import 'package:due_day/core/observability/log_level.dart';
import 'package:due_day/core/observability/observability_sink.dart';

/// Prints structured logs via `dart:developer log`, so they show up in
/// DevTools/IDE consoles with level, name (tag) and error/stackTrace
/// attached, instead of being flattened into plain `print` text.
class ConsoleObservabilitySink implements ObservabilitySink {
  @override
  void log({
    required LogLevel level,
    required String message,
    String? tag,
    Object? error,
    StackTrace? stackTrace,
    Map<String, Object?>? context,
  }) {
    final buffer = StringBuffer(message);
    if (context != null && context.isNotEmpty) {
      buffer.write(' | context: $context');
    }
    developer.log(
      buffer.toString(),
      name: tag ?? 'DueDay',
      level: _levelValue(level),
      error: error,
      stackTrace: stackTrace,
    );
  }

  @override
  void trackEvent(String name, {Map<String, Object?>? parameters}) {
    developer.log(
      'event: $name${parameters != null ? ' | $parameters' : ''}',
      name: 'analytics',
    );
  }

  int _levelValue(LogLevel level) {
    switch (level) {
      case LogLevel.debug:
        return 500;
      case LogLevel.info:
        return 800;
      case LogLevel.warning:
        return 900;
      case LogLevel.error:
        return 1000;
      case LogLevel.fatal:
        return 1200;
    }
  }
}
