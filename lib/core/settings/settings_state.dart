import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

class SettingsState extends Equatable {
  final String languageCode;
  final ThemeMode themeMode;
  final bool pushNotificationsEnabled;
  final bool isBiometricsEnabled;

  const SettingsState({
    this.languageCode = 'pt',
    this.themeMode = ThemeMode.system,
    this.pushNotificationsEnabled = true,
    this.isBiometricsEnabled = false,
  });

  SettingsState copyWith({
    String? languageCode,
    ThemeMode? themeMode,
    bool? pushNotificationsEnabled,
    bool? isBiometricsEnabled,
  }) {
    return SettingsState(
      languageCode: languageCode ?? this.languageCode,
      themeMode: themeMode ?? this.themeMode,
      pushNotificationsEnabled:
          pushNotificationsEnabled ?? this.pushNotificationsEnabled,
      isBiometricsEnabled: isBiometricsEnabled ?? this.isBiometricsEnabled,
    );
  }

  @override
  List<Object?> get props => [
        languageCode,
        themeMode,
        pushNotificationsEnabled,
        isBiometricsEnabled,
      ];
}
