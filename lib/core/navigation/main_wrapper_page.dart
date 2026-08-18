import 'package:due_day/core/design_system/components/navbar/floating_bottom_nav.dart';
import 'package:due_day/core/injection/injection_container.dart';
import 'package:due_day/core/l10n/app_localizations.dart';
import 'package:due_day/core/navigation/biometric_lock_overlay.dart';
import 'package:due_day/core/services/security_service.dart';
import 'package:due_day/core/settings/settings_bloc.dart';
import 'package:due_day/core/settings/settings_state.dart';
import 'package:due_day/features/accounts/presentation/bloc/account_load_bloc.dart';
import 'package:due_day/features/accounts/presentation/bloc/account_load_event.dart';
import 'package:due_day/features/categories/presentation/bloc/category_load_bloc.dart';
import 'package:due_day/features/categories/presentation/bloc/category_load_event.dart';
import 'package:due_day/features/notifications/presentation/bloc/notifications_load_bloc.dart';
import 'package:due_day/features/notifications/presentation/bloc/notifications_load_event.dart';
import 'package:due_day/features/transactions/presentation/bloc/transaction_load_bloc.dart';
import 'package:due_day/features/transactions/presentation/bloc/transaction_load_event.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class MainWrapperPage extends StatefulWidget {
  final StatefulNavigationShell navigationShell;

  const MainWrapperPage({required this.navigationShell, super.key});

  @override
  State<MainWrapperPage> createState() => _MainWrapperPageState();
}

class _MainWrapperPageState extends State<MainWrapperPage>
    with WidgetsBindingObserver {
  bool _isLocked = false;
  bool _isAuthenticating = false;
  BiometricAuthResult? _lastAuthResult;
  AppLifecycleState? _lastLifecycleState;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    // Dispatch initial load events to (re)subscribe to the signed-in user's
    // streams. These blocs live for the whole app session, so re-firing
    // here on every mount (i.e. every fresh login) is what keeps them from
    // serving stale data left over from a previous account.
    context.read<AccountLoadBloc>().add(LoadAccounts());
    context.read<CategoryLoadBloc>().add(LoadCategories());
    context.read<TransactionLoadBloc>().add(const LoadTransactions());
    context.read<NotificationsLoadBloc>().add(LoadNotifications());

    _checkInitialLock();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  Future<void> _checkInitialLock() async {
    final settingsBloc = context.read<SettingsBloc>();
    if (settingsBloc.state.isBiometricsEnabled) {
      setState(() {
        _isLocked = true;
      });
      _authenticate();
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final AppLifecycleState? previousState = _lastLifecycleState;
    _lastLifecycleState = state;

    if (state != AppLifecycleState.resumed ||
        previousState != AppLifecycleState.paused) {
      return;
    }

    final settingsBloc = context.read<SettingsBloc>();
    if (settingsBloc.state.isBiometricsEnabled &&
        !settingsBloc.state.isTogglingBiometrics) {
      setState(() {
        _isLocked = true;
      });
      _authenticate();
    }
  }

  Future<void> _authenticate() async {
    if (_isAuthenticating) return;
    setState(() {
      _isAuthenticating = true;
      _lastAuthResult = null;
    });

    try {
      final securityService = sl<SecurityService>();
      final bool canAuth = await securityService.canAuthenticate();
      if (!canAuth) {
        // No biometrics available on the device: stay locked instead of
        // granting access without authentication.
        return;
      }

      final result = await securityService.authenticate();
      if (!mounted) return;
      if (result == BiometricAuthResult.success) {
        setState(() {
          _isLocked = false;
        });
      } else {
        setState(() {
          _lastAuthResult = result;
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isAuthenticating = false;
        });
      } else {
        _isAuthenticating = false;
      }
    }
  }

  String? _errorMessageFor(BiometricAuthResult? result) {
    if (result == null) return null;
    final l10n = AppLocalizations.of(context);
    switch (result) {
      case BiometricAuthResult.lockedOut:
        return l10n.profileBiometricsLockedOut;
      case BiometricAuthResult.notEnrolled:
        return l10n.profileBiometricsNotEnrolled;
      case BiometricAuthResult.notAvailable:
        return l10n.profileBiometricsNotSupported;
      case BiometricAuthResult.success:
      case BiometricAuthResult.canceled:
      case BiometricAuthResult.error:
        return l10n.profileBiometricsAuthFailed;
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SettingsBloc, SettingsState>(
      builder: (context, state) {
        return Scaffold(
          body: Stack(
            children: [
              widget.navigationShell,
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: FloatingBottomNav(
                  currentIndex: widget.navigationShell.currentIndex,
                  onTap: (index) {
                    widget.navigationShell.goBranch(
                      index,
                      initialLocation:
                          index == widget.navigationShell.currentIndex,
                    );
                  },
                ),
              ),
              if (_isLocked && state.isBiometricsEnabled)
                Positioned.fill(
                  child: BiometricLockOverlay(
                    onAuthenticate: _authenticate,
                    isAuthenticating: _isAuthenticating,
                    errorMessage: _errorMessageFor(_lastAuthResult),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}
