import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../bloc/dashboard_bloc.dart';
import '../bloc/dashboard_event.dart';
import '../bloc/dashboard_state.dart';
import '../../../category/presentation/bloc/category_bloc.dart';
import '../../../category/presentation/bloc/category_state.dart';
import '../../../settings/presentation/bloc/settings_bloc.dart';
import '../../../settings/presentation/bloc/settings_state.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/utils/currency_utils.dart';
import '../../../../core/router/app_router.dart';
import '../../../../widgets/common/summary_card.dart';
import '../../../../widgets/common/expense_list_item.dart';
import '../../../../widgets/common/empty_state.dart';

/// Dashboard page showing overview of expenses
class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SettingsBloc, SettingsState>(
      builder: (context, settingsState) {
        if (settingsState is! SettingsLoaded) {
          return const Center(child: CircularProgressIndicator());
        }

        final locale = settingsState.settings.languageCode;
        final currency = settingsState.currency;

        return BlocBuilder<DashboardBloc, DashboardState>(
          builder: (context, state) {
            if (state is DashboardLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state is DashboardError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.error_outline,
                      size: 64,
                      color: Theme.of(context).colorScheme.error,
                    ),
                    const SizedBox(height: 16),
                    Text(state.message),
                    const SizedBox(height: 16),
                    FilledButton(
                      onPressed: () {
                        context.read<DashboardBloc>().add(const LoadDashboard());
                      },
                      child: Text(context.tr('retry')),
                    ),
                  ],
                ),
              );
            }

            if (state is DashboardLoaded) {
              return RefreshIndicator(
                onRefresh: () async {
                  context.read<DashboardBloc>().add(const RefreshDashboard());
                },
                child: CustomScrollView(
                  slivers: [
                    SliverAppBar.large(
                      title: Text(context.tr('dashboard')),
                      actions: [
                        IconButton(
                          icon: const Icon(Icons.notifications_outlined),
                          onPressed: () {},
                        ),
                      ],
                    ),
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Month selector
                            _buildMonthSelector(context, state, locale),
                            const SizedBox(height: 16),

                            // Summary cards
                            _buildSummarySection(context, state, currency, locale),
                            const SizedBox(height: 24),

                            // Recent expenses header
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  context.tr('recent_expenses'),
                                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                        fontWeight: FontWeight.bold,
                                      ),
                                ),
                                TextButton(
                                  onPressed: () => context.go(AppRoutes.expenses),
                                  child: Text(context.tr('view_all')),
                                ),
                              ],
                            ).animate().fadeIn(delay: 400.ms),
                          ],
                        ),
                      ),
                    ),

                    // Recent expenses list
                    if (state.recentExpenses.isEmpty)
                      SliverFillRemaining(
                        hasScrollBody: false,
                        child: EmptyState(
                          icon: Icons.receipt_long_outlined,
                          title: context.tr('no_expenses'),
                          description: context.tr('no_expenses_desc'),
                        ),
                      )
                    else
                      SliverPadding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        sliver: BlocBuilder<CategoryBloc, CategoryState>(
                          builder: (context, categoryState) {
                            return SliverList(
                              delegate: SliverChildBuilderDelegate(
                                (context, index) {
                                  final expense = state.recentExpenses[index];
                                  final category = categoryState is CategoryLoaded
                                      ? categoryState.getCategoryById(expense.categoryId)
                                      : null;

                                  return ExpenseListItem(
                                    expense: expense,
                                    category: category,
                                    currency: currency,
                                    locale: locale,
                                    animationIndex: index,
                                    onTap: () => context.push(AppRoutes.editExpense, extra: expense),
                                  );
                                },
                                childCount: state.recentExpenses.length,
                              ),
                            );
                          },
                        ),
                      ),

                    // Bottom padding
                    const SliverToBoxAdapter(
                      child: SizedBox(height: 100),
                    ),
                  ],
                ),
              );
            }

            return const SizedBox.shrink();
          },
        );
      },
    );
  }

  Widget _buildMonthSelector(
    BuildContext context,
    DashboardLoaded state,
    String locale,
  ) {
    final monthDate = DateTime(state.selectedYear, state.selectedMonth);
    final monthFormat = DateFormat('MMMM yyyy', locale);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        IconButton(
          icon: const Icon(Icons.chevron_left),
          onPressed: () {
            final prevMonth = DateTime(state.selectedYear, state.selectedMonth - 1);
            context.read<DashboardBloc>().add(ChangeMonth(
                  year: prevMonth.year,
                  month: prevMonth.month,
                ));
          },
        ),
        GestureDetector(
          onTap: () => _showMonthPicker(context, state),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.calendar_month,
                  size: 18,
                  color: Theme.of(context).colorScheme.onPrimaryContainer,
                ),
                const SizedBox(width: 8),
                Text(
                  monthFormat.format(monthDate),
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onPrimaryContainer,
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ],
            ),
          ),
        ),
        IconButton(
          icon: const Icon(Icons.chevron_right),
          onPressed: () {
            final nextMonth = DateTime(state.selectedYear, state.selectedMonth + 1);
            context.read<DashboardBloc>().add(ChangeMonth(
                  year: nextMonth.year,
                  month: nextMonth.month,
                ));
          },
        ),
      ],
    ).animate().fadeIn().slideY(begin: -0.2, end: 0);
  }

  void _showMonthPicker(BuildContext context, DashboardLoaded state) async {
    final selected = await showDatePicker(
      context: context,
      initialDate: DateTime(state.selectedYear, state.selectedMonth),
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      initialDatePickerMode: DatePickerMode.year,
    );

    if (selected != null && context.mounted) {
      context.read<DashboardBloc>().add(ChangeMonth(
            year: selected.year,
            month: selected.month,
          ));
    }
  }

  Widget _buildSummarySection(
    BuildContext context,
    DashboardLoaded state,
    currency,
    String locale,
  ) {
    return Column(
      children: [
        // Main total card
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Theme.of(context).colorScheme.primary,
                Theme.of(context).colorScheme.primary.withAlpha(204),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                context.tr('total_expense'),
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onPrimary.withAlpha(204),
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                CurrencyUtils.format(
                  state.monthlySummary.totalAmount,
                  currency: currency,
                ),
                style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                      color: Theme.of(context).colorScheme.onPrimary,
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                '${state.monthlySummary.transactionCount} ${context.tr('transactions')}',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onPrimary.withAlpha(179),
                    ),
              ),
            ],
          ),
        )
            .animate()
            .fadeIn(delay: 100.ms)
            .scale(begin: const Offset(0.95, 0.95), curve: Curves.easeOutBack),

        const SizedBox(height: 16),

        // Quick stats
        Row(
          children: [
            Expanded(
              child: SummaryCard(
                title: context.tr('today'),
                value: CurrencyUtils.formatCompact(state.todayTotal, currency: currency),
                icon: Icons.today,
                iconColor: Colors.orange,
                animationIndex: 1,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: SummaryCard(
                title: context.tr('this_week'),
                value: CurrencyUtils.formatCompact(state.weekTotal, currency: currency),
                icon: Icons.date_range,
                iconColor: Colors.blue,
                animationIndex: 2,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
