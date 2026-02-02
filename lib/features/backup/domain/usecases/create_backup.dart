import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../repositories/backup_repository.dart';

/// Use case to create a backup of all app data
class CreateBackup {
  final BackupRepository _repository;

  CreateBackup(this._repository);

  /// Execute the use case
  /// Returns the file path where backup was saved
  Future<Either<Failure, String>> call() async {
    return await _repository.createBackup();
  }
}
