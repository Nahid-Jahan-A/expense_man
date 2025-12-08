import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../bloc/expense_bloc.dart';
import '../bloc/expense_event.dart';
import '../bloc/expense_state.dart';
import '../../../category/presentation/bloc/category_bloc.dart';
import '../../../category/presentation/bloc/category_state.dart';
import '../../../dashboard/presentation/bloc/dashboard_bloc.dart';
import '../../../dashboard/presentation/bloc/dashboard_event.dart';
import '../../../settings/presentation/bloc/settings_bloc.dart';
import '../../../settings/presentation/bloc/settings_state.dart';
import '../../../../core/constants/enums.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../widgets/common/expense_list_item.dart';
import '../../../../widgets/common/empty_state.dart';
import 'add_edit_expense_page.dart';

/// Page displaying list of all expenses
class ExpenseListPage extends StatefulWidget {
  const ExpenseListPage({super.key});

  @override
  State<ExpenseListPage> createState() => _ExpenseListPageState();
}

class _ExpenseListPageState extends State<ExpenseListPage> {
  final _searchController = TextEditingController();
  bool _isSearching = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
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

        return BlocListener<ExpenseBloc, ExpenseState>(
          listener: (context, state) {
            if (state is ExpenseOperationSuccess) {
              // Refresh dashboard when expense is added/updated/deleted
              context.read<DashboardBloc>().add(const RefreshDashboard());
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            }
          },
          child: BlocBuilder<ExpenseBloc, ExpenseState>(
            builder: (context, state) {
              return Scaffold(
              body: CustomScrollView(
                slivers: [
                  // App Bar with search
                  SliverAppBar.large(
                    title: _isSearching
                        ? TextField(
                            controller: _searchController,
                            autofocus: true,
                            decoration: InputDecoration(
                              hintText: context.tr('search_hint'),
                              border: InputBorder.none,
                            ),
                            onChanged: (query) {
                              context.read<ExpenseBloc>().add(SearchExpenses(query));
                            },
                          )
                        : Text(context.tr('expenses')),
                    actions: [
                      IconButton(
                        icon: Icon(_isSearching ? Icons.close : Icons.search),
                        onPressed: () {
                          setState(() {
                            _isSearching = !_isSearching;
                            if (!_isSearching) {
                              _searchController.clear();
                              context.read<ExpenseBloc>().add(const SearchExpenses(''));
                            }
                          });
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.filter_list),
                        onPressed: () => _showFilterSheet(context, state, locale),
                      ),
                    ],
                  ),

                  // Filter chips if filters are applied
                  if (state is ExpenseLoaded && state.hasFilters)
                    SliverToBoxAdapter(
                      child: _buildActiveFilters(context, state, locale),
                    ),

                  // Expense list
                  if (state is ExpenseLoading)
                    const SliverFillRemaining(
                      child: Center(child: CircularProgressIndicator()),
                    )
                  else if (state is ExpenseError)
                    SliverFillRemaining(
                      child: Center(child: Text(state.message)),
                    )
                  else if (state is ExpenseLoaded)
                    if (state.filteredExpenses.isEmpty)
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
                                  final expense = state.filteredExpenses[index];
                                  final category = categoryState is CategoryLoaded
                                      ? categoryState.getCategoryById(expense.categoryId)
                                      : null;

                                  return ExpenseListItem(
                                    expense: expense,
                                    category: category,
                                    currency: currency,
                                    locale: locale,
                                    animationIndex: index,
                                    onTap: () => _editExpense(context, expense),
                                    onDelete: () {
                                      context.read<ExpenseBloc>().add(
                                            DeleteExpenseEvent(expense.id),
                                          );
                                    },
                                  );
                                },
                                childCount: state.filteredExpenses.length,
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
            },
          ),
        );
      },
    );
  }

  Widget _buildActiveFilters(
    BuildContext context,
    ExpenseLoaded state,
    String locale,
  ) {
    return Container(
      height: 50,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          if (state.filterType != ExpenseFilterType.all)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: Chip(
                label: Text(_getFilterTypeLabel(state.filterType, locale)),
                onDeleted: () {
                  context.read<ExpenseBloc>().add(const ClearFilters());
                },
                deleteIcon: const Icon(Icons.close, size: 16),
              ),
            ),
          if (state.filterCategoryId != null)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: BlocBuilder<CategoryBloc, CategoryState>(
                builder: (context, categoryState) {
                  final category = categoryState is CategoryLoaded
                      ? categoryState.getCategoryById(state.filterCategoryId!)
                      : null;
                  return Chip(
                    label: Text(category?.getName(locale) ?? ''),
                    onDeleted: () {
                      context.read<ExpenseBloc>().add(const ClearFilters());
                    },
                    deleteIcon: const Icon(Icons.close, size: 16),
                  );
                },
              ),
            ),
        ],
      ),
    ).animate().fadeIn().slideY(begin: -0.5, end: 0);
  }

  String _getFilterTypeLabel(ExpenseFilterType type, String locale) {
    final isBn = locale == 'bn';
    switch (type) {
      case ExpenseFilterType.today:
        return isBn ? 'আজ' : 'Today';
      case ExpenseFilterType.thisWeek:
        return isBn ? 'এই সপ্তাহ' : 'This Week';
      case ExpenseFilterType.thisMonth:
        return isBn ? 'এই মাস' : 'This Month';
      case ExpenseFilterType.custom:
        return isBn ? 'কাস্টম' : 'Custom';
      case ExpenseFilterType.all:
        return isBn ? 'সব' : 'All';
    }
  }

  void _showFilterSheet(BuildContext context, ExpenseState state, String locale) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        minChildSize: 0.4,
        maxChildSize: 0.9,
        expand: false,
        builder: (context, scrollController) => _FilterSheet(
          locale: locale,
          scrollController: scrollController,
        ),
      ),
    );
  }

  void _editExpense(BuildContext context, expense) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => AddEditExpensePage(expense: expense),
      ),
    );
  }
}

