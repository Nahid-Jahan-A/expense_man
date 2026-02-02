import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/backup_data.dart';
import '../repositories/backup_repository.dart';

/// Use case to validate a backup file before importing
class ValidateBackup {
  final BackupRepository _repository;

  ValidateBackup(this._repository);

  /// Execute the use case
  /// [filePath] path to the backup file to validate
  Future<Either<Failure, BackupValidationResult>> call(String filePath) async {
    return await _repository.validateBackup(filePath);
  }
}
