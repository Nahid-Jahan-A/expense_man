import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/create_backup.dart';
import '../../domain/usecases/export_backup.dart';
import '../../domain/usecases/import_backup.dart';
import '../../domain/repositories/backup_repository.dart';
import 'backup_event.dart';
import 'backup_state.dart';

/// BLoC for managing backup operations
class BackupBloc extends Bloc<BackupEvent, BackupState> {
  final CreateBackup _createBackup;
  final ExportBackup _exportBackup;
  final ImportBackup _importBackup;
  final BackupRepository _repository;

  BackupBloc({
    required CreateBackup createBackup,
    required ExportBackup exportBackup,
    required ImportBackup importBackup,
    required BackupRepository repository,
  })  : _createBackup = createBackup,
        _exportBackup = exportBackup,
        _importBackup = importBackup,
        _repository = repository,
        super(const BackupInitial()) {
    on<CreateBackupEvent>(_onCreateBackup);
    on<ExportBackupEvent>(_onExportBackup);
    on<ImportBackupEvent>(_onImportBackup);
    on<ValidateBackupFileEvent>(_onValidateBackup);
    on<LoadBackupListEvent>(_onLoadBackupList);
    on<DeleteBackupFileEvent>(_onDeleteBackup);
    on<ResetBackupStateEvent>(_onResetState);
  }

  Future<void> _onCreateBackup(
    CreateBackupEvent event,
    Emitter<BackupState> emit,
  ) async {
    emit(const BackupLoading('Creating backup...'));

    final result = await _createBackup();

    result.fold(
      (failure) => emit(BackupError(failure)),
      (filePath) => emit(BackupCreated(
        filePath: filePath,
        createdAt: DateTime.now(),
      )),
    );
  }

  Future<void> _onExportBackup(
    ExportBackupEvent event,
    Emitter<BackupState> emit,
  ) async {
    emit(const BackupLoading('Preparing backup for export...'));

    final result = await _exportBackup();

    result.fold(
      (failure) => emit(BackupError(failure)),
      (filePath) => emit(BackupExported(filePath)),
    );
  }

  Future<void> _onImportBackup(
    ImportBackupEvent event,
    Emitter<BackupState> emit,
  ) async {
    emit(const BackupLoading('Importing backup...'));

    final result = await _importBackup(event.mode);

    result.fold(
      (failure) => emit(BackupError(failure)),
      (importResult) => emit(BackupImported(
        result: importResult,
        mode: event.mode,
      )),
    );
  }

  Future<void> _onValidateBackup(
    ValidateBackupFileEvent event,
    Emitter<BackupState> emit,
  ) async {
    emit(const BackupLoading('Validating backup file...'));

    final result = await _repository.validateBackup(event.filePath);

    result.fold(
      (failure) => emit(BackupError(failure)),
      (validationResult) => emit(BackupValidated(
        result: validationResult,
        filePath: event.filePath,
      )),
    );
  }

  Future<void> _onLoadBackupList(
    LoadBackupListEvent event,
    Emitter<BackupState> emit,
  ) async {
    emit(const BackupLoading('Loading backups...'));

    final result = await _repository.listBackups();

    result.fold(
      (failure) => emit(BackupError(failure)),
      (backups) => emit(BackupListLoaded(backups)),
    );
  }

  Future<void> _onDeleteBackup(
    DeleteBackupFileEvent event,
    Emitter<BackupState> emit,
  ) async {
    emit(const BackupLoading('Deleting backup...'));

    final result = await _repository.deleteBackup(event.filePath);

    result.fold(
      (failure) => emit(BackupError(failure)),
      (_) => emit(BackupDeleted(event.filePath)),
    );
  }

  void _onResetState(
    ResetBackupStateEvent event,
    Emitter<BackupState> emit,
  ) {
    emit(const BackupInitial());
  }
}
