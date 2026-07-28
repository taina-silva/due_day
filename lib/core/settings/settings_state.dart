import 'package:due_day/core/services/security_service.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

class SettingsState extends Equatable {
  final String languageCode;
  final ThemeMode themeMode;
  final bool pushNotificationsEnabled;
  final bool isBiometricsEnabled;
  final bool isTogglingBiometrics;
  final BiometricAuthResult? biometricsToggleError;

  const SettingsState({
    this.languageCode = 'pt',
    this.themeMode = ThemeMode.system,
    this.pushNotificationsEnabled = true,
    this.isBiometricsEnabled = false,
    this.isTogglingBiometrics = false,
    this.biometricsToggleError,
  });

  SettingsState copyWith({
    String? languageCode,
    ThemeMode? themeMode,
    bool? pushNotificationsEnabled,
    bool? isBiometricsEnabled,
    bool? isTogglingBiometrics,
    BiometricAuthResult? biometricsToggleError,
    bool clearBiometricsToggleError = false,
  }) {
    return SettingsState(
      languageCode: languageCode ?? this.languageCode,
      themeMode: themeMode ?? this.themeMode,
      pushNotificationsEnabled:
          pushNotificationsEnabled ?? this.pushNotificationsEnabled,
      isBiometricsEnabled: isBiometricsEnabled ?? this.isBiometricsEnabled,
      isTogglingBiometrics: isTogglingBiometrics ?? this.isTogglingBiometrics,
      biometricsToggleError: clearBiometricsToggleError
          ? null
          : (biometricsToggleError ?? this.biometricsToggleError),
    );
  }

  @override
  List<Object?> get props => [
    languageCode,
    themeMode,
    pushNotificationsEnabled,
    isBiometricsEnabled,
    isTogglingBiometrics,
    biometricsToggleError,
  ];
}
