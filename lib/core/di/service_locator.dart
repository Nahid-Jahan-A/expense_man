import 'package:get_it/get_it.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../../features/expense/data/datasources/expense_local_datasource.dart';
import '../../features/expense/data/repositories/expense_repository_impl.dart';
import '../../features/expense/domain/repositories/expense_repository.dart';
import '../../features/expense/domain/usecases/add_expense.dart';
import '../../features/expense/domain/usecases/delete_expense.dart';
import '../../features/expense/domain/usecases/get_expenses.dart';
import '../../features/expense/domain/usecases/get_expenses_by_date_range.dart';
import '../../features/expense/domain/usecases/get_monthly_summary.dart';
import '../../features/expense/domain/usecases/update_expense.dart';
import '../../features/expense/presentation/bloc/expense_bloc.dart';

import '../../features/category/data/datasources/category_local_datasource.dart';
import '../../features/category/data/repositories/category_repository_impl.dart';
import '../../features/category/domain/repositories/category_repository.dart';
import '../../features/category/domain/usecases/add_category.dart';
import '../../features/category/domain/usecases/delete_category.dart';
import '../../features/category/domain/usecases/get_categories.dart';
import '../../features/category/domain/usecases/update_category.dart';
import '../../features/category/presentation/bloc/category_bloc.dart';

import '../../features/settings/data/datasources/settings_local_datasource.dart';
import '../../features/settings/data/repositories/settings_repository_impl.dart';
import '../../features/settings/domain/repositories/settings_repository.dart';
import '../../features/settings/presentation/bloc/settings_bloc.dart';

import '../../features/pdf_export/data/pdf_generator.dart';
import '../../features/pdf_export/presentation/bloc/pdf_export_bloc.dart';

import '../../features/dashboard/presentation/bloc/dashboard_bloc.dart';

import '../../features/backup/data/services/backup_file_service.dart';
import '../../features/backup/data/repositories/backup_repository_impl.dart';
import '../../features/backup/domain/repositories/backup_repository.dart';
import '../../features/backup/domain/usecases/create_backup.dart';
import '../../features/backup/domain/usecases/export_backup.dart';
import '../../features/backup/domain/usecases/import_backup.dart';
import '../../features/backup/presentation/bloc/backup_bloc.dart';

final sl = GetIt.instance;

/// Initialize all dependencies
/// Note: Hive must be initialized in main.dart before calling this function
Future<void> initializeDependencies() async {
  // Register Hive Boxes
  await _registerHiveBoxes();

  // Register Services (must be before repositories that depend on them)
  _registerServices();

  // Register DataSources
  _registerDataSources();

  // Register Repositories
  _registerRepositories();

  // Register UseCases
  _registerUseCases();

  // Register Blocs
  _registerBlocs();
}

Future<void> _registerHiveBoxes() async {
  // Open boxes (will be typed after adapters are registered)
  final expenseBox = await Hive.openBox('expenses');
  final categoryBox = await Hive.openBox('categories');
  final settingsBox = await Hive.openBox('settings');

  sl.registerSingleton<Box>(expenseBox, instanceName: 'expenseBox');
  sl.registerSingleton<Box>(categoryBox, instanceName: 'categoryBox');
  sl.registerSingleton<Box>(settingsBox, instanceName: 'settingsBox');
}

void _registerDataSources() {
  sl.registerLazySingleton<ExpenseLocalDataSource>(
    () => ExpenseLocalDataSourceImpl(sl(instanceName: 'expenseBox')),
  );

  sl.registerLazySingleton<CategoryLocalDataSource>(
    () => CategoryLocalDataSourceImpl(sl(instanceName: 'categoryBox')),
  );

  sl.registerLazySingleton<SettingsLocalDataSource>(
    () => SettingsLocalDataSourceImpl(sl(instanceName: 'settingsBox')),
  );
}

void _registerRepositories() {
  sl.registerLazySingleton<ExpenseRepository>(
    () => ExpenseRepositoryImpl(sl()),
  );

  sl.registerLazySingleton<CategoryRepository>(
    () => CategoryRepositoryImpl(sl()),
  );

  sl.registerLazySingleton<SettingsRepository>(
    () => SettingsRepositoryImpl(sl()),
  );

  sl.registerLazySingleton<BackupRepository>(
    () => BackupRepositoryImpl(
      expenseDataSource: sl(),
      categoryDataSource: sl(),
      settingsDataSource: sl(),
      backupFileService: sl(),
    ),
  );
}

void _registerUseCases() {
  // Expense UseCases
  sl.registerLazySingleton(() => GetExpenses(sl()));
  sl.registerLazySingleton(() => GetExpensesByDateRange(sl()));
  sl.registerLazySingleton(() => GetMonthlySummary(sl()));
  sl.registerLazySingleton(() => AddExpense(sl()));
  sl.registerLazySingleton(() => UpdateExpense(sl()));
  sl.registerLazySingleton(() => DeleteExpense(sl()));

  // Category UseCases
  sl.registerLazySingleton(() => GetCategories(sl()));
  sl.registerLazySingleton(() => AddCategory(sl()));
  sl.registerLazySingleton(() => UpdateCategory(sl()));
  sl.registerLazySingleton(() => DeleteCategory(sl()));

  // Backup UseCases
  sl.registerLazySingleton(() => CreateBackup(sl()));
  sl.registerLazySingleton(() => ExportBackup(sl()));
  sl.registerLazySingleton(() => ImportBackup(sl()));
}

void _registerBlocs() {
  sl.registerFactory(
    () => ExpenseBloc(
      getExpenses: sl(),
      getExpensesByDateRange: sl(),
      getMonthlySummary: sl(),
      addExpense: sl(),
      updateExpense: sl(),
      deleteExpense: sl(),
    ),
  );

  sl.registerFactory(
    () => CategoryBloc(
      getCategories: sl(),
      addCategory: sl(),
      updateCategory: sl(),
      deleteCategory: sl(),
    ),
  );

  sl.registerFactory(
    () => SettingsBloc(sl()),
  );

  sl.registerFactory(
    () => DashboardBloc(
      getExpenses: sl(),
      getMonthlySummary: sl(),
    ),
  );

  sl.registerFactory(
    () => PdfExportBloc(sl()),
  );

  sl.registerFactory(
    () => BackupBloc(
      createBackup: sl(),
      exportBackup: sl(),
      importBackup: sl(),
      repository: sl(),
    ),
  );
}

void _registerServices() {
  sl.registerLazySingleton<PdfGenerator>(() => PdfGeneratorImpl());
  sl.registerLazySingleton<BackupFileService>(() => BackupFileService());
}
