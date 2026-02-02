import 'dart:convert';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../models/backup_model.dart';

/// Service for handling backup file operations
class BackupFileService {
  static const String _backupFilePrefix = 'expense_manager_backup_';
  static const String _backupFileExtension = '.json';

  /// Generate a backup filename with current date
  String generateBackupFileName() {
    final now = DateTime.now();
    final dateStr =
        '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
    final timeStr =
        '${now.hour.toString().padLeft(2, '0')}${now.minute.toString().padLeft(2, '0')}';
    return '$_backupFilePrefix${dateStr}_$timeStr$_backupFileExtension';
  }

  /// Get the default backup directory
  Future<Directory> getBackupDirectory() async {
    final appDir = await getApplicationDocumentsDirectory();
    final backupDir = Directory('${appDir.path}/backups');
    if (!await backupDir.exists()) {
      await backupDir.create(recursive: true);
    }
    return backupDir;
  }

  /// Save backup data to default location
  Future<String> saveBackup(BackupDataModel backupData) async {
    final backupDir = await getBackupDirectory();
    final fileName = generateBackupFileName();
    final filePath = '${backupDir.path}/$fileName';

    final jsonString = const JsonEncoder.withIndent('  ').convert(
      backupData.toJson(),
    );

    final file = File(filePath);
    await file.writeAsString(jsonString, encoding: utf8);

    return filePath;
  }

  /// Export backup using share sheet (user chooses destination)
  Future<String> exportBackupWithShare(BackupDataModel backupData) async {
    // First save to temp location
    final tempDir = await getTemporaryDirectory();
    final fileName = generateBackupFileName();
    final filePath = '${tempDir.path}/$fileName';

    final jsonString = const JsonEncoder.withIndent('  ').convert(
      backupData.toJson(),
    );

    final file = File(filePath);
    await file.writeAsString(jsonString, encoding: utf8);

    // Share the file
    await Share.shareXFiles(
      [XFile(filePath)],
      subject: 'Expense Manager Backup',
      text: 'Expense Manager backup created on ${DateTime.now().toString().split('.')[0]}',
    );

    return filePath;
  }

  /// Pick a backup file using file picker
  Future<String?> pickBackupFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['json'],
      allowMultiple: false,
    );

    if (result != null && result.files.isNotEmpty) {
      return result.files.first.path;
    }
    return null;
  }

  /// Read backup data from a file
  Future<BackupDataModel> readBackupFile(String filePath) async {
    final file = File(filePath);
    if (!await file.exists()) {
      throw FileSystemException('Backup file not found', filePath);
    }

    final jsonString = await file.readAsString(encoding: utf8);
    final json = jsonDecode(jsonString) as Map<String, dynamic>;

    return BackupDataModel.fromJson(json);
  }

  /// Validate backup file format
  Future<BackupValidationInfo> validateBackupFile(String filePath) async {
    try {
      final file = File(filePath);
      if (!await file.exists()) {
        return BackupValidationInfo(
          isValid: false,
          errorMessage: 'File not found',
        );
      }

      final jsonString = await file.readAsString(encoding: utf8);
      final json = jsonDecode(jsonString) as Map<String, dynamic>;

      // Check for required fields
      if (!json.containsKey('metadata')) {
        return BackupValidationInfo(
          isValid: false,
          errorMessage: 'Invalid backup format: missing metadata',
        );
      }

      final metadata = json['metadata'] as Map<String, dynamic>;
      if (!metadata.containsKey('version')) {
        return BackupValidationInfo(
          isValid: false,
          errorMessage: 'Invalid backup format: missing version',
        );
      }

      // Parse metadata for display
      final backupMetadata = BackupMetadataModel.fromJson(metadata);

      return BackupValidationInfo(
        isValid: true,
        metadata: backupMetadata,
      );
    } on FormatException catch (e) {
      return BackupValidationInfo(
        isValid: false,
        errorMessage: 'Invalid JSON format: ${e.message}',
      );
    } catch (e) {
      return BackupValidationInfo(
        isValid: false,
        errorMessage: 'Error reading file: $e',
      );
    }
  }

  /// List all backup files in the default directory
  Future<List<BackupFileInfoModel>> listBackupFiles() async {
    final backupDir = await getBackupDirectory();
    final files = <BackupFileInfoModel>[];

    if (!await backupDir.exists()) {
      return files;
    }

    await for (final entity in backupDir.list()) {
      if (entity is File && entity.path.endsWith(_backupFileExtension)) {
        final stat = await entity.stat();
        files.add(BackupFileInfoModel(
          filePath: entity.path,
          fileName: entity.path.split(Platform.pathSeparator).last,
          createdAt: stat.modified,
          fileSizeBytes: stat.size,
        ));
      }
    }

    // Sort by date, newest first
    files.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return files;
  }

  /// Delete a backup file
  Future<void> deleteBackupFile(String filePath) async {
    final file = File(filePath);
    if (await file.exists()) {
      await file.delete();
    }
  }
}

/// Validation info for backup file
class BackupValidationInfo {
  final bool isValid;
  final String? errorMessage;
  final BackupMetadataModel? metadata;

  const BackupValidationInfo({
    required this.isValid,
    this.errorMessage,
    this.metadata,
  });
}

/// Model for backup file info
class BackupFileInfoModel {
  final String filePath;
  final String fileName;
  final DateTime createdAt;
  final int fileSizeBytes;

  const BackupFileInfoModel({
    required this.filePath,
    required this.fileName,
    required this.createdAt,
    required this.fileSizeBytes,
  });
}
