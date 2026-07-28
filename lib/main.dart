import 'dart:async';

import 'package:due_day/core/design_system/theme/app_theme.dart';
import 'package:due_day/core/injection/injection_container.dart' as di;
import 'package:due_day/core/l10n/app_localizations.dart';
import 'package:due_day/core/navigation/app_router.dart';
import 'package:due_day/core/observability/app_bloc_observer.dart';
import 'package:due_day/core/observability/observability_service.dart';
import 'package:due_day/core/observability/sinks/console_observability_sink.dart';
import 'package:due_day/core/settings/settings_bloc.dart';
import 'package:due_day/core/settings/settings_state.dart';
import 'package:due_day/features/accounts/presentation/bloc/account_action_bloc.dart';
import 'package:due_day/features/accounts/presentation/bloc/account_load_bloc.dart';
import 'package:due_day/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:due_day/features/auth/presentation/bloc/auth_event.dart';
import 'package:due_day/features/categories/presentation/bloc/category_action_bloc.dart';
import 'package:due_day/features/categories/presentation/bloc/category_load_bloc.dart';
import 'package:due_day/features/dashboard/presentation/bloc/dashboard_bloc.dart';
import 'package:due_day/features/notifications/presentation/bloc/notifications_action_bloc.dart';
import 'package:due_day/features/notifications/presentation/bloc/notifications_load_bloc.dart';
import 'package:due_day/features/notifications/presentation/bloc/notifications_load_event.dart';
import 'package:due_day/features/transactions/presentation/bloc/transaction_action_bloc.dart';
import 'package:due_day/features/transactions/presentation/bloc/transaction_load_bloc.dart';
import 'package:due_day/firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_sign_in/google_sign_in.dart';

void main() {
  runZonedGuarded(
    () async {
      WidgetsFlutterBinding.ensureInitialized();

      // Registered manually (not via injection_container.dart) so it exists
      // before Firebase/DI bootstrap and can capture failures from t=0.
      final observability = ObservabilityServiceImpl(
        sinks: [ConsoleObservabilitySink()],
      );
      di.sl.registerSingleton<ObservabilityService>(observability);

      FlutterError.onError = (details) {
        observability.fatal(
          'Uncaught Flutter framework error',
          tag: 'flutter',
          error: details.exception,
          stackTrace: details.stack,
        );
        FlutterError.presentError(details);
      };
      PlatformDispatcher.instance.onError = (error, stack) {
        observability.fatal(
          'Uncaught platform error',
          tag: 'platform',
          error: error,
          stackTrace: stack,
        );
        return true;
      };
      Bloc.observer = AppBlocObserver(observability: observability);

      // Initialize Firebase
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );

      // Initialize Google Sign In
      await GoogleSignIn.instance.initialize();

      // Initializes Dependency Injection
      await di.init();

      runApp(const DueDayApp());
    },
    (error, stack) {
      di.sl<ObservabilityService>().fatal(
        'Uncaught async error',
        tag: 'zone',
        error: error,
        stackTrace: stack,
      );
    },
  );
}

class DueDayApp extends StatefulWidget {
  const DueDayApp({super.key});

  @override
  State<DueDayApp> createState() => _DueDayAppState();
}

class _DueDayAppState extends State<DueDayApp> {
  late final AuthBloc _authBloc;
  late final GoRouter _router;

  @override
  void initState() {
    super.initState();
    _authBloc = di.sl<AuthBloc>()..add(AuthCheckRequested());
    _router = createAppRouter(_authBloc);
  }

  @override
  void dispose() {
    _authBloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider.value(value: _authBloc),
        BlocProvider(create: (_) => di.sl<SettingsBloc>()),
        BlocProvider(create: (_) => di.sl<AccountLoadBloc>()),
        BlocProvider(create: (_) => di.sl<AccountActionBloc>()),
        BlocProvider(create: (_) => di.sl<CategoryLoadBloc>()),
        BlocProvider(create: (_) => di.sl<CategoryActionBloc>()),
        BlocProvider(create: (_) => di.sl<TransactionLoadBloc>()),
        BlocProvider(create: (_) => di.sl<TransactionActionBloc>()),
        BlocProvider(create: (_) => di.sl<DashboardBloc>()),
        BlocProvider(
          create: (_) =>
              di.sl<NotificationsLoadBloc>()..add(LoadNotifications()),
        ),
        BlocProvider(create: (_) => di.sl<NotificationsActionBloc>()),
      ],
      child: BlocBuilder<SettingsBloc, SettingsState>(
        builder: (context, state) {
          return MaterialApp.router(
            title: 'DueDay',
            debugShowCheckedModeBanner: false,
            routerConfig: _router,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: state.themeMode,
            locale: Locale(state.languageCode),
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            builder: (context, child) {
              return GestureDetector(
                onTap: () => FocusScope.of(context).unfocus(),
                behavior: HitTestBehavior.opaque,
                child: child,
              );
            },
          );
        },
      ),
    );
  }
}
