import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import 'package:open_filex/open_filex.dart';
import 'package:share_plus/share_plus.dart';
import '../../../expense/domain/entities/expense.dart';
import '../../../expense/presentation/bloc/expense_bloc.dart';
import '../../../expense/presentation/bloc/expense_state.dart';
import '../../../category/domain/entities/category.dart';
import '../../../category/presentation/bloc/category_bloc.dart';
import '../../../category/presentation/bloc/category_state.dart';
import '../../../settings/presentation/bloc/settings_bloc.dart';
import '../../../settings/presentation/bloc/settings_state.dart';
import '../../../../core/constants/enums.dart';
import '../../../../core/utils/currency_utils.dart';
import '../bloc/pdf_export_bloc.dart';
import '../bloc/pdf_export_event.dart';
import '../bloc/pdf_export_state.dart';

/// Page to preview monthly expense report before exporting to PDF
class ReportPreviewPage extends StatefulWidget {
  final int year;
  final int month;

  const ReportPreviewPage({
    super.key,
    required this.year,
    required this.month,
  });

  @override
  State<ReportPreviewPage> createState() => _ReportPreviewPageState();
}

class _ReportPreviewPageState extends State<ReportPreviewPage> {
  List<Expense> _monthlyExpenses = [];
  MonthlySummary? _summary;

  @override
  void initState() {
    super.initState();
    _loadMonthlyData();
  }

