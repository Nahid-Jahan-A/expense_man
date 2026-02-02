import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/app_settings.dart';
import '../../../../core/constants/enums.dart';

/// Base class for settings states
abstract class SettingsState extends Equatable {
  const SettingsState();

  @override
  List<Object?> get props => [];
}

/// Initial state
class SettingsInitial extends SettingsState {
  const SettingsInitial();
}

/// Loading state
class SettingsLoading extends SettingsState {
  const SettingsLoading();
}

/// Loaded state with settings data
class SettingsLoaded extends SettingsState {
  final AppSettings settings;

  const SettingsLoaded(this.settings);

  /// Get current theme mode
  ThemeMode get themeMode {
    switch (settings.themeMode) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      default:
        return ThemeMode.system;
    }
  }

  /// Get current locale
  Locale get locale => Locale(settings.languageCode);

  /// Get current currency
  Currency get currency => Currency.fromCode(settings.currencyCode);

  /// Check if first launch
  bool get isFirstLaunch => settings.isFirstLaunch;

  SettingsLoaded copyWith({AppSettings? settings}) {
    return SettingsLoaded(settings ?? this.settings);
  }

  @override
  List<Object?> get props => [settings];
}

/// Error state
class SettingsError extends SettingsState {
  final Failure failure;

  const SettingsError(this.failure);

  /// Get the error message
  String get message => failure.message;

  /// Get localized error message
  String getLocalizedMessage(String locale) => failure.getLocalizedMessage(locale);

  @override
  List<Object?> get props => [failure];
}
