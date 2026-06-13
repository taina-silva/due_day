import 'dart:async';

import 'package:due_day/core/services/security_service.dart';
import 'package:due_day/core/settings/settings_event.dart';
import 'package:due_day/core/settings/settings_state.dart';
import 'package:due_day/features/auth/domain/usecases/auth_usecases.dart';
import 'package:due_day/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:due_day/features/auth/presentation/bloc/auth_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class SettingsBloc extends Bloc<SettingsEvent, SettingsState> {
  final UpdateUser updateUser;
  final AuthBloc authBloc;
  final SecurityService securityService;
  late final StreamSubscription _authSubscription;

  SettingsBloc({
    required this.updateUser,
    required this.authBloc,
    required this.securityService,
  }) : super(const SettingsState()) {
    on<ChangeLanguageEvent>(_onChangeLanguage);
    on<ChangeThemeEvent>(_onChangeTheme);
    on<LoadSettingsFromUserEvent>(_onLoadSettingsFromUser);
    on<TogglePushNotificationsEvent>(_onTogglePushNotifications);
    on<ToggleBiometricsEvent>(_onToggleBiometrics);
    on<LoadBiometricsSettingsEvent>(_onLoadBiometricsSettings);

    _authSubscription = authBloc.stream.listen((authState) {
      if (authState is AuthAuthenticated) {
        add(
          LoadSettingsFromUserEvent(
            themePreference: authState.user.themePreference,
          ),
        );
      }
    });

    // Initial checks
    final authState = authBloc.state;
    if (authState is AuthAuthenticated) {
      add(
        LoadSettingsFromUserEvent(
          themePreference: authState.user.themePreference,
        ),
      );
    }
    
    add(LoadBiometricsSettingsEvent());
  }

  void _onTogglePushNotifications(
    TogglePushNotificationsEvent event,
    Emitter<SettingsState> emit,
  ) {
    emit(state.copyWith(pushNotificationsEnabled: event.enabled));
  }

  void _onChangeLanguage(
    ChangeLanguageEvent event,
    Emitter<SettingsState> emit,
  ) {
    emit(state.copyWith(languageCode: event.languageCode));
  }

  Future<void> _onChangeTheme(
    ChangeThemeEvent event,
    Emitter<SettingsState> emit,
  ) async {
    emit(state.copyWith(themeMode: event.themeMode));

    // Persistência no Firestore
    final authState = authBloc.state;
    if (authState is AuthAuthenticated) {
      final updatedUser = authState.user.copyWith(
        themePreference: event.themeMode.name,
      );
      await updateUser(updatedUser);
    }
  }

  void _onLoadSettingsFromUser(
    LoadSettingsFromUserEvent event,
    Emitter<SettingsState> emit,
  ) {
    ThemeMode? themeMode;
    if (event.themePreference != null) {
      themeMode = ThemeMode.values.firstWhere(
        (e) => e.name == event.themePreference,
        orElse: () => ThemeMode.system,
      );
    }

    emit(
      state.copyWith(
        themeMode: themeMode,
        languageCode: event.languagePreference,
      ),
    );
  }

  Future<void> _onToggleBiometrics(
    ToggleBiometricsEvent event,
    Emitter<SettingsState> emit,
  ) async {
    await securityService.setBiometricsEnabled(event.enabled);
    emit(state.copyWith(isBiometricsEnabled: event.enabled));
  }

  Future<void> _onLoadBiometricsSettings(
    LoadBiometricsSettingsEvent event,
    Emitter<SettingsState> emit,
  ) async {
    final isEnabled = await securityService.isBiometricsEnabled();
    emit(state.copyWith(isBiometricsEnabled: isEnabled));
  }

  @override
  Future<void> close() {
    _authSubscription.cancel();
    return super.close();
  }
}
