import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../../features/expense/presentation/bloc/expense_bloc.dart';
import '../../features/expense/presentation/bloc/expense_event.dart';
import '../../features/expense/presentation/bloc/expense_state.dart';
import '../../features/category/presentation/bloc/category_bloc.dart';
import '../../features/category/presentation/bloc/category_state.dart';
import '../../features/settings/presentation/bloc/settings_bloc.dart';
import '../../features/settings/presentation/bloc/settings_state.dart';
import '../../core/localization/app_localizations.dart';
import '../../core/utils/currency_utils.dart';
import '../../core/theme/app_colors.dart';

/// Statistics page with charts
class StatisticsPage extends StatefulWidget {
  const StatisticsPage({super.key});

  @override
  State<StatisticsPage> createState() => _StatisticsPageState();
}

class _StatisticsPageState extends State<StatisticsPage> {
  int _selectedYear = DateTime.now().year;
  int _selectedMonth = DateTime.now().month;

  @override
  void initState() {
    super.initState();
    _loadMonthlySummary();
  }

  void _loadMonthlySummary() {
    context.read<ExpenseBloc>().add(
          LoadMonthlySummary(year: _selectedYear, month: _selectedMonth),
        );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SettingsBloc, SettingsState>(
      builder: (context, settingsState) {
        if (settingsState is! SettingsLoaded) {
          return const Center(child: CircularProgressIndicator());
        }

        final locale = settingsState.settings.languageCode;
        final currency = settingsState.currency;

        return BlocBuilder<ExpenseBloc, ExpenseState>(
          builder: (context, state) {
            return Scaffold(
              body: CustomScrollView(
                slivers: [
                  SliverAppBar.large(
                    title: Text(context.tr('statistics')),
                    actions: [
                      IconButton(
                        icon: const Icon(Icons.picture_as_pdf),
                        onPressed: () {
                          // Export PDF
                        },
                      ),
                    ],
                  ),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Month selector
                          _buildMonthSelector(context, locale),
                          const SizedBox(height: 24),

                          if (state is ExpenseLoaded &&
                              state.monthlySummary != null) ...[
                            // Summary cards
                            _buildSummaryCards(context, state, currency, locale),
                            const SizedBox(height: 24),

                            // Category breakdown chart
                            _buildCategoryChart(context, state, locale),
                            const SizedBox(height: 24),

                            // Category breakdown list
                            _buildCategoryBreakdownList(context, state, currency, locale),
                          ] else if (state is ExpenseLoading)
                            const Center(
                              child: Padding(
                                padding: EdgeInsets.all(48),
                                child: CircularProgressIndicator(),
                              ),
                            )
                          else
                            _buildEmptyState(context, locale),

                          const SizedBox(height: 100),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildMonthSelector(BuildContext context, String locale) {
    final monthDate = DateTime(_selectedYear, _selectedMonth);
    final monthFormat = DateFormat('MMMM yyyy', locale);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        IconButton(
          icon: const Icon(Icons.chevron_left),
          onPressed: () {
            setState(() {
              if (_selectedMonth == 1) {
                _selectedMonth = 12;
                _selectedYear--;
              } else {
                _selectedMonth--;
              }
            });
            _loadMonthlySummary();
          },
        ),
        GestureDetector(
          onTap: () => _showMonthPicker(context),
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
            setState(() {
              if (_selectedMonth == 12) {
                _selectedMonth = 1;
                _selectedYear++;
              } else {
                _selectedMonth++;
              }
            });
            _loadMonthlySummary();
          },
        ),
      ],
    ).animate().fadeIn().slideY(begin: -0.2, end: 0);
  }

  void _showMonthPicker(BuildContext context) async {
    final selected = await showDatePicker(
      context: context,
      initialDate: DateTime(_selectedYear, _selectedMonth),
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      initialDatePickerMode: DatePickerMode.year,
    );

    if (selected != null) {
      setState(() {
        _selectedYear = selected.year;
        _selectedMonth = selected.month;
      });
      _loadMonthlySummary();
    }
  }

  Widget _buildSummaryCards(
    BuildContext context,
    ExpenseLoaded state,
    currency,
    String locale,
  ) {
    final summary = state.monthlySummary!;

    return Row(
      children: [
        Expanded(
          child: _SummaryCard(
            title: context.tr('total'),
            value: CurrencyUtils.formatCompact(summary.totalAmount, currency: currency),
            icon: Icons.account_balance_wallet,
            color: Theme.of(context).colorScheme.primary,
            animationIndex: 0,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _SummaryCard(
            title: context.tr('average'),
            value: CurrencyUtils.formatCompact(summary.averageExpense, currency: currency),
            icon: Icons.trending_up,
            color: Colors.green,
            animationIndex: 1,
          ),
        ),
      ],
    );
  }

  Widget _buildCategoryChart(
    BuildContext context,
    ExpenseLoaded state,
    String locale,
  ) {
    final summary = state.monthlySummary!;
    if (summary.categoryBreakdown.isEmpty) {
      return const SizedBox.shrink();
    }

    return BlocBuilder<CategoryBloc, CategoryState>(
      builder: (context, categoryState) {
        final categoryMap = categoryState is CategoryLoaded
            ? {for (var c in categoryState.categories) c.id: c}
            : <String, dynamic>{};

        return Card(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  context.tr('expense_by_category'),
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  height: 200,
                  child: PieChart(
                    PieChartData(
                      sectionsSpace: 2,
                      centerSpaceRadius: 50,
                      sections: summary.categoryBreakdown.entries
                          .toList()
                          .asMap()
                          .entries
                          .map((entry) {
                        final index = entry.key;
                        final categoryEntry = entry.value;
                        final category = categoryMap[categoryEntry.key];
                        final color = category != null
                            ? Color(category.color)
                            : AppColors.chartColors[
                                index % AppColors.chartColors.length];
                        final percentage = summary.totalAmount > 0
                            ? (categoryEntry.value / summary.totalAmount * 100)
                            : 0.0;

                        return PieChartSectionData(
                          value: categoryEntry.value,
                          title: '${percentage.toStringAsFixed(0)}%',
                          color: color,
                          radius: 40,
                          titleStyle: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ).animate().fadeIn(delay: 200.ms).scale(begin: const Offset(0.9, 0.9));
      },
    );
  }

  Widget _buildCategoryBreakdownList(
    BuildContext context,
    ExpenseLoaded state,
    currency,
    String locale,
  ) {
    final summary = state.monthlySummary!;

    return BlocBuilder<CategoryBloc, CategoryState>(
      builder: (context, categoryState) {
        final categoryMap = categoryState is CategoryLoaded
            ? {for (var c in categoryState.categories) c.id: c}
            : <String, dynamic>{};

        final sortedEntries = summary.categoryBreakdown.entries.toList()
          ..sort((a, b) => b.value.compareTo(a.value));

        return Card(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  context.tr('category_breakdown'),
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 16),
                ...sortedEntries.asMap().entries.map((entry) {
                  final index = entry.key;
                  final categoryEntry = entry.value;
                  final category = categoryMap[categoryEntry.key];
                  final color = category != null
                      ? Color(category.color)
                      : AppColors.chartColors[
                          index % AppColors.chartColors.length];
                  final percentage = summary.totalAmount > 0
                      ? (categoryEntry.value / summary.totalAmount)
                      : 0.0;

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Row(
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: color.withAlpha(26),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            Icons.category,
                            color: color,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    category?.getName(locale) ??
                                        categoryEntry.key,
                                    style: Theme.of(context).textTheme.bodyMedium,
                                  ),
                                  Text(
                                    CurrencyUtils.format(
                                      categoryEntry.value,
                                      currency: currency,
                                    ),
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyMedium
                                        ?.copyWith(
                                          fontWeight: FontWeight.bold,
                                        ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              ClipRRect(
                                borderRadius: BorderRadius.circular(4),
                                child: LinearProgressIndicator(
                                  value: percentage,
                                  backgroundColor: color.withAlpha(51),
                                  valueColor:
                                      AlwaysStoppedAnimation<Color>(color),
                                  minHeight: 6,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  )
                      .animate()
                      .fadeIn(delay: Duration(milliseconds: 300 + (index * 50)))
                      .slideX(begin: 0.1, end: 0);
                }),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildEmptyState(BuildContext context, String locale) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.bar_chart_outlined,
            size: 64,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
          const SizedBox(height: 16),
          Text(
            locale == 'bn' ? 'কোনো তথ্য নেই' : 'No data available',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Text(
            locale == 'bn'
                ? 'এই মাসে কোনো খরচ রেকর্ড করা হয়নি'
                : 'No expenses recorded for this month',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
          ),
        ],
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;
  final int animationIndex;

  const _SummaryCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
    required this.animationIndex,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      color: color.withAlpha(26),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withAlpha(51),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ],
        ),
      ),
    )
        .animate()
        .fadeIn(delay: Duration(milliseconds: 100 * animationIndex))
        .scale(
          begin: const Offset(0.8, 0.8),
          delay: Duration(milliseconds: 100 * animationIndex),
          curve: Curves.easeOutBack,
        );
  }
}
