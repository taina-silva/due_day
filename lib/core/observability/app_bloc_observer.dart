import 'package:due_day/core/observability/observability_service.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Global [BlocObserver] that reports bloc lifecycle and errors through
/// [ObservabilityService].
///
/// Deliberately does not override `onChange`/`onEvent`: those carry full
/// state/event objects, which in DueDay include account balances and
/// transaction amounts. Logging their `toString()` on every change would
/// leak financial data into logs, even local ones. Only lifecycle markers
/// and explicit errors are recorded here.
class AppBlocObserver extends BlocObserver {
  final ObservabilityService observability;

  AppBlocObserver({required this.observability});

  @override
  void onCreate(BlocBase<dynamic> bloc) {
    super.onCreate(bloc);
    observability.debug('${bloc.runtimeType} created', tag: 'bloc');
  }

  @override
  void onError(BlocBase<dynamic> bloc, Object error, StackTrace stackTrace) {
    observability.error(
      '${bloc.runtimeType} error',
      tag: 'bloc',
      error: error,
      stackTrace: stackTrace,
    );
    super.onError(bloc, error, stackTrace);
  }

  @override
  void onClose(BlocBase<dynamic> bloc) {
    super.onClose(bloc);
    observability.debug('${bloc.runtimeType} closed', tag: 'bloc');
  }
}