  void _loadMonthlyData() {
    final expenseState = context.read<ExpenseBloc>().state;
    if (expenseState is ExpenseLoaded) {
      final startDate = DateTime(widget.year, widget.month, 1);
      final endDate = DateTime(widget.year, widget.month + 1, 0, 23, 59, 59);

      _monthlyExpenses = expenseState.expenses.where((e) {
        return e.dateTime.isAfter(startDate.subtract(const Duration(days: 1))) &&
            e.dateTime.isBefore(endDate.add(const Duration(days: 1)));
      }).toList();

      _monthlyExpenses.sort((a, b) => b.dateTime.compareTo(a.dateTime));

      // Calculate summary
      if (_monthlyExpenses.isNotEmpty) {
        final categoryBreakdown = <String, double>{};
        final paymentMethodBreakdown = <String, double>{};

        for (final expense in _monthlyExpenses) {
          categoryBreakdown[expense.categoryId] =
              (categoryBreakdown[expense.categoryId] ?? 0) + expense.amount;
          paymentMethodBreakdown[expense.paymentMethod] =
              (paymentMethodBreakdown[expense.paymentMethod] ?? 0) + expense.amount;
        }

        final totalAmount = _monthlyExpenses.fold<double>(
          0,
          (sum, e) => sum + e.amount,
        );

        final amounts = _monthlyExpenses.map((e) => e.amount).toList();

        _summary = MonthlySummary(
          month: DateTime(widget.year, widget.month),
          totalAmount: totalAmount,
          transactionCount: _monthlyExpenses.length,
          categoryBreakdown: categoryBreakdown,
          paymentMethodBreakdown: paymentMethodBreakdown,
          averageExpense: totalAmount / _monthlyExpenses.length,
          highestExpense: amounts.reduce((a, b) => a > b ? a : b),
          lowestExpense: amounts.reduce((a, b) => a < b ? a : b),
        );
      } else {
        _summary = MonthlySummary(
          month: DateTime(widget.year, widget.month),
          totalAmount: 0,
          transactionCount: 0,
          categoryBreakdown: {},
          paymentMethodBreakdown: {},
          averageExpense: 0,
          highestExpense: 0,
          lowestExpense: 0,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final monthDate = DateTime(widget.year, widget.month);
    final monthName = DateFormat('MMMM yyyy').format(monthDate);

    return BlocConsumer<PdfExportBloc, PdfExportState>(
      listener: (context, state) {
        if (state is PdfExportSuccess) {
          _showExportSuccessDialog(context, state.file);
        } else if (state is PdfExportError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: colorScheme.error,
            ),
          );
        }
      },
      builder: (context, pdfState) {
        return BlocBuilder<SettingsBloc, SettingsState>(
          builder: (context, settingsState) {
            if (settingsState is! SettingsLoaded) {
              return const Scaffold(
                body: Center(child: CircularProgressIndicator()),
              );
            }

            final locale = settingsState.settings.languageCode;
            final currency = settingsState.currency;

            return BlocBuilder<CategoryBloc, CategoryState>(
              builder: (context, categoryState) {
                final categories = categoryState is CategoryLoaded
                    ? categoryState.categories
                    : <Category>[];

                return Scaffold(
                  appBar: AppBar(
                    title: Text(locale == 'bn' ? 'রিপোর্ট প্রিভিউ' : 'Report Preview'),
                    actions: [
                      if (pdfState is PdfExportGenerating)
                        const Padding(
                          padding: EdgeInsets.all(16),
                          child: SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                        )
                      else
                        IconButton(
                          icon: const Icon(Icons.picture_as_pdf),
                          tooltip: locale == 'bn' ? 'PDF ডাউনলোড করুন' : 'Download PDF',
                          onPressed: _summary != null
                              ? () => _generatePdf(context, categories, locale, currency)
                              : null,
                        ),
                    ],
                  ),
                  body: _summary == null
                      ? Center(
                          child: Text(
                            locale == 'bn'
                                ? 'এই মাসে কোনো খরচ নেই'
                                : 'No expenses for this month',
                          ),
                        )
                      : _buildReportPreview(
                          context,
                          monthName,
                          categories,
                          locale,
                          currency,
                        ),
                );
              },
            );
          },
        );
      },
    );
  }

  Widget _buildReportPreview(
    BuildContext context,
    String monthName,
    List<Category> categories,
    String locale,
    Currency currency,
  ) {
    final categoryMap = {for (var c in categories) c.id: c};

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Header
        _buildHeader(context, monthName, locale).animate().fadeIn().slideY(begin: -0.2),
        const SizedBox(height: 16),

        // Summary Section
        _buildSummarySection(context, locale, currency).animate().fadeIn(delay: 100.ms),
        const SizedBox(height: 24),

        // Category Breakdown
        _buildCategoryBreakdown(context, categoryMap, locale, currency)
            .animate()
            .fadeIn(delay: 200.ms),
        const SizedBox(height: 24),

        // Payment Method Breakdown
        _buildPaymentMethodBreakdown(context, locale, currency)
            .animate()
            .fadeIn(delay: 300.ms),
        const SizedBox(height: 24),

        // Expense List
        _buildExpenseList(context, categoryMap, locale, currency)
            .animate()
            .fadeIn(delay: 400.ms),
        const SizedBox(height: 32),
      ],
    );
  }

  Widget _buildHeader(BuildContext context, String monthName, String locale) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [colorScheme.primary, colorScheme.secondary],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            locale == 'bn' ? 'মাসিক খরচের রিপোর্ট' : 'Monthly Expense Report',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: colorScheme.onPrimary,
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 4),
          Text(
            monthName,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: colorScheme.onPrimary.withAlpha(204),
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummarySection(BuildContext context, String locale, Currency currency) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.primaryContainer.withAlpha(77),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            locale == 'bn' ? 'সারাংশ' : 'Summary',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildSummaryCard(
                  context,
                  locale == 'bn' ? 'মোট খরচ' : 'Total',
                  CurrencyUtils.format(_summary!.totalAmount, currency: currency),
                  Icons.account_balance_wallet,
                  colorScheme.primary,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildSummaryCard(
                  context,
                  locale == 'bn' ? 'লেনদেন' : 'Transactions',
                  _summary!.transactionCount.toString(),
                  Icons.receipt_long,
                  colorScheme.secondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildSummaryCard(
                  context,
                  locale == 'bn' ? 'গড়' : 'Average',
                  CurrencyUtils.format(_summary!.averageExpense, currency: currency),
                  Icons.trending_flat,
                  Colors.green,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildSummaryCard(
                  context,
                  locale == 'bn' ? 'সর্বোচ্চ' : 'Highest',
                  CurrencyUtils.format(_summary!.highestExpense, currency: currency),
                  Icons.trending_up,
                  Colors.orange,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildSummaryCard(
                  context,
                  locale == 'bn' ? 'সর্বনিম্ন' : 'Lowest',
                  CurrencyUtils.format(_summary!.lowestExpense, currency: currency),
                  Icons.trending_down,
                  Colors.teal,
                ),
              ),
              const Expanded(child: SizedBox()),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(
    BuildContext context,
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(13),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withAlpha(26),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: color,
                      ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryBreakdown(
    BuildContext context,
    Map<String, Category> categoryMap,
    String locale,
    Currency currency,
  ) {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          locale == 'bn' ? 'বিভাগ অনুযায়ী খরচ' : 'Expense by Category',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: colorScheme.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: colorScheme.outlineVariant),
          ),
          child: Column(
            children: [
              // Header
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainerHighest,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                ),
                child: Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: Text(
                        locale == 'bn' ? 'বিভাগ' : 'Category',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    Expanded(
                      child: Text(
                        locale == 'bn' ? 'পরিমাণ' : 'Amount',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                        textAlign: TextAlign.right,
                      ),
                    ),
                    const SizedBox(width: 16),
                    SizedBox(
                      width: 50,
                      child: Text(
                        '%',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                        textAlign: TextAlign.right,
                      ),
                    ),
                  ],
                ),
              ),
              // Rows
              ..._summary!.categoryBreakdown.entries.map((entry) {
                final category = categoryMap[entry.key];
                final percentage = _summary!.totalAmount > 0
                    ? (entry.value / _summary!.totalAmount * 100)
                    : 0.0;

                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    border: Border(
                      top: BorderSide(color: colorScheme.outlineVariant),
                    ),
                  ),
                  child: Row(
                    children: [
                      if (category != null)
                        Container(
                          width: 8,
                          height: 8,
                          margin: const EdgeInsets.only(right: 8),
                          decoration: BoxDecoration(
                            color: Color(category.color),
                            shape: BoxShape.circle,
                          ),
                        ),
                      Expanded(
                        flex: 2,
                        child: Text(category?.getName(locale) ?? entry.key),
                      ),
                      Expanded(
                        child: Text(
                          CurrencyUtils.format(entry.value, currency: currency),
                          textAlign: TextAlign.right,
                        ),
                      ),
                      const SizedBox(width: 16),
                      SizedBox(
                        width: 50,
                        child: Text(
                          '${percentage.toStringAsFixed(1)}%',
                          textAlign: TextAlign.right,
                          style: TextStyle(color: colorScheme.onSurfaceVariant),
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPaymentMethodBreakdown(
    BuildContext context,
    String locale,
    Currency currency,
  ) {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          locale == 'bn' ? 'পেমেন্ট পদ্ধতি অনুযায়ী' : 'Expense by Payment Method',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: colorScheme.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: colorScheme.outlineVariant),
          ),
          child: Column(
            children: [
              // Header
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainerHighest,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                ),
                child: Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: Text(
                        locale == 'bn' ? 'পদ্ধতি' : 'Method',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    Expanded(
                      child: Text(
                        locale == 'bn' ? 'পরিমাণ' : 'Amount',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                        textAlign: TextAlign.right,
                      ),
                    ),
                    const SizedBox(width: 16),
                    SizedBox(
                      width: 50,
                      child: Text(
                        '%',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                        textAlign: TextAlign.right,
                      ),
                    ),
                  ],
                ),
              ),
              // Rows
              ..._summary!.paymentMethodBreakdown.entries.map((entry) {
                final method = PaymentMethod.fromValue(entry.key);
                final percentage = _summary!.totalAmount > 0
                    ? (entry.value / _summary!.totalAmount * 100)
                    : 0.0;

                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    border: Border(
                      top: BorderSide(color: colorScheme.outlineVariant),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(_getPaymentIcon(entry.key), size: 18),
                      const SizedBox(width: 8),
                      Expanded(
                        flex: 2,
                        child: Text(method.getLabel(locale)),
                      ),
                      Expanded(
                        child: Text(
                          CurrencyUtils.format(entry.value, currency: currency),
                          textAlign: TextAlign.right,
                        ),
                      ),
                      const SizedBox(width: 16),
                      SizedBox(
                        width: 50,
                        child: Text(
                          '${percentage.toStringAsFixed(1)}%',
                          textAlign: TextAlign.right,
                          style: TextStyle(color: colorScheme.onSurfaceVariant),
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildExpenseList(
    BuildContext context,
    Map<String, Category> categoryMap,
    String locale,
    Currency currency,
  ) {
    final colorScheme = Theme.of(context).colorScheme;
    final dateFormat = DateFormat('dd MMM');
    final timeFormat = DateFormat('hh:mm a');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          locale == 'bn' ? 'বিস্তারিত খরচের তালিকা' : 'Detailed Expense List',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: colorScheme.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: colorScheme.outlineVariant),
          ),
          child: Column(
            children: [
              // Header
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainerHighest,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                ),
                child: Row(
                  children: [
                    SizedBox(
                      width: 60,
                      child: Text(
                        locale == 'bn' ? 'তারিখ' : 'Date',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                      ),
                    ),
                    Expanded(
                      child: Text(
                        locale == 'bn' ? 'বিভাগ' : 'Category',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                      ),
                    ),
                    SizedBox(
                      width: 80,
                      child: Text(
                        locale == 'bn' ? 'পরিমাণ' : 'Amount',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                        textAlign: TextAlign.right,
                      ),
                    ),
                  ],
                ),
              ),
              // Rows
              ...(_monthlyExpenses.length > 20
                      ? _monthlyExpenses.take(20)
                      : _monthlyExpenses)
                  .map((expense) {
                final category = categoryMap[expense.categoryId];

                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  decoration: BoxDecoration(
                    border: Border(
                      top: BorderSide(color: colorScheme.outlineVariant),
                    ),
                  ),
                  child: Row(
                    children: [
                      SizedBox(
                        width: 60,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              dateFormat.format(expense.dateTime),
                              style: const TextStyle(fontSize: 11),
                            ),
                            Text(
                              timeFormat.format(expense.dateTime),
                              style: TextStyle(
                                fontSize: 10,
                                color: colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              category?.getName(locale) ?? expense.categoryId,
                              style: const TextStyle(fontSize: 13),
                            ),
                            if (expense.note?.isNotEmpty ?? false)
                              Text(
                                expense.note!,
                                style: TextStyle(
                                  fontSize: 11,
                                  color: colorScheme.onSurfaceVariant,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                          ],
                        ),
                      ),
                      SizedBox(
                        width: 80,
                        child: Text(
                          CurrencyUtils.format(expense.amount, currency: currency),
                          textAlign: TextAlign.right,
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: colorScheme.primary,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }),
              if (_monthlyExpenses.length > 20)
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    border: Border(
                      top: BorderSide(color: colorScheme.outlineVariant),
                    ),
                  ),
                  child: Text(
                    locale == 'bn'
                        ? '... এবং আরো ${_monthlyExpenses.length - 20}টি খরচ (PDF-এ সব দেখুন)'
                        : '... and ${_monthlyExpenses.length - 20} more (view all in PDF)',
                    style: TextStyle(
                      color: colorScheme.onSurfaceVariant,
                      fontStyle: FontStyle.italic,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  IconData _getPaymentIcon(String method) {
    switch (method) {
      case 'cash':
        return Icons.money;
      case 'mobile_banking':
        return Icons.phone_android;
      case 'card':
        return Icons.credit_card;
      default:
        return Icons.payment;
    }
  }

  void _generatePdf(
    BuildContext context,
    List<Category> categories,
    String locale,
    Currency currency,
  ) {
    context.read<PdfExportBloc>().add(GenerateMonthlyReport(
          expenses: _monthlyExpenses,
          categories: categories,
          summary: _summary!,
          year: widget.year,
          month: widget.month,
          languageCode: locale,
          currency: currency,
        ));
  }

  void _showExportSuccessDialog(BuildContext context, File file) {
    final locale = Localizations.localeOf(context).languageCode;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        icon: const Icon(Icons.check_circle, color: Colors.green, size: 48),
        title: Text(locale == 'bn' ? 'PDF তৈরি হয়েছে!' : 'PDF Generated!'),
        content: Text(
          locale == 'bn'
              ? 'আপনার রিপোর্ট সফলভাবে তৈরি হয়েছে।'
              : 'Your report has been generated successfully.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(locale == 'bn' ? 'বন্ধ করুন' : 'Close'),
          ),
          TextButton.icon(
            onPressed: () {
              Navigator.pop(context);
              Share.shareXFiles([XFile(file.path)]);
            },
            icon: const Icon(Icons.share),
            label: Text(locale == 'bn' ? 'শেয়ার' : 'Share'),
          ),
          FilledButton.icon(
            onPressed: () {
              Navigator.pop(context);
              OpenFilex.open(file.path);
            },
            icon: const Icon(Icons.open_in_new),
            label: Text(locale == 'bn' ? 'খুলুন' : 'Open'),
          ),
        ],
      ),
    );
  }
}
