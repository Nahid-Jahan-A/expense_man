import 'package:equatable/equatable.dart';
import '../../../expense/domain/entities/expense.dart';
import '../../../category/domain/entities/category.dart';
import '../../../settings/domain/entities/app_settings.dart';

/// Metadata about the backup file
class BackupMetadata extends Equatable {
  final String version;
  final DateTime exportedAt;
  final String appVersion;
  final int expenseCount;
  final int categoryCount;
  final String? deviceInfo;

  const BackupMetadata({
    required this.version,
    required this.exportedAt,
    required this.appVersion,
    required this.expenseCount,
    required this.categoryCount,
    this.deviceInfo,
  });

  @override
  List<Object?> get props => [
        version,
        exportedAt,
        appVersion,
        expenseCount,
        categoryCount,
        deviceInfo,
      ];
}

/// Complete backup data containing all app data
class BackupData extends Equatable {
  final BackupMetadata metadata;
  final List<Expense> expenses;
  final List<Category> categories;
  final AppSettings? settings;

  const BackupData({
    required this.metadata,
    required this.expenses,
    required this.categories,
    this.settings,
  });

  /// Check if backup is empty
  bool get isEmpty => expenses.isEmpty && categories.isEmpty;

  /// Check if backup has data
  bool get hasData => expenses.isNotEmpty || categories.isNotEmpty;

  @override
  List<Object?> get props => [metadata, expenses, categories, settings];
}

/// Options for importing backup
enum ImportMode {
  /// Replace all existing data with backup data
  replace,

  /// Merge backup data with existing data (skip duplicates)
  merge,
}

/// Result of backup validation
class BackupValidationResult extends Equatable {
  final bool isValid;
  final String? errorMessage;
  final BackupMetadata? metadata;

  const BackupValidationResult({
    required this.isValid,
    this.errorMessage,
    this.metadata,
  });

  factory BackupValidationResult.valid(BackupMetadata metadata) {
    return BackupValidationResult(
      isValid: true,
      metadata: metadata,
    );
  }

  factory BackupValidationResult.invalid(String message) {
    return BackupValidationResult(
      isValid: false,
      errorMessage: message,
    );
  }

  @override
  List<Object?> get props => [isValid, errorMessage, metadata];
}

/// Result of import operation
class ImportResult extends Equatable {
  final int expensesImported;
  final int categoriesImported;
  final int expensesSkipped;
  final int categoriesSkipped;

  const ImportResult({
    required this.expensesImported,
    required this.categoriesImported,
    this.expensesSkipped = 0,
    this.categoriesSkipped = 0,
  });

  int get totalImported => expensesImported + categoriesImported;
  int get totalSkipped => expensesSkipped + categoriesSkipped;

  @override
  List<Object?> get props => [
        expensesImported,
        categoriesImported,
        expensesSkipped,
        categoriesSkipped,
      ];
}
