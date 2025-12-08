import 'package:hive/hive.dart';
import '../../domain/entities/app_settings.dart';

part 'settings_model.g.dart';

@HiveType(typeId: 2)
class SettingsModel extends HiveObject {
  @HiveField(0)
  final String themeMode;

  @HiveField(1)
  final String languageCode;

  @HiveField(2)
  final String currencyCode;

  @HiveField(3)
  final bool isFirstLaunch;

  @HiveField(4)
  final DateTime? lastBackupDate;

  SettingsModel({
    this.themeMode = 'system',
    this.languageCode = 'en',
    this.currencyCode = 'BDT',
    this.isFirstLaunch = true,
    this.lastBackupDate,
  });

  /// Convert from entity
  factory SettingsModel.fromEntity(AppSettings settings) {
    return SettingsModel(
      themeMode: settings.themeMode,
      languageCode: settings.languageCode,
      currencyCode: settings.currencyCode,
      isFirstLaunch: settings.isFirstLaunch,
      lastBackupDate: settings.lastBackupDate,
    );
  }

  /// Convert to entity
  AppSettings toEntity() {
    return AppSettings(
      themeMode: themeMode,
      languageCode: languageCode,
      currencyCode: currencyCode,
      isFirstLaunch: isFirstLaunch,
      lastBackupDate: lastBackupDate,
    );
  }

  /// Convert from JSON
  factory SettingsModel.fromJson(Map<String, dynamic> json) {
    return SettingsModel(
      themeMode: json['themeMode'] as String? ?? 'system',
      languageCode: json['languageCode'] as String? ?? 'en',
      currencyCode: json['currencyCode'] as String? ?? 'BDT',
      isFirstLaunch: json['isFirstLaunch'] as bool? ?? true,
      lastBackupDate: json['lastBackupDate'] != null
          ? DateTime.parse(json['lastBackupDate'] as String)
          : null,
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'themeMode': themeMode,
      'languageCode': languageCode,
      'currencyCode': currencyCode,
      'isFirstLaunch': isFirstLaunch,
      'lastBackupDate': lastBackupDate?.toIso8601String(),
    };
  }

  SettingsModel copyWith({
    String? themeMode,
    String? languageCode,
    String? currencyCode,
    bool? isFirstLaunch,
    DateTime? lastBackupDate,
  }) {
    return SettingsModel(
      themeMode: themeMode ?? this.themeMode,
      languageCode: languageCode ?? this.languageCode,
      currencyCode: currencyCode ?? this.currencyCode,
      isFirstLaunch: isFirstLaunch ?? this.isFirstLaunch,
      lastBackupDate: lastBackupDate ?? this.lastBackupDate,
    );
  }
}
