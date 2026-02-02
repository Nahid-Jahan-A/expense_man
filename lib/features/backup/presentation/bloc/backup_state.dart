import 'package:equatable/equatable.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/backup_data.dart';
import '../../domain/repositories/backup_repository.dart';

/// Base class for backup states
sealed class BackupState extends Equatable {
  const BackupState();

  @override
  List<Object?> get props => [];
}

/// Initial state
class BackupInitial extends BackupState {
  const BackupInitial();
}

/// Loading state for any backup operation
class BackupLoading extends BackupState {
  final String? message;

  const BackupLoading([this.message]);

  @override
  List<Object?> get props => [message];
}

/// State when backup list is loaded
class BackupListLoaded extends BackupState {
  final List<BackupFileInfo> backups;

  const BackupListLoaded(this.backups);

  @override
  List<Object?> get props => [backups];
}

/// State when backup is created successfully
class BackupCreated extends BackupState {
  final String filePath;
  final DateTime createdAt;

  const BackupCreated({
    required this.filePath,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [filePath, createdAt];
}

/// State when backup is exported successfully
class BackupExported extends BackupState {
  final String filePath;

  const BackupExported(this.filePath);

  @override
  List<Object?> get props => [filePath];
}

/// State when backup is saved locally successfully
class BackupSavedLocally extends BackupState {
  final String filePath;

  const BackupSavedLocally(this.filePath);

  @override
  List<Object?> get props => [filePath];
}

/// State when backup validation is complete
class BackupValidated extends BackupState {
  final BackupValidationResult result;
  final String filePath;

  const BackupValidated({
    required this.result,
    required this.filePath,
  });

  bool get isValid => result.isValid;
  BackupMetadata? get metadata => result.metadata;

  @override
  List<Object?> get props => [result, filePath];
}

/// State when backup is imported successfully
class BackupImported extends BackupState {
  final ImportResult result;
  final ImportMode mode;

  const BackupImported({
    required this.result,
    required this.mode,
  });

  @override
  List<Object?> get props => [result, mode];
}

/// State when backup file is deleted
class BackupDeleted extends BackupState {
  final String filePath;

  const BackupDeleted(this.filePath);

  @override
  List<Object?> get props => [filePath];
}

/// Error state
class BackupError extends BackupState {
  final Failure failure;

  const BackupError(this.failure);

  String get message => failure.message;

  String getLocalizedMessage(String locale) => failure.getLocalizedMessage(locale);

  @override
  List<Object?> get props => [failure];
}
