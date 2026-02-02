import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/backup_data.dart';
import '../repositories/backup_repository.dart';

/// Use case to import backup from a file
class ImportBackup {
  final BackupRepository _repository;

  ImportBackup(this._repository);

  /// Execute the use case
  /// [mode] determines whether to replace or merge with existing data
  Future<Either<Failure, ImportResult>> call(ImportMode mode) async {
    return await _repository.importBackup(mode);
  }
}
