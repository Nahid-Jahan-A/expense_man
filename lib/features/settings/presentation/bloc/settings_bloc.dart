import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/repositories/settings_repository.dart';
import 'settings_event.dart';
import 'settings_state.dart';

/// BLoC for settings management
class SettingsBloc extends Bloc<SettingsEvent, SettingsState> {
  final SettingsRepository _repository;

  SettingsBloc(this._repository) : super(const SettingsInitial()) {
    on<LoadSettings>(_onLoadSettings);
    on<ChangeThemeMode>(_onChangeThemeMode);
    on<ChangeLanguage>(_onChangeLanguage);
    on<ChangeCurrency>(_onChangeCurrency);
    on<CompleteFirstLaunch>(_onCompleteFirstLaunch);
    on<UpdateBackupDate>(_onUpdateBackupDate);
  }

  Future<void> _onLoadSettings(
    LoadSettings event,
    Emitter<SettingsState> emit,
  ) async {
    emit(const SettingsLoading());

    final result = await _repository.getSettings();
    result.fold(
      (failure) => emit(SettingsError(failure)),
      (settings) => emit(SettingsLoaded(settings)),
    );
  }

  Future<void> _onChangeThemeMode(
    ChangeThemeMode event,
    Emitter<SettingsState> emit,
  ) async {
    final currentState = state;

    if (currentState is SettingsLoaded) {
      final result = await _repository.updateThemeMode(event.themeMode);
      result.fold(
        (failure) => emit(SettingsError(failure)),
        (_) {
          final updatedSettings = currentState.settings.copyWith(
            themeMode: event.themeMode,
          );
          emit(SettingsLoaded(updatedSettings));
        },
      );
    }
  }

  Future<void> _onChangeLanguage(
    ChangeLanguage event,
    Emitter<SettingsState> emit,
  ) async {
    final currentState = state;

    if (currentState is SettingsLoaded) {
      final result = await _repository.updateLanguage(event.languageCode);
      result.fold(
        (failure) => emit(SettingsError(failure)),
        (_) {
          final updatedSettings = currentState.settings.copyWith(
            languageCode: event.languageCode,
          );
          emit(SettingsLoaded(updatedSettings));
        },
      );
    }
  }

  Future<void> _onChangeCurrency(
    ChangeCurrency event,
    Emitter<SettingsState> emit,
  ) async {
    final currentState = state;

    if (currentState is SettingsLoaded) {
      final result = await _repository.updateCurrency(event.currencyCode);
      result.fold(
        (failure) => emit(SettingsError(failure)),
        (_) {
          final updatedSettings = currentState.settings.copyWith(
            currencyCode: event.currencyCode,
          );
          emit(SettingsLoaded(updatedSettings));
        },
      );
    }
  }

  Future<void> _onCompleteFirstLaunch(
    CompleteFirstLaunch event,
    Emitter<SettingsState> emit,
  ) async {
    final currentState = state;

    if (currentState is SettingsLoaded) {
      final result = await _repository.setFirstLaunchComplete();
      result.fold(
        (failure) => emit(SettingsError(failure)),
        (_) {
          final updatedSettings = currentState.settings.copyWith(
            isFirstLaunch: false,
          );
          emit(SettingsLoaded(updatedSettings));
        },
      );
    }
  }

  Future<void> _onUpdateBackupDate(
    UpdateBackupDate event,
    Emitter<SettingsState> emit,
  ) async {
    final currentState = state;

    if (currentState is SettingsLoaded) {
      final result = await _repository.updateLastBackupDate(event.date);
      result.fold(
        (failure) => emit(SettingsError(failure)),
        (_) {
          final updatedSettings = currentState.settings.copyWith(
            lastBackupDate: event.date,
          );
          emit(SettingsLoaded(updatedSettings));
        },
      );
    }
  }
}
