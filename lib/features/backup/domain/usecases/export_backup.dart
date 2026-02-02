import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../repositories/backup_repository.dart';

/// Use case to export backup to a user-selected location
class ExportBackup {
  final BackupRepository _repository;

  ExportBackup(this._repository);

  /// Execute the use case
  /// Returns the file path where backup was saved
  Future<Either<Failure, String>> call() async {
    return await _repository.exportBackup();
  }
}
