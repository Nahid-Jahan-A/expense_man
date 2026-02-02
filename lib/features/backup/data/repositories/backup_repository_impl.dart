import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../expense/data/datasources/expense_local_datasource.dart';
import '../../../category/data/datasources/category_local_datasource.dart';
import '../../../settings/data/datasources/settings_local_datasource.dart';
import '../../domain/entities/backup_data.dart';
import '../../domain/repositories/backup_repository.dart';
import '../models/backup_model.dart';
import '../services/backup_file_service.dart';

/// Implementation of backup repository
class BackupRepositoryImpl implements BackupRepository {
  final ExpenseLocalDataSource _expenseDataSource;
  final CategoryLocalDataSource _categoryDataSource;
  final SettingsLocalDataSource _settingsDataSource;
  final BackupFileService _backupFileService;

  BackupRepositoryImpl({
    required ExpenseLocalDataSource expenseDataSource,
    required CategoryLocalDataSource categoryDataSource,
    required SettingsLocalDataSource settingsDataSource,
    required BackupFileService backupFileService,
  })  : _expenseDataSource = expenseDataSource,
        _categoryDataSource = categoryDataSource,
        _settingsDataSource = settingsDataSource,
        _backupFileService = backupFileService;

  @override
  Future<Either<Failure, String>> createBackup() async {
    try {
      final backupData = await _createBackupData();
      final filePath = await _backupFileService.saveBackup(backupData);

      // Update last backup date
      await _settingsDataSource.updateLastBackupDate(DateTime.now());

      return Right(filePath);
    } catch (e) {
      return Left(BackupFailure.creation(e.toString()));
    }
  }

  @override
  Future<Either<Failure, String>> exportBackup() async {
    try {
      final backupData = await _createBackupData();
      final filePath = await _backupFileService.exportBackupWithShare(backupData);

      // Update last backup date
      await _settingsDataSource.updateLastBackupDate(DateTime.now());

      return Right(filePath);
    } catch (e) {
      return Left(BackupFailure.creation(e.toString()));
    }
  }

  @override
  Future<Either<Failure, ImportResult>> importBackup(ImportMode mode) async {
    try {
      // Let user pick a file
      final filePath = await _backupFileService.pickBackupFile();
      if (filePath == null) {
        return Left(BackupFailure.import('No file selected'));
      }

      // Validate the backup
      final validation = await _backupFileService.validateBackupFile(filePath);
      if (!validation.isValid) {
        return Left(BackupFailure.import(validation.errorMessage ?? 'Invalid backup file'));
      }

      // Read the backup data
      final backupData = await _backupFileService.readBackupFile(filePath);

      // Import based on mode
      ImportResult result;
      if (mode == ImportMode.replace) {
        result = await _importWithReplace(backupData);
      } else {
        result = await _importWithMerge(backupData);
      }

      return Right(result);
    } catch (e) {
      return Left(BackupFailure.import(e.toString()));
    }
  }

  @override
  Future<Either<Failure, BackupValidationResult>> validateBackup(String filePath) async {
    try {
      final validation = await _backupFileService.validateBackupFile(filePath);

      if (validation.isValid && validation.metadata != null) {
        return Right(BackupValidationResult.valid(validation.metadata!.toEntity()));
      } else {
        return Right(BackupValidationResult.invalid(
          validation.errorMessage ?? 'Unknown error',
        ));
      }
    } catch (e) {
      return Left(BackupFailure.validation(e.toString()));
    }
  }

  @override
  Future<Either<Failure, BackupData>> readBackupFile(String filePath) async {
    try {
      final backupData = await _backupFileService.readBackupFile(filePath);
      return Right(backupData.toEntity());
    } catch (e) {
      return Left(BackupFailure.read(e.toString()));
    }
  }

  @override
  Future<Either<Failure, String>> getBackupDirectory() async {
    try {
      final dir = await _backupFileService.getBackupDirectory();
      return Right(dir.path);
    } catch (e) {
      return Left(BackupFailure.read(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<BackupFileInfo>>> listBackups() async {
    try {
      final files = await _backupFileService.listBackupFiles();
      return Right(files
          .map((f) => BackupFileInfo(
                filePath: f.filePath,
                fileName: f.fileName,
                createdAt: f.createdAt,
                fileSizeBytes: f.fileSizeBytes,
              ))
          .toList());
    } catch (e) {
      return Left(BackupFailure.read(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> deleteBackup(String filePath) async {
    try {
      await _backupFileService.deleteBackupFile(filePath);
      return const Right(null);
    } catch (e) {
      return Left(BackupFailure.deletion(e.toString()));
    }
  }

  /// Create backup data from all data sources
  Future<BackupDataModel> _createBackupData() async {
    final expenses = await _expenseDataSource.getAllExpenses();
    final categories = await _categoryDataSource.getAllCategories();
    final settings = await _settingsDataSource.getSettings();

    final metadata = BackupMetadataModel(
      version: kBackupFormatVersion,
      exportedAt: DateTime.now(),
      appVersion: kAppVersion,
      expenseCount: expenses.length,
      categoryCount: categories.length,
    );

    return BackupDataModel(
      metadata: metadata,
      expenses: expenses,
      categories: categories,
      settings: settings,
    );
  }

  /// Import with replace mode - clear existing data first
  Future<ImportResult> _importWithReplace(BackupDataModel backupData) async {
    // Clear existing data
    await _expenseDataSource.deleteAllExpenses();

    // Import expenses
    for (final expense in backupData.expenses) {
      await _expenseDataSource.addExpense(expense);
    }

    // Import categories (only non-default ones, keep default categories)
    final existingCategories = await _categoryDataSource.getAllCategories();
    final existingIds = existingCategories.map((c) => c.id).toSet();

    int categoriesImported = 0;
    for (final category in backupData.categories) {
      if (!category.isDefault || !existingIds.contains(category.id)) {
        await _categoryDataSource.addCategory(category);
        categoriesImported++;
      } else {
        // Update existing default category with backup data
        await _categoryDataSource.updateCategory(category);
        categoriesImported++;
      }
    }

    // Import settings if present (optional)
    if (backupData.settings != null) {
      await _settingsDataSource.saveSettings(backupData.settings!);
    }

    return ImportResult(
      expensesImported: backupData.expenses.length,
      categoriesImported: categoriesImported,
    );
  }

  /// Import with merge mode - keep existing data, skip duplicates
  Future<ImportResult> _importWithMerge(BackupDataModel backupData) async {
    int expensesImported = 0;
    int expensesSkipped = 0;
    int categoriesImported = 0;
    int categoriesSkipped = 0;

    // Get existing IDs
    final existingExpenses = await _expenseDataSource.getAllExpenses();
    final existingExpenseIds = existingExpenses.map((e) => e.id).toSet();

    final existingCategories = await _categoryDataSource.getAllCategories();
    final existingCategoryIds = existingCategories.map((c) => c.id).toSet();

    // Import expenses (skip existing)
    for (final expense in backupData.expenses) {
      if (!existingExpenseIds.contains(expense.id)) {
        await _expenseDataSource.addExpense(expense);
        expensesImported++;
      } else {
        expensesSkipped++;
      }
    }

    // Import categories (skip existing non-default)
    for (final category in backupData.categories) {
      if (!existingCategoryIds.contains(category.id)) {
        await _categoryDataSource.addCategory(category);
        categoriesImported++;
      } else {
        categoriesSkipped++;
      }
    }

    return ImportResult(
      expensesImported: expensesImported,
      categoriesImported: categoriesImported,
      expensesSkipped: expensesSkipped,
      categoriesSkipped: categoriesSkipped,
    );
  }
}
