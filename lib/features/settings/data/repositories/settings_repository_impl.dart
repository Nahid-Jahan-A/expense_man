import 'package:dartz/dartz.dart';
import '../../domain/entities/app_settings.dart';
import '../../domain/repositories/settings_repository.dart';
import '../datasources/settings_local_datasource.dart';
import '../models/settings_model.dart';

/// Implementation of settings repository
class SettingsRepositoryImpl implements SettingsRepository {
  final SettingsLocalDataSource _localDataSource;

  SettingsRepositoryImpl(this._localDataSource);

  @override
  Future<Either<String, AppSettings>> getSettings() async {
    try {
      final model = await _localDataSource.getSettings();
      return Right(model.toEntity());
    } catch (e) {
      return Left('Failed to get settings: ${e.toString()}');
    }
  }

  @override
  Future<Either<String, void>> saveSettings(AppSettings settings) async {
    try {
      final model = SettingsModel.fromEntity(settings);
      await _localDataSource.saveSettings(model);
      return const Right(null);
    } catch (e) {
      return Left('Failed to save settings: ${e.toString()}');
    }
  }

  @override
  Future<Either<String, void>> updateThemeMode(String themeMode) async {
    try {
      await _localDataSource.updateThemeMode(themeMode);
      return const Right(null);
    } catch (e) {
      return Left('Failed to update theme: ${e.toString()}');
    }
  }

  @override
  Future<Either<String, void>> updateLanguage(String languageCode) async {
    try {
      await _localDataSource.updateLanguage(languageCode);
      return const Right(null);
    } catch (e) {
      return Left('Failed to update language: ${e.toString()}');
    }
  }

  @override
  Future<Either<String, void>> updateCurrency(String currencyCode) async {
    try {
      await _localDataSource.updateCurrency(currencyCode);
      return const Right(null);
    } catch (e) {
      return Left('Failed to update currency: ${e.toString()}');
    }
  }

  @override
  Future<Either<String, void>> setFirstLaunchComplete() async {
    try {
      await _localDataSource.setFirstLaunchComplete();
      return const Right(null);
    } catch (e) {
      return Left('Failed to update first launch: ${e.toString()}');
    }
  }

  @override
  Future<Either<String, void>> updateLastBackupDate(DateTime date) async {
    try {
      await _localDataSource.updateLastBackupDate(date);
      return const Right(null);
    } catch (e) {
      return Left('Failed to update backup date: ${e.toString()}');
    }
  }
}
