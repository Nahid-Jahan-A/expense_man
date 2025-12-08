import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import '../core/theme/app_theme.dart';
import '../core/localization/app_localizations.dart';
import '../core/di/service_locator.dart';
import '../features/expense/presentation/bloc/expense_bloc.dart';
import '../features/expense/presentation/bloc/expense_event.dart';
import '../features/category/presentation/bloc/category_bloc.dart';
import '../features/category/presentation/bloc/category_event.dart';
import '../features/settings/presentation/bloc/settings_bloc.dart';
import '../features/settings/presentation/bloc/settings_event.dart';
import '../features/settings/presentation/bloc/settings_state.dart';
import '../features/dashboard/presentation/bloc/dashboard_bloc.dart';
import '../features/dashboard/presentation/bloc/dashboard_event.dart';
import '../features/pdf_export/presentation/bloc/pdf_export_bloc.dart';
import 'home_page.dart';

/// Main application widget
class ExpenseManagerApp extends StatelessWidget {
  const ExpenseManagerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => sl<SettingsBloc>()..add(const LoadSettings()),
        ),
        BlocProvider(
          create: (context) => sl<CategoryBloc>()..add(const LoadCategories()),
        ),
        BlocProvider(
          create: (context) => sl<ExpenseBloc>()..add(const LoadExpenses()),
        ),
        BlocProvider(
          create: (context) => sl<DashboardBloc>()..add(const LoadDashboard()),
        ),
        BlocProvider(
          create: (context) => sl<PdfExportBloc>(),
        ),
      ],
      child: BlocBuilder<SettingsBloc, SettingsState>(
        builder: (context, state) {
          // Default values if settings not loaded yet
          ThemeMode themeMode = ThemeMode.system;
          Locale locale = const Locale('en');

          if (state is SettingsLoaded) {
            themeMode = state.themeMode;
            locale = state.locale;
          }

          return MaterialApp(
            title: 'Expense Manager',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: themeMode,
            locale: locale,
            supportedLocales: AppLocalizations.supportedLocales,
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            home: const HomePage(),
          );
        },
      ),
    );
  }
}
