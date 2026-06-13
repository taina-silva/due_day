import 'package:due_day/core/navigation/go_router_refresh_stream.dart';
// Navigation Shell
import 'package:due_day/core/navigation/main_wrapper_page.dart';
import 'package:due_day/features/accounts/presentation/pages/accounts_page.dart';
import 'package:due_day/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:due_day/features/auth/presentation/bloc/auth_state.dart';
import 'package:due_day/features/auth/presentation/pages/login_page.dart';
import 'package:due_day/features/auth/presentation/pages/signup_page.dart';
import 'package:due_day/features/categories/presentation/pages/categories_page.dart';
import 'package:due_day/features/dashboard/presentation/pages/dashboard_page.dart';
import 'package:due_day/features/notifications/presentation/pages/notifications_page.dart';
import 'package:due_day/features/profile/presentation/pages/profile_page.dart';
import 'package:due_day/features/schedule/presentation/pages/schedule_page.dart';
// Pages
import 'package:due_day/features/splash/presentation/pages/splash_page.dart';
import 'package:due_day/features/transactions/presentation/pages/transaction_history_page.dart';
import 'package:due_day/features/transactions/presentation/pages/transactions_page.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>();
final GlobalKey<NavigatorState> _shellNavigatorHome = GlobalKey<NavigatorState>(
  debugLabel: 'home',
);
final GlobalKey<NavigatorState> _shellNavigatorTrans =
    GlobalKey<NavigatorState>(debugLabel: 'trans');
final GlobalKey<NavigatorState> _shellNavigatorAcc = GlobalKey<NavigatorState>(
  debugLabel: 'acc',
);
final GlobalKey<NavigatorState> _shellNavigatorCat = GlobalKey<NavigatorState>(
  debugLabel: 'cat',
);

/// Builds the app router wired to [authBloc] so redirects react to auth changes.
GoRouter createAppRouter(AuthBloc authBloc) {
  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/',
    refreshListenable: GoRouterRefreshStream(authBloc.stream),
    redirect: (context, state) {
      final authState = authBloc.state;
      final location = state.matchedLocation;

      final isInSplash = location == '/';
      final isInAuth = location == '/login' || location == '/signup';

      final isLoading = authState is AuthInitial || authState is AuthLoading;
      final isAuthenticated = authState is AuthAuthenticated;

      // While auth is resolving, always stay on splash
      if (isLoading) {
        // If user is on auth screen, stay there
        if (isInAuth) return null;

        return location == '/' ? null : '/';
      }

      // Auth resolved — leave splash
      if (isInSplash) {
        return isAuthenticated ? '/dashboard' : '/login';
      }

      // Authenticated users cannot visit auth screens
      if (isAuthenticated && isInAuth) {
        return '/dashboard';
      }

      // Unauthenticated users cannot visit protected screens
      if (!isAuthenticated && !isInAuth) {
        return '/login';
      }

      return null; // no redirect needed
    },
    routes: [
      GoRoute(path: '/', builder: (context, state) => const SplashPage()),
      GoRoute(path: '/login', builder: (context, state) => const LoginPage()),
      GoRoute(path: '/signup', builder: (context, state) => const SignUpPage()),
      GoRoute(
        path: '/profile',
        builder: (context, state) => const ProfilePage(),
      ),
      GoRoute(
        path: '/notifications',
        builder: (context, state) => const NotificationsPage(),
      ),

      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return MainWrapperPage(navigationShell: navigationShell);
        },
        branches: [
          // Tab 0: Home
          StatefulShellBranch(
            navigatorKey: _shellNavigatorHome,
            routes: [
              GoRoute(
                path: '/dashboard',
                builder: (context, state) => const DashboardPage(),
              ),
            ],
          ),

          // Tab 1: Transactions
          StatefulShellBranch(
            navigatorKey: _shellNavigatorTrans,
            routes: [
              GoRoute(
                path: '/transactions',
                builder: (context, state) => const TransactionsPage(),
                routes: [
                  GoRoute(
                    path: 'history',
                    builder: (context, state) => const TransactionHistoryPage(),
                  ),
                  GoRoute(
                    path: 'schedule',
                    builder: (context, state) => const SchedulePage(),
                  ),
                ],
              ),
            ],
          ),

          // Tab 2: Accounts
          StatefulShellBranch(
            navigatorKey: _shellNavigatorAcc,
            routes: [
              GoRoute(
                path: '/accounts',
                builder: (context, state) => const AccountsPage(),
              ),
            ],
          ),

          // Tab 3: Category
          StatefulShellBranch(
            navigatorKey: _shellNavigatorCat,
            routes: [
              GoRoute(
                path: '/categories',
                builder: (context, state) => CategoriesPage(
                  isSelectionMode: state.extra as bool? ?? false,
                ),
              ),
            ],
          ),
        ],
      ),
    ],
  );
}
