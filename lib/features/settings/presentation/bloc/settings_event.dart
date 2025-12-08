import 'package:equatable/equatable.dart';

/// Base class for settings events
abstract class SettingsEvent extends Equatable {
  const SettingsEvent();

  @override
  List<Object?> get props => [];
}

/// Event to load settings
class LoadSettings extends SettingsEvent {
  const LoadSettings();
}

/// Event to change theme mode
class ChangeThemeMode extends SettingsEvent {
  final String themeMode;

  const ChangeThemeMode(this.themeMode);

  @override
  List<Object?> get props => [themeMode];
}

/// Event to change language
class ChangeLanguage extends SettingsEvent {
  final String languageCode;

  const ChangeLanguage(this.languageCode);

  @override
  List<Object?> get props => [languageCode];
}

/// Event to change currency
class ChangeCurrency extends SettingsEvent {
  final String currencyCode;

  const ChangeCurrency(this.currencyCode);

  @override
  List<Object?> get props => [currencyCode];
}

/// Event to complete first launch
class CompleteFirstLaunch extends SettingsEvent {
  const CompleteFirstLaunch();
}

/// Event to update last backup date
class UpdateBackupDate extends SettingsEvent {
  final DateTime date;

  const UpdateBackupDate(this.date);

  @override
  List<Object?> get props => [date];
}
