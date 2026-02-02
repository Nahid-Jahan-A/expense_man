import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../core/localization/app_localizations.dart';
import '../core/router/app_router.dart';

/// Home page with bottom navigation
class HomePage extends StatefulWidget {
  final Widget child;

  const HomePage({super.key, required this.child});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
  late final AnimationController _fabAnimationController;

  @override
  void initState() {
    super.initState();
    _fabAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
  }

  @override
  void dispose() {
    _fabAnimationController.dispose();
    super.dispose();
  }

  int _calculateSelectedIndex(BuildContext context) {
    final String location = GoRouterState.of(context).uri.path;
    if (location.startsWith(AppRoutes.expenses)) {
      return 1;
    }
    if (location.startsWith(AppRoutes.statistics)) {
      return 2;
    }
    if (location.startsWith(AppRoutes.settings)) {
      return 3;
    }
    return 0; // Default to dashboard
  }

  void _onItemTapped(int index, BuildContext context) {
    switch (index) {
      case 0:
        context.go(AppRoutes.home);
        break;
      case 1:
        context.go(AppRoutes.expenses);
        break;
      case 2:
        context.go(AppRoutes.statistics);
        break;
      case 3:
        context.go(AppRoutes.settings);
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final selectedIndex = _calculateSelectedIndex(context);

    return Scaffold(
      body: widget.child,
      floatingActionButton: _buildFab(context),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: _buildBottomNavBar(context, selectedIndex),
    );
  }

  Widget _buildFab(BuildContext context) {
    return FloatingActionButton(
      onPressed: () => context.push(AppRoutes.addExpense),
      elevation: 2,
      child: const Icon(Icons.add),
    )
        .animate(
          onPlay: (controller) => controller.forward(),
        )
        .scale(
          begin: const Offset(0, 0),
          end: const Offset(1, 1),
          duration: 300.ms,
          curve: Curves.easeOutBack,
        );
  }

  Widget _buildBottomNavBar(BuildContext context, int selectedIndex) {
    return NavigationBar(
      selectedIndex: selectedIndex,
      onDestinationSelected: (index) => _onItemTapped(index, context),
      destinations: [
        NavigationDestination(
          icon: const Icon(Icons.dashboard_outlined),
          selectedIcon: const Icon(Icons.dashboard),
          label: context.tr('nav_home'),
        ),
        NavigationDestination(
          icon: const Icon(Icons.receipt_long_outlined),
          selectedIcon: const Icon(Icons.receipt_long),
          label: context.tr('nav_expenses'),
        ),
        NavigationDestination(
          icon: const Icon(Icons.bar_chart_outlined),
          selectedIcon: const Icon(Icons.bar_chart),
          label: context.tr('nav_statistics'),
        ),
        NavigationDestination(
          icon: const Icon(Icons.settings_outlined),
          selectedIcon: const Icon(Icons.settings),
          label: context.tr('nav_settings'),
        ),
      ],
    );
  }
}
