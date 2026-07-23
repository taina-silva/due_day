import 'package:due_day/core/observability/log_level.dart';
import 'package:due_day/core/observability/observability_sink.dart';

/// Single entry point the rest of the app depends on for logging, error
/// reporting and flow/event tracking. It never talks to a backend directly —
/// it fans out to whatever [ObservabilitySink]s it was built with, so
/// swapping/adding a backend (Crashlytics, Analytics, Sentry, ...) never
/// requires touching a call site, only the sink list passed in at bootstrap.
abstract class ObservabilityService {
  void debug(String message, {String? tag, Map<String, Object?>? context});

  void info(String message, {String? tag, Map<String, Object?>? context});

  void warning(
    String message, {
    String? tag,
    Object? error,
    StackTrace? stackTrace,
    Map<String, Object?>? context,
  });

  void error(
    String message, {
    String? tag,
    Object? error,
    StackTrace? stackTrace,
    Map<String, Object?>? context,
  });

  void fatal(
    String message, {
    String? tag,
    Object? error,
    StackTrace? stackTrace,
    Map<String, Object?>? context,
  });

  void trackEvent(String name, {Map<String, Object?>? parameters});
}

class ObservabilityServiceImpl implements ObservabilityService {
  final List<ObservabilitySink> sinks;

  ObservabilityServiceImpl({required this.sinks});

  @override
  void debug(String message, {String? tag, Map<String, Object?>? context}) {
    _log(LogLevel.debug, message, tag: tag, context: context);
  }

  @override
  void info(String message, {String? tag, Map<String, Object?>? context}) {
    _log(LogLevel.info, message, tag: tag, context: context);
  }

  @override
  void warning(
    String message, {
    String? tag,
    Object? error,
    StackTrace? stackTrace,
    Map<String, Object?>? context,
  }) {
    _log(
      LogLevel.warning,
      message,
      tag: tag,
      error: error,
      stackTrace: stackTrace,
      context: context,
    );
  }

  @override
  void error(
    String message, {
    String? tag,
    Object? error,
    StackTrace? stackTrace,
    Map<String, Object?>? context,
  }) {
    _log(
      LogLevel.error,
      message,
      tag: tag,
      error: error,
      stackTrace: stackTrace,
      context: context,
    );
  }

  @override
  void fatal(
    String message, {
    String? tag,
    Object? error,
    StackTrace? stackTrace,
    Map<String, Object?>? context,
  }) {
    _log(
      LogLevel.fatal,
      message,
      tag: tag,
      error: error,
      stackTrace: stackTrace,
      context: context,
    );
  }

  @override
  void trackEvent(String name, {Map<String, Object?>? parameters}) {
    for (final sink in sinks) {
      sink.trackEvent(name, parameters: parameters);
    }
  }

  void _log(
    LogLevel level,
    String message, {
    String? tag,
    Object? error,
    StackTrace? stackTrace,
    Map<String, Object?>? context,
  }) {
    for (final sink in sinks) {
      sink.log(
        level: level,
        message: message,
        tag: tag,
        error: error,
        stackTrace: stackTrace,
        context: context,
      );
    }
  }
}
