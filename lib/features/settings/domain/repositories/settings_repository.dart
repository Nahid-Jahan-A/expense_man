import 'package:dartz/dartz.dart';
import '../entities/app_settings.dart';

/// Abstract repository for settings operations
abstract class SettingsRepository {
  Future<Either<String, AppSettings>> getSettings();
  Future<Either<String, void>> saveSettings(AppSettings settings);
  Future<Either<String, void>> updateThemeMode(String themeMode);
  Future<Either<String, void>> updateLanguage(String languageCode);
  Future<Either<String, void>> updateCurrency(String currencyCode);
  Future<Either<String, void>> setFirstLaunchComplete();
  Future<Either<String, void>> updateLastBackupDate(DateTime date);
}
