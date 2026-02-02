import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../app/home_page.dart';
import '../../features/expense/presentation/pages/add_edit_expense_page.dart';
import '../../features/expense/presentation/pages/expense_list_page.dart';
import '../../features/expense/domain/entities/expense.dart';
import '../../features/category/presentation/pages/category_management_page.dart';
import '../../features/pdf_export/presentation/pages/report_preview_page.dart';
import '../../features/settings/presentation/pages/settings_page.dart';
import '../../features/dashboard/presentation/pages/dashboard_page.dart';
import '../../features/backup/presentation/pages/backup_page.dart';
import '../../features/splash/presentation/pages/splash_page.dart';
import '../../widgets/charts/statistics_page.dart';

/// Route names for type-safe navigation
abstract class AppRoutes {
  static const String splash = '/splash';
  static const String home = '/';
  static const String dashboard = '/dashboard';
  static const String expenses = '/expenses';
  static const String addExpense = '/expenses/add';
  static const String editExpense = '/expenses/edit';
  static const String statistics = '/statistics';
  static const String settings = '/settings';
  static const String categories = '/categories';
  static const String reportPreview = '/report-preview';
  static const String backup = '/backup';
}

/// App router configuration using go_router
class AppRouter {
  static final GlobalKey<NavigatorState> _rootNavigatorKey =
      GlobalKey<NavigatorState>(debugLabel: 'root');
  static final GlobalKey<NavigatorState> _shellNavigatorKey =
      GlobalKey<NavigatorState>(debugLabel: 'shell');

  static final GoRouter router = GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: AppRoutes.splash,
    debugLogDiagnostics: true,
    routes: [
      // Splash screen route
      GoRoute(
        path: AppRoutes.splash,
        name: 'splash',
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: const SplashPage(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(opacity: animation, child: child);
          },
        ),
      ),
      // Shell route for bottom navigation
      ShellRoute(
        navigatorKey: _shellNavigatorKey,
        builder: (context, state, child) {
          return HomePage(child: child);
        },
        routes: [
          GoRoute(
            path: AppRoutes.home,
            name: 'home',
            pageBuilder: (context, state) => CustomTransitionPage(
              key: state.pageKey,
              child: const DashboardPage(),
              transitionsBuilder: _fadeTransition,
            ),
          ),
          GoRoute(
            path: AppRoutes.expenses,
            name: 'expenses',
            pageBuilder: (context, state) => CustomTransitionPage(
              key: state.pageKey,
              child: const ExpenseListPage(),
              transitionsBuilder: _fadeTransition,
            ),
          ),
          GoRoute(
            path: AppRoutes.statistics,
            name: 'statistics',
            pageBuilder: (context, state) => CustomTransitionPage(
              key: state.pageKey,
              child: const StatisticsPage(),
              transitionsBuilder: _fadeTransition,
            ),
          ),
          GoRoute(
            path: AppRoutes.settings,
            name: 'settings',
            pageBuilder: (context, state) => CustomTransitionPage(
              key: state.pageKey,
              child: const SettingsPage(),
              transitionsBuilder: _fadeTransition,
            ),
          ),
        ],
      ),
      // Full-screen routes outside of shell
      GoRoute(
        path: AppRoutes.addExpense,
        name: 'addExpense',
        parentNavigatorKey: _rootNavigatorKey,
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: const AddEditExpensePage(),
          transitionsBuilder: _slideUpTransition,
        ),
      ),
      GoRoute(
        path: AppRoutes.editExpense,
        name: 'editExpense',
        parentNavigatorKey: _rootNavigatorKey,
        pageBuilder: (context, state) {
          final expense = state.extra as Expense?;
          return CustomTransitionPage(
            key: state.pageKey,
            child: AddEditExpensePage(expense: expense),
            transitionsBuilder: _slideUpTransition,
          );
        },
      ),
      GoRoute(
        path: AppRoutes.categories,
        name: 'categories',
        parentNavigatorKey: _rootNavigatorKey,
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: const CategoryManagementPage(),
          transitionsBuilder: _slideTransition,
        ),
      ),
      GoRoute(
        path: AppRoutes.reportPreview,
        name: 'reportPreview',
        parentNavigatorKey: _rootNavigatorKey,
        pageBuilder: (context, state) {
          final args = state.extra as ReportPreviewArgs?;
          return CustomTransitionPage(
            key: state.pageKey,
            child: ReportPreviewPage(
              year: args?.year ?? DateTime.now().year,
              month: args?.month ?? DateTime.now().month,
            ),
            transitionsBuilder: _slideTransition,
          );
        },
      ),
      GoRoute(
        path: AppRoutes.backup,
        name: 'backup',
        parentNavigatorKey: _rootNavigatorKey,
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: const BackupPage(),
          transitionsBuilder: _slideTransition,
        ),
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      appBar: AppBar(title: const Text('Page Not Found')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              'Page not found: ${state.uri.path}',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => context.go(AppRoutes.home),
              child: const Text('Go Home'),
            ),
          ],
        ),
      ),
    ),
  );

  /// Fade transition for tab switches
  static Widget _fadeTransition(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    return FadeTransition(
      opacity: CurveTween(curve: Curves.easeInOut).animate(animation),
      child: child,
    );
  }

  /// Slide transition for push navigation
  static Widget _slideTransition(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    const begin = Offset(1.0, 0.0);
    const end = Offset.zero;
    const curve = Curves.easeOutCubic;

    var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));

    return SlideTransition(
      position: animation.drive(tween),
      child: child,
    );
  }

  /// Slide up transition for modal-like pages
  static Widget _slideUpTransition(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    const begin = Offset(0.0, 1.0);
    const end = Offset.zero;
    const curve = Curves.easeOutCubic;

    var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));

    return SlideTransition(
      position: animation.drive(tween),
      child: child,
    );
  }
}

/// Arguments for report preview page
class ReportPreviewArgs {
  final int year;
  final int month;

  const ReportPreviewArgs({
    required this.year,
    required this.month,
  });
}

/// Extension methods for easy navigation
extension GoRouterExtension on BuildContext {
  /// Navigate to add expense page
  void goToAddExpense() => go(AppRoutes.addExpense);

  /// Navigate to edit expense page
  void goToEditExpense(Expense expense) => go(
        AppRoutes.editExpense,
        extra: expense,
      );

  /// Navigate to categories page
  void goToCategories() => go(AppRoutes.categories);

  /// Navigate to report preview page
  void goToReportPreview({required int year, required int month}) => go(
        AppRoutes.reportPreview,
        extra: ReportPreviewArgs(year: year, month: month),
      );

  /// Navigate to home/dashboard
  void goToDashboard() => go(AppRoutes.home);

  /// Navigate to expenses list
  void goToExpenses() => go(AppRoutes.expenses);

  /// Navigate to statistics
  void goToStatistics() => go(AppRoutes.statistics);

  /// Navigate to settings
  void goToSettings() => go(AppRoutes.settings);

  /// Navigate to backup page
  void goToBackup() => go(AppRoutes.backup);
}
