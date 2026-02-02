import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/app_settings.dart';
import '../../domain/repositories/settings_repository.dart';
import '../datasources/settings_local_datasource.dart';
import '../models/settings_model.dart';

/// Implementation of settings repository
class SettingsRepositoryImpl implements SettingsRepository {
  final SettingsLocalDataSource _localDataSource;

  SettingsRepositoryImpl(this._localDataSource);

  @override
  Future<Either<Failure, AppSettings>> getSettings() async {
    try {
      final model = await _localDataSource.getSettings();
      return Right(model.toEntity());
    } catch (e) {
      return Left(CacheFailure.read(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> saveSettings(AppSettings settings) async {
    try {
      final model = SettingsModel.fromEntity(settings);
      await _localDataSource.saveSettings(model);
      return const Right(null);
    } catch (e) {
      return Left(CacheFailure.write(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> updateThemeMode(String themeMode) async {
    try {
      await _localDataSource.updateThemeMode(themeMode);
      return const Right(null);
    } catch (e) {
      return Left(CacheFailure.write(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> updateLanguage(String languageCode) async {
    try {
      await _localDataSource.updateLanguage(languageCode);
      return const Right(null);
    } catch (e) {
      return Left(CacheFailure.write(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> updateCurrency(String currencyCode) async {
    try {
      await _localDataSource.updateCurrency(currencyCode);
      return const Right(null);
    } catch (e) {
      return Left(CacheFailure.write(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> setFirstLaunchComplete() async {
    try {
      await _localDataSource.setFirstLaunchComplete();
      return const Right(null);
    } catch (e) {
      return Left(CacheFailure.write(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> updateLastBackupDate(DateTime date) async {
    try {
      await _localDataSource.updateLastBackupDate(date);
      return const Right(null);
    } catch (e) {
      return Left(CacheFailure.write(e.toString()));
    }
  }
}
