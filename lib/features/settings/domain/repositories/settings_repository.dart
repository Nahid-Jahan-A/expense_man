import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/app_settings.dart';

/// Abstract repository for settings operations
abstract class SettingsRepository {
  Future<Either<Failure, AppSettings>> getSettings();
  Future<Either<Failure, void>> saveSettings(AppSettings settings);
  Future<Either<Failure, void>> updateThemeMode(String themeMode);
  Future<Either<Failure, void>> updateLanguage(String languageCode);
  Future<Either<Failure, void>> updateCurrency(String currencyCode);
  Future<Either<Failure, void>> setFirstLaunchComplete();
  Future<Either<Failure, void>> updateLastBackupDate(DateTime date);
}
