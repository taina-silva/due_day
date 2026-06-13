import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

abstract class SettingsEvent extends Equatable {
  const SettingsEvent();

  @override
  List<Object?> get props => [];
}

class ChangeLanguageEvent extends SettingsEvent {
  final String languageCode;

  const ChangeLanguageEvent(this.languageCode);

  @override
  List<Object?> get props => [languageCode];
}

class ChangeThemeEvent extends SettingsEvent {
  final ThemeMode themeMode;

  const ChangeThemeEvent(this.themeMode);

  @override
  List<Object?> get props => [themeMode];
}

class LoadSettingsFromUserEvent extends SettingsEvent {
  final String? themePreference;
  final String? languagePreference;

  const LoadSettingsFromUserEvent({
    this.themePreference,
    this.languagePreference,
  });

  @override
  List<Object?> get props => [themePreference, languagePreference];
}

class TogglePushNotificationsEvent extends SettingsEvent {
  final bool enabled;

  const TogglePushNotificationsEvent(this.enabled);

  @override
  List<Object?> get props => [enabled];
}

class ToggleBiometricsEvent extends SettingsEvent {
  final bool enabled;

  const ToggleBiometricsEvent(this.enabled);

  @override
  List<Object?> get props => [enabled];
}

class LoadBiometricsSettingsEvent extends SettingsEvent {}