class _FilterSheet extends StatefulWidget {
  final String locale;
  final ScrollController scrollController;

  const _FilterSheet({
    required this.locale,
    required this.scrollController,
  });

  @override
  State<_FilterSheet> createState() => _FilterSheetState();
}

class _FilterSheetState extends State<_FilterSheet> {
  ExpenseFilterType _selectedFilter = ExpenseFilterType.all;
  ExpenseSortType _selectedSort = ExpenseSortType.dateDesc;
  String? _selectedCategoryId;
  DateTime? _customStartDate;
  DateTime? _customEndDate;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: ListView(
        controller: widget.scrollController,
        padding: const EdgeInsets.all(16),
        children: [
          // Handle
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: colorScheme.onSurfaceVariant.withAlpha(102),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Title
          Text(
            context.tr('filter_by'),
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 16),

          // Date filter
          Text(
            context.tr('date_range'),
            style: Theme.of(context).textTheme.titleSmall,
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: ExpenseFilterType.values.map((type) {
              return ChoiceChip(
                label: Text(_getFilterLabel(type)),
                selected: _selectedFilter == type,
                onSelected: (selected) async {
                  if (type == ExpenseFilterType.custom && selected) {
                    final dateRange = await showDateRangePicker(
                      context: context,
                      firstDate: DateTime(2020),
                      lastDate: DateTime.now(),
                      initialDateRange: _customStartDate != null && _customEndDate != null
                          ? DateTimeRange(start: _customStartDate!, end: _customEndDate!)
                          : null,
                    );
                    if (dateRange != null) {
                      setState(() {
                        _selectedFilter = type;
                        _customStartDate = dateRange.start;
                        _customEndDate = dateRange.end;
                      });
                    }
                  } else {
                    setState(() {
                      _selectedFilter = selected ? type : ExpenseFilterType.all;
                      if (!selected || type != ExpenseFilterType.custom) {
                        _customStartDate = null;
                        _customEndDate = null;
                      }
                    });
                  }
                },
              );
            }).toList(),
          ),
          if (_selectedFilter == ExpenseFilterType.custom && _customStartDate != null && _customEndDate != null)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                '${_formatDate(_customStartDate!)} - ${_formatDate(_customEndDate!)}',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: colorScheme.primary,
                    ),
              ),
            ),
          const SizedBox(height: 24),

          // Sort
          Text(
            context.tr('sort_by'),
            style: Theme.of(context).textTheme.titleSmall,
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: ExpenseSortType.values.map((type) {
              return ChoiceChip(
                label: Text(_getSortLabel(type)),
                selected: _selectedSort == type,
                onSelected: (selected) {
                  setState(() {
                    _selectedSort = type;
                  });
                },
              );
            }).toList(),
          ),
          const SizedBox(height: 24),

          // Category filter
          Text(
            context.tr('category'),
            style: Theme.of(context).textTheme.titleSmall,
          ),
          const SizedBox(height: 8),
          BlocBuilder<CategoryBloc, CategoryState>(
            builder: (context, state) {
              if (state is! CategoryLoaded) return const SizedBox.shrink();

              return Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  ChoiceChip(
                    label: Text(widget.locale == 'bn' ? 'সব' : 'All'),
                    selected: _selectedCategoryId == null,
                    onSelected: (selected) {
                      setState(() {
                        _selectedCategoryId = null;
                      });
                    },
                  ),
                  ...state.categories.map((category) {
                    return ChoiceChip(
                      label: Text(category.getName(widget.locale)),
                      selected: _selectedCategoryId == category.id,
                      onSelected: (selected) {
                        setState(() {
                          _selectedCategoryId = selected ? category.id : null;
                        });
                      },
                    );
                  }),
                ],
              );
            },
          ),
          const SizedBox(height: 32),

          // Action buttons
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    context.read<ExpenseBloc>().add(const ClearFilters());
                    Navigator.pop(context);
                  },
                  child: Text(context.tr('clear')),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: FilledButton(
                  onPressed: () {
                    context.read<ExpenseBloc>().add(ApplyFilter(
                          filterType: _selectedFilter,
                          categoryId: _selectedCategoryId,
                          startDate: _customStartDate,
                          endDate: _customEndDate,
                        ));
                    context.read<ExpenseBloc>().add(ApplySort(_selectedSort));
                    Navigator.pop(context);
                  },
                  child: Text(context.tr('apply')),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _getFilterLabel(ExpenseFilterType type) {
    final isBn = widget.locale == 'bn';
    switch (type) {
      case ExpenseFilterType.all:
        return isBn ? 'সব' : 'All';
      case ExpenseFilterType.today:
        return isBn ? 'আজ' : 'Today';
      case ExpenseFilterType.thisWeek:
        return isBn ? 'এই সপ্তাহ' : 'This Week';
      case ExpenseFilterType.thisMonth:
        return isBn ? 'এই মাস' : 'This Month';
      case ExpenseFilterType.custom:
        return isBn ? 'কাস্টম' : 'Custom';
    }
  }

  String _getSortLabel(ExpenseSortType type) {
    final isBn = widget.locale == 'bn';
    switch (type) {
      case ExpenseSortType.dateDesc:
        return isBn ? 'তারিখ (নতুন)' : 'Date (Newest)';
      case ExpenseSortType.dateAsc:
        return isBn ? 'তারিখ (পুরাতন)' : 'Date (Oldest)';
      case ExpenseSortType.amountDesc:
        return isBn ? 'পরিমাণ (বেশি)' : 'Amount (High)';
      case ExpenseSortType.amountAsc:
        return isBn ? 'পরিমাণ (কম)' : 'Amount (Low)';
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
