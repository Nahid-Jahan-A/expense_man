import 'package:equatable/equatable.dart';
import '../../domain/entities/backup_data.dart';

/// Base class for backup events
sealed class BackupEvent extends Equatable {
  const BackupEvent();

  @override
  List<Object?> get props => [];
}

/// Event to create a backup (saved to app directory)
class CreateBackupEvent extends BackupEvent {
  const CreateBackupEvent();
}

/// Event to export backup (share with user)
class ExportBackupEvent extends BackupEvent {
  const ExportBackupEvent();
}

/// Event to import a backup file
class ImportBackupEvent extends BackupEvent {
  final ImportMode mode;

  const ImportBackupEvent(this.mode);

  @override
  List<Object?> get props => [mode];
}

/// Event to validate a backup file before importing
class ValidateBackupFileEvent extends BackupEvent {
  final String filePath;

  const ValidateBackupFileEvent(this.filePath);

  @override
  List<Object?> get props => [filePath];
}

/// Event to load list of existing backups
class LoadBackupListEvent extends BackupEvent {
  const LoadBackupListEvent();
}

/// Event to delete a backup file
class DeleteBackupFileEvent extends BackupEvent {
  final String filePath;

  const DeleteBackupFileEvent(this.filePath);

  @override
  List<Object?> get props => [filePath];
}

/// Event to reset backup state
class ResetBackupStateEvent extends BackupEvent {
  const ResetBackupStateEvent();
}
