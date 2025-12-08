import 'package:hive/hive.dart';
import '../models/settings_model.dart';

/// Abstract class for settings local data source
abstract class SettingsLocalDataSource {
  Future<SettingsModel> getSettings();
  Future<void> saveSettings(SettingsModel settings);
  Future<void> updateThemeMode(String themeMode);
  Future<void> updateLanguage(String languageCode);
  Future<void> updateCurrency(String currencyCode);
  Future<void> setFirstLaunchComplete();
  Future<void> updateLastBackupDate(DateTime date);
}

/// Implementation of settings local data source using Hive
class SettingsLocalDataSourceImpl implements SettingsLocalDataSource {
  final Box _box;
  static const String _settingsKey = 'app_settings';

  SettingsLocalDataSourceImpl(this._box);

  @override
  Future<SettingsModel> getSettings() async {
    try {
      final data = _box.get(_settingsKey);
      if (data != null && data is Map) {
        return SettingsModel.fromJson(Map<String, dynamic>.from(data));
      }
      // Return default settings if not found
      final defaultSettings = SettingsModel();
      await saveSettings(defaultSettings);
      return defaultSettings;
    } catch (e) {
      return SettingsModel();
    }
  }

  @override
  Future<void> saveSettings(SettingsModel settings) async {
    await _box.put(_settingsKey, settings.toJson());
  }

  @override
  Future<void> updateThemeMode(String themeMode) async {
    final settings = await getSettings();
    final updatedSettings = settings.copyWith(themeMode: themeMode);
    await saveSettings(updatedSettings);
  }

  @override
  Future<void> updateLanguage(String languageCode) async {
    final settings = await getSettings();
    final updatedSettings = settings.copyWith(languageCode: languageCode);
    await saveSettings(updatedSettings);
  }

  @override
  Future<void> updateCurrency(String currencyCode) async {
    final settings = await getSettings();
    final updatedSettings = settings.copyWith(currencyCode: currencyCode);
    await saveSettings(updatedSettings);
  }

  @override
  Future<void> setFirstLaunchComplete() async {
    final settings = await getSettings();
    final updatedSettings = settings.copyWith(isFirstLaunch: false);
    await saveSettings(updatedSettings);
  }

  @override
  Future<void> updateLastBackupDate(DateTime date) async {
    final settings = await getSettings();
    final updatedSettings = settings.copyWith(lastBackupDate: date);
    await saveSettings(updatedSettings);
  }
}
