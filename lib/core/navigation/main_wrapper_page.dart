import 'package:due_day/core/design_system/components/navbar/floating_bottom_nav.dart';
import 'package:due_day/core/injection/injection_container.dart';
import 'package:due_day/core/navigation/biometric_lock_overlay.dart';
import 'package:due_day/core/services/security_service.dart';
import 'package:due_day/core/settings/settings_bloc.dart';
import 'package:due_day/core/settings/settings_state.dart';
import 'package:due_day/features/accounts/presentation/bloc/account_bloc.dart';
import 'package:due_day/features/accounts/presentation/bloc/account_event.dart';
import 'package:due_day/features/categories/presentation/bloc/category_bloc.dart';
import 'package:due_day/features/categories/presentation/bloc/category_event.dart';
import 'package:due_day/features/transactions/presentation/bloc/transaction_bloc.dart';
import 'package:due_day/features/transactions/presentation/bloc/transaction_event.dart';
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

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    // Dispatch initial load events to listen to Firestore streams
    context.read<AccountBloc>().add(LoadAccounts());
    context.read<CategoryBloc>().add(LoadCategories());
    context.read<TransactionBloc>().add(const LoadTransactions());

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
    if (state == AppLifecycleState.resumed) {
      final settingsBloc = context.read<SettingsBloc>();
      if (settingsBloc.state.isBiometricsEnabled) {
        setState(() {
          _isLocked = true;
        });
        _authenticate();
      }
    }
  }

  Future<void> _authenticate() async {
    final securityService = sl<SecurityService>();
    final bool canAuth = await securityService.canAuthenticate();
    if (!canAuth) {
      // Dispositivo não suporta ou não tem cadastro biométrico ativo
      setState(() {
        _isLocked = false;
      });
      return;
    }

    final bool authenticated = await securityService.authenticate();
    if (authenticated) {
      setState(() {
        _isLocked = false;
      });
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
                  child: BiometricLockOverlay(onAuthenticate: _authenticate),
                ),
            ],
          ),
        );
      },
    );
  }
}
