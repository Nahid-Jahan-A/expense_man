import 'dart:io';
import 'package:flutter/services.dart' show rootBundle;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:intl/intl.dart';
import '../../expense/domain/entities/expense.dart';
import '../../category/domain/entities/category.dart';
import '../../../core/constants/enums.dart';

/// Abstract class for PDF generation
abstract class PdfGenerator {
  Future<File> generateMonthlyReport({
    required List<Expense> expenses,
    required List<Category> categories,
    required MonthlySummary summary,
    required int year,
    required int month,
    required String languageCode,
    required Currency currency,
  });
}

/// Implementation of PDF generator
class PdfGeneratorImpl implements PdfGenerator {
  pw.Font? _bengaliFont;
  pw.Font? _bengaliFontBold;

  /// Load Bengali font from assets
  Future<void> _loadFonts() async {
    if (_bengaliFont != null) return;

    try {
      final fontData = await rootBundle.load('assets/fonts/NotoSansBengali-Regular.ttf');
      _bengaliFont = pw.Font.ttf(fontData);
      _bengaliFontBold = pw.Font.ttf(fontData); // Using same font for bold as well
    } catch (e) {
      // Font loading failed, will use default font
      _bengaliFont = null;
      _bengaliFontBold = null;
    }
  }

  @override
  Future<File> generateMonthlyReport({
    required List<Expense> expenses,
    required List<Category> categories,
    required MonthlySummary summary,
    required int year,
    required int month,
    required String languageCode,
    required Currency currency,
  }) async {
    // Load Bengali font
    await _loadFonts();

    final pdf = pw.Document();
    final monthDate = DateTime(year, month);
    final monthName = DateFormat('MMMM yyyy').format(monthDate);
    final isBengali = languageCode == 'bn';

    // Build category map for quick lookup
    final categoryMap = {for (var c in categories) c.id: c};

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        theme: _bengaliFont != null
            ? pw.ThemeData.withFont(
                base: _bengaliFont!,
                bold: _bengaliFontBold ?? _bengaliFont!,
              )
            : null,
        header: (context) => _buildHeader(monthName, isBengali),
        footer: (context) => _buildFooter(context, isBengali),
        build: (context) => [
          _buildSummarySection(summary, isBengali, currency),
          pw.SizedBox(height: 20),
          _buildCategoryBreakdown(summary, categories, isBengali, currency),
          pw.SizedBox(height: 20),
          _buildPaymentMethodBreakdown(summary, isBengali, currency),
          pw.SizedBox(height: 20),
          _buildExpenseTable(expenses, categoryMap, isBengali, currency),
        ],
      ),
    );

    // Save PDF
    final output = await getApplicationDocumentsDirectory();
    final fileName = 'expense_report_${year}_$month.pdf';
    final file = File('${output.path}/$fileName');
    await file.writeAsBytes(await pdf.save());

    return file;
  }

  pw.Widget _buildHeader(String monthName, bool isBengali) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          isBengali ? 'মাসিক খরচের রিপোর্ট' : 'Monthly Expense Report',
          style: pw.TextStyle(
            fontSize: 24,
            fontWeight: pw.FontWeight.bold,
            color: PdfColors.purple800,
          ),
        ),
        pw.SizedBox(height: 4),
        pw.Text(
          monthName,
          style: pw.TextStyle(
            fontSize: 16,
            color: PdfColors.grey700,
          ),
        ),
        pw.Divider(thickness: 2, color: PdfColors.purple800),
        pw.SizedBox(height: 10),
      ],
    );
  }

  pw.Widget _buildFooter(pw.Context context, bool isBengali) {
    final now = DateTime.now();
    final generatedText = isBengali
        ? 'তৈরির তারিখ: ${DateFormat('dd MMM yyyy, hh:mm a').format(now)}'
        : 'Generated on: ${DateFormat('dd MMM yyyy, hh:mm a').format(now)}';

    return pw.Column(
      children: [
        pw.Divider(color: PdfColors.grey400),
        pw.SizedBox(height: 4),
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.Text(
              generatedText,
              style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey600),
            ),
            pw.Text(
              '${isBengali ? 'পৃষ্ঠা' : 'Page'} ${context.pageNumber} / ${context.pagesCount}',
              style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey600),
            ),
          ],
        ),
      ],
    );
  }

  pw.Widget _buildSummarySection(
    MonthlySummary summary,
    bool isBengali,
    Currency currency,
  ) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(16),
      decoration: pw.BoxDecoration(
        color: PdfColors.purple50,
        borderRadius: pw.BorderRadius.circular(8),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            isBengali ? 'সারাংশ' : 'Summary',
            style: pw.TextStyle(
              fontSize: 18,
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.purple800,
            ),
          ),
          pw.SizedBox(height: 12),
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              _buildSummaryCard(
                isBengali ? 'মোট খরচ' : 'Total Expense',
                '${currency.symbol}${summary.totalAmount.toStringAsFixed(2)}',
                PdfColors.purple800,
              ),
              _buildSummaryCard(
                isBengali ? 'লেনদেন' : 'Transactions',
                summary.transactionCount.toString(),
                PdfColors.blue800,
              ),
              _buildSummaryCard(
                isBengali ? 'গড়' : 'Average',
                '${currency.symbol}${summary.averageExpense.toStringAsFixed(2)}',
                PdfColors.green800,
              ),
            ],
          ),
          pw.SizedBox(height: 8),
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              _buildSummaryCard(
                isBengali ? 'সর্বোচ্চ' : 'Highest',
                '${currency.symbol}${summary.highestExpense.toStringAsFixed(2)}',
                PdfColors.orange800,
              ),
              _buildSummaryCard(
                isBengali ? 'সর্বনিম্ন' : 'Lowest',
                '${currency.symbol}${summary.lowestExpense.toStringAsFixed(2)}',
                PdfColors.teal800,
              ),
              pw.Expanded(child: pw.SizedBox()),
            ],
          ),
        ],
      ),
    );
  }

  pw.Widget _buildSummaryCard(String label, String value, PdfColor color) {
    return pw.Expanded(
      child: pw.Container(
        margin: const pw.EdgeInsets.symmetric(horizontal: 4),
        padding: const pw.EdgeInsets.all(8),
        decoration: pw.BoxDecoration(
          color: PdfColors.white,
          borderRadius: pw.BorderRadius.circular(4),
        ),
        child: pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text(
              label,
              style: pw.TextStyle(fontSize: 10, color: PdfColors.grey600),
            ),
            pw.SizedBox(height: 4),
            pw.Text(
              value,
              style: pw.TextStyle(
                fontSize: 14,
                fontWeight: pw.FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  pw.Widget _buildCategoryBreakdown(
    MonthlySummary summary,
    List<Category> categories,
    bool isBengali,
    Currency currency,
  ) {
    final categoryMap = {for (var c in categories) c.id: c};

    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          isBengali ? 'বিভাগ অনুযায়ী খরচ' : 'Expense by Category',
          style: pw.TextStyle(
            fontSize: 16,
            fontWeight: pw.FontWeight.bold,
          ),
        ),
        pw.SizedBox(height: 8),
        pw.Table(
          border: pw.TableBorder.all(color: PdfColors.grey300),
          columnWidths: {
            0: const pw.FlexColumnWidth(2),
            1: const pw.FlexColumnWidth(1),
            2: const pw.FlexColumnWidth(1),
          },
          children: [
            pw.TableRow(
              decoration: const pw.BoxDecoration(color: PdfColors.grey200),
              children: [
                _tableHeader(isBengali ? 'বিভাগ' : 'Category'),
                _tableHeader(isBengali ? 'পরিমাণ' : 'Amount'),
                _tableHeader('%'),
              ],
            ),
            ...summary.categoryBreakdown.entries.map((entry) {
              final category = categoryMap[entry.key];
              final categoryName = category?.getName(isBengali ? 'bn' : 'en') ?? entry.key;
              final percentage = summary.totalAmount > 0
                  ? (entry.value / summary.totalAmount * 100)
                  : 0.0;

              return pw.TableRow(
                children: [
                  _tableCell(categoryName),
                  _tableCell('${currency.symbol}${entry.value.toStringAsFixed(2)}'),
                  _tableCell('${percentage.toStringAsFixed(1)}%'),
                ],
              );
            }),
          ],
        ),
      ],
    );
  }

  pw.Widget _buildPaymentMethodBreakdown(
    MonthlySummary summary,
    bool isBengali,
    Currency currency,
  ) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          isBengali ? 'পেমেন্ট পদ্ধতি অনুযায়ী' : 'Expense by Payment Method',
          style: pw.TextStyle(
            fontSize: 16,
            fontWeight: pw.FontWeight.bold,
          ),
        ),
        pw.SizedBox(height: 8),
        pw.Table(
          border: pw.TableBorder.all(color: PdfColors.grey300),
          columnWidths: {
            0: const pw.FlexColumnWidth(2),
            1: const pw.FlexColumnWidth(1),
            2: const pw.FlexColumnWidth(1),
          },
          children: [
            pw.TableRow(
              decoration: const pw.BoxDecoration(color: PdfColors.grey200),
              children: [
                _tableHeader(isBengali ? 'পদ্ধতি' : 'Method'),
                _tableHeader(isBengali ? 'পরিমাণ' : 'Amount'),
                _tableHeader('%'),
              ],
            ),
            ...summary.paymentMethodBreakdown.entries.map((entry) {
              final method = PaymentMethod.fromValue(entry.key);
              final methodName = method.getLabel(isBengali ? 'bn' : 'en');
              final percentage = summary.totalAmount > 0
                  ? (entry.value / summary.totalAmount * 100)
                  : 0.0;

              return pw.TableRow(
                children: [
                  _tableCell(methodName),
                  _tableCell('${currency.symbol}${entry.value.toStringAsFixed(2)}'),
                  _tableCell('${percentage.toStringAsFixed(1)}%'),
                ],
              );
            }),
          ],
        ),
      ],
    );
  }

  pw.Widget _buildExpenseTable(
    List<Expense> expenses,
    Map<String, Category> categoryMap,
    bool isBengali,
    Currency currency,
  ) {
    final dateFormat = DateFormat('dd/MM/yyyy');
    final timeFormat = DateFormat('hh:mm a');

    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          isBengali ? 'বিস্তারিত খরচের তালিকা' : 'Detailed Expense List',
          style: pw.TextStyle(
            fontSize: 16,
            fontWeight: pw.FontWeight.bold,
          ),
        ),
        pw.SizedBox(height: 8),
        pw.Table(
          border: pw.TableBorder.all(color: PdfColors.grey300),
          columnWidths: {
            0: const pw.FlexColumnWidth(1),
            1: const pw.FlexColumnWidth(1),
            2: const pw.FlexColumnWidth(1.5),
            3: const pw.FlexColumnWidth(1),
            4: const pw.FlexColumnWidth(1.5),
          },
          children: [
            pw.TableRow(
              decoration: const pw.BoxDecoration(color: PdfColors.grey200),
              children: [
                _tableHeader(isBengali ? 'তারিখ' : 'Date'),
                _tableHeader(isBengali ? 'সময়' : 'Time'),
                _tableHeader(isBengali ? 'বিভাগ' : 'Category'),
                _tableHeader(isBengali ? 'পরিমাণ' : 'Amount'),
                _tableHeader(isBengali ? 'নোট' : 'Note'),
              ],
            ),
            ...expenses.map((expense) {
              final category = categoryMap[expense.categoryId];
              final categoryName =
                  category?.getName(isBengali ? 'bn' : 'en') ?? expense.categoryId;

              return pw.TableRow(
                children: [
                  _tableCell(dateFormat.format(expense.dateTime)),
                  _tableCell(timeFormat.format(expense.dateTime)),
                  _tableCell(categoryName),
                  _tableCell('${currency.symbol}${expense.amount.toStringAsFixed(2)}'),
                  _tableCell(expense.note ?? '-'),
                ],
              );
            }),
          ],
        ),
      ],
    );
  }

  pw.Widget _tableHeader(String text) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(8),
      child: pw.Text(
        text,
        style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10),
      ),
    );
  }

  pw.Widget _tableCell(String text) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(8),
      child: pw.Text(
        text,
        style: const pw.TextStyle(fontSize: 9),
      ),
    );
  }
}
