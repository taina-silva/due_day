import 'package:due_day/core/injection/account_injection.dart';
import 'package:due_day/core/injection/auth_injection.dart';
import 'package:due_day/core/injection/category_injection.dart';
import 'package:due_day/core/injection/dashboard_injection.dart';
import 'package:due_day/core/injection/notifications_injection.dart';
import 'package:due_day/core/injection/schedule_injection.dart';
import 'package:due_day/core/injection/transaction_injection.dart';
import 'package:due_day/core/services/notification_service.dart';
import 'package:due_day/core/services/security_service.dart';
import 'package:due_day/core/settings/settings_bloc.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get_it/get_it.dart';
import 'package:local_auth/local_auth.dart';

final sl = GetIt.instance; // sl stands for Service Locator

Future<void> init() async {
  // --- Core & Services ---
  sl.registerLazySingleton<NotificationService>(() => NotificationService());
  // Inicializamos na hora
  await sl<NotificationService>().init();

  // --- Security ---
  sl.registerLazySingleton<FlutterSecureStorage>(() => const FlutterSecureStorage());
  sl.registerLazySingleton<LocalAuthentication>(() => LocalAuthentication());
  sl.registerLazySingleton<SecurityService>(
    () => SecurityServiceImpl(
      secureStorage: sl(),
      localAuth: sl(),
    ),
  );

  // Features
  initAuth();

  sl.registerSingleton<SettingsBloc>(
    SettingsBloc(
      updateUser: sl(),
      authBloc: sl(),
      securityService: sl(),
    ),
  );

  // Accounts
  initAccounts();

  // Categories
  initCategories();

  // Transactions
  initTransactions();

  // Notifications
  initNotifications();

  // Schedule
  initSchedule();

  // Dashboard
  initDashboard();
}
