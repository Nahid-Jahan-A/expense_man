import 'package:equatable/equatable.dart';

/// App settings entity
class AppSettings extends Equatable {
  final String themeMode; // 'light', 'dark', 'system'
  final String languageCode; // 'en', 'bn'
  final String currencyCode; // 'BDT', 'USD', etc.
  final bool isFirstLaunch;
  final DateTime? lastBackupDate;

  const AppSettings({
    this.themeMode = 'system',
    this.languageCode = 'en',
    this.currencyCode = 'BDT',
    this.isFirstLaunch = true,
    this.lastBackupDate,
  });

  /// Create default settings
  factory AppSettings.defaultSettings() {
    return const AppSettings(
      themeMode: 'system',
      languageCode: 'en',
      currencyCode: 'BDT',
      isFirstLaunch: true,
    );
  }

  /// Create a copy with updated values
  AppSettings copyWith({
    String? themeMode,
    String? languageCode,
    String? currencyCode,
    bool? isFirstLaunch,
    DateTime? lastBackupDate,
  }) {
    return AppSettings(
      themeMode: themeMode ?? this.themeMode,
      languageCode: languageCode ?? this.languageCode,
      currencyCode: currencyCode ?? this.currencyCode,
      isFirstLaunch: isFirstLaunch ?? this.isFirstLaunch,
      lastBackupDate: lastBackupDate ?? this.lastBackupDate,
    );
  }

  @override
  List<Object?> get props => [
        themeMode,
        languageCode,
        currencyCode,
        isFirstLaunch,
        lastBackupDate,
      ];
}
