import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/backup_data.dart';

/// Repository interface for backup operations
abstract class BackupRepository {
  /// Create a backup of all app data
  /// Returns the file path where backup was saved
  Future<Either<Failure, String>> createBackup();

  /// Export backup to a user-selected location
  /// Returns the file path where backup was saved
  Future<Either<Failure, String>> exportBackup();

  /// Import backup from a user-selected file
  /// [mode] determines whether to replace or merge with existing data
  Future<Either<Failure, ImportResult>> importBackup(ImportMode mode);

  /// Validate a backup file without importing
  Future<Either<Failure, BackupValidationResult>> validateBackup(String filePath);

  /// Get backup data from a file path
  Future<Either<Failure, BackupData>> readBackupFile(String filePath);

  /// Get the default backup directory path
  Future<Either<Failure, String>> getBackupDirectory();

  /// List all backup files in the default directory
  Future<Either<Failure, List<BackupFileInfo>>> listBackups();

  /// Delete a backup file
  Future<Either<Failure, void>> deleteBackup(String filePath);
}

/// Information about a backup file
class BackupFileInfo {
  final String filePath;
  final String fileName;
  final DateTime createdAt;
  final int fileSizeBytes;

  const BackupFileInfo({
    required this.filePath,
    required this.fileName,
    required this.createdAt,
    required this.fileSizeBytes,
  });

  String get fileSizeFormatted {
    if (fileSizeBytes < 1024) {
      return '$fileSizeBytes B';
    } else if (fileSizeBytes < 1024 * 1024) {
      return '${(fileSizeBytes / 1024).toStringAsFixed(1)} KB';
    } else {
      return '${(fileSizeBytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
  }
}
