import '../../../expense/data/models/expense_model.dart';
import '../../../category/data/models/category_model.dart';
import '../../../settings/data/models/settings_model.dart';
import '../../domain/entities/backup_data.dart';

/// Model for backup metadata with JSON serialization
class BackupMetadataModel {
  final String version;
  final DateTime exportedAt;
  final String appVersion;
  final int expenseCount;
  final int categoryCount;
  final String? deviceInfo;

  const BackupMetadataModel({
    required this.version,
    required this.exportedAt,
    required this.appVersion,
    required this.expenseCount,
    required this.categoryCount,
    this.deviceInfo,
  });

  factory BackupMetadataModel.fromJson(Map<String, dynamic> json) {
    return BackupMetadataModel(
      version: json['version'] as String,
      exportedAt: DateTime.parse(json['exportedAt'] as String),
      appVersion: json['appVersion'] as String,
      expenseCount: json['expenseCount'] as int,
      categoryCount: json['categoryCount'] as int,
      deviceInfo: json['deviceInfo'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'version': version,
      'exportedAt': exportedAt.toIso8601String(),
      'appVersion': appVersion,
      'expenseCount': expenseCount,
      'categoryCount': categoryCount,
      if (deviceInfo != null) 'deviceInfo': deviceInfo,
    };
  }

  BackupMetadata toEntity() {
    return BackupMetadata(
      version: version,
      exportedAt: exportedAt,
      appVersion: appVersion,
      expenseCount: expenseCount,
      categoryCount: categoryCount,
      deviceInfo: deviceInfo,
    );
  }

  factory BackupMetadataModel.fromEntity(BackupMetadata entity) {
    return BackupMetadataModel(
      version: entity.version,
      exportedAt: entity.exportedAt,
      appVersion: entity.appVersion,
      expenseCount: entity.expenseCount,
      categoryCount: entity.categoryCount,
      deviceInfo: entity.deviceInfo,
    );
  }
}

/// Model for complete backup data with JSON serialization
class BackupDataModel {
  final BackupMetadataModel metadata;
  final List<ExpenseModel> expenses;
  final List<CategoryModel> categories;
  final SettingsModel? settings;

  const BackupDataModel({
    required this.metadata,
    required this.expenses,
    required this.categories,
    this.settings,
  });

  factory BackupDataModel.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>? ?? json;

    return BackupDataModel(
      metadata: BackupMetadataModel.fromJson(
        json['metadata'] as Map<String, dynamic>,
      ),
      expenses: (data['expenses'] as List<dynamic>?)
              ?.map((e) => ExpenseModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      categories: (data['categories'] as List<dynamic>?)
              ?.map((e) => CategoryModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      settings: data['settings'] != null
          ? SettingsModel.fromJson(data['settings'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'metadata': metadata.toJson(),
      'data': {
        'expenses': expenses.map((e) => e.toJson()).toList(),
        'categories': categories.map((c) => c.toJson()).toList(),
        if (settings != null) 'settings': settings!.toJson(),
      },
    };
  }

  BackupData toEntity() {
    return BackupData(
      metadata: metadata.toEntity(),
      expenses: expenses.map((e) => e.toEntity()).toList(),
      categories: categories.map((c) => c.toEntity()).toList(),
      settings: settings?.toEntity(),
    );
  }

  factory BackupDataModel.fromEntity(BackupData entity) {
    return BackupDataModel(
      metadata: BackupMetadataModel.fromEntity(entity.metadata),
      expenses: entity.expenses.map((e) => ExpenseModel.fromEntity(e)).toList(),
      categories:
          entity.categories.map((c) => CategoryModel.fromEntity(c)).toList(),
      settings: entity.settings != null
          ? SettingsModel.fromEntity(entity.settings!)
          : null,
    );
  }
}

/// Current backup file format version
const String kBackupFormatVersion = '1.0';

/// App version for backup metadata
const String kAppVersion = '1.0.0';
