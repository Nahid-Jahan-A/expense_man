import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import '../bloc/settings_bloc.dart';
import '../bloc/settings_event.dart';
import '../bloc/settings_state.dart';
import '../../../../core/constants/enums.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../category/presentation/pages/category_management_page.dart';
import '../../../pdf_export/presentation/pages/report_preview_page.dart';

/// Settings page for app configuration
class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SettingsBloc, SettingsState>(
      builder: (context, state) {
        if (state is! SettingsLoaded) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final locale = state.settings.languageCode;

        return Scaffold(
          body: CustomScrollView(
            slivers: [
              SliverAppBar.large(
                title: Text(context.tr('settings')),
              ),
              SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // General Section
                    _buildSectionHeader(context, context.tr('general')),
                    _buildThemeTile(context, state, locale),
                    _buildLanguageTile(context, state, locale),
                    _buildCurrencyTile(context, state, locale),

                    const SizedBox(height: 24),

                    // Data Section
                    _buildSectionHeader(context, context.tr('data')),
                    _buildCategoryManagementTile(context, locale),
                    _buildExportPdfTile(context, locale),
                    _buildBackupTile(context, state, locale),

                    const SizedBox(height: 24),

                    // About Section
                    _buildSectionHeader(context, context.tr('about')),
                    _buildVersionTile(context, locale),
                    _buildPrivacyTile(context, locale),

                    const SizedBox(height: 100),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleSmall?.copyWith(
              color: Theme.of(context).colorScheme.primary,
              fontWeight: FontWeight.bold,
            ),
      ),
    ).animate().fadeIn().slideX(begin: -0.1, end: 0);
  }

  Widget _buildThemeTile(BuildContext context, SettingsLoaded state, String locale) {
    final currentTheme = AppThemeMode.fromValue(state.settings.themeMode);

    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primaryContainer,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          Icons.palette_outlined,
          color: Theme.of(context).colorScheme.onPrimaryContainer,
        ),
      ),
      title: Text(context.tr('theme')),
      subtitle: Text(currentTheme.getLabel(locale)),
      trailing: const Icon(Icons.chevron_right),
      onTap: () => _showThemeDialog(context, state, locale),
    ).animate().fadeIn(delay: 50.ms).slideX(begin: 0.1, end: 0);
  }

  Widget _buildLanguageTile(BuildContext context, SettingsLoaded state, String locale) {
    final currentLang = locale == 'bn' ? 'বাংলা' : 'English';

    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.secondaryContainer,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          Icons.language,
          color: Theme.of(context).colorScheme.onSecondaryContainer,
        ),
      ),
      title: Text(context.tr('language')),
      subtitle: Text(currentLang),
      trailing: const Icon(Icons.chevron_right),
      onTap: () => _showLanguageDialog(context, locale),
    ).animate().fadeIn(delay: 100.ms).slideX(begin: 0.1, end: 0);
  }

  Widget _buildCurrencyTile(BuildContext context, SettingsLoaded state, String locale) {
    final currency = state.currency;

    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.tertiaryContainer,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          Icons.attach_money,
          color: Theme.of(context).colorScheme.onTertiaryContainer,
        ),
      ),
      title: Text(context.tr('currency')),
      subtitle: Text('${currency.symbol} - ${currency.getName(locale)}'),
      trailing: const Icon(Icons.chevron_right),
      onTap: () => _showCurrencyDialog(context, locale),
    ).animate().fadeIn(delay: 150.ms).slideX(begin: 0.1, end: 0);
  }

  Widget _buildCategoryManagementTile(BuildContext context, String locale) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.orange.withAlpha(51),
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Icon(
          Icons.category_outlined,
          color: Colors.orange,
        ),
      ),
      title: Text(context.tr('manage_categories')),
      subtitle: Text(locale == 'bn' ? 'বিভাগ যোগ ও সম্পাদনা করুন' : 'Add and edit categories'),
      trailing: const Icon(Icons.chevron_right),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const CategoryManagementPage(),
          ),
        );
      },
    ).animate().fadeIn(delay: 200.ms).slideX(begin: 0.1, end: 0);
  }

  Widget _buildExportPdfTile(BuildContext context, String locale) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.red.withAlpha(51),
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Icon(
          Icons.picture_as_pdf,
          color: Colors.red,
        ),
      ),
      title: Text(context.tr('export_pdf')),
      subtitle: Text(locale == 'bn' ? 'মাসিক রিপোর্ট ডাউনলোড করুন' : 'Download monthly report'),
      trailing: const Icon(Icons.chevron_right),
      onTap: () => _showMonthPickerDialog(context, locale),
    ).animate().fadeIn(delay: 250.ms).slideX(begin: 0.1, end: 0);
  }

  void _showMonthPickerDialog(BuildContext context, String locale) {
    final now = DateTime.now();
    int selectedYear = now.year;
    int selectedMonth = now.month;

    showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: Text(locale == 'bn' ? 'মাস নির্বাচন করুন' : 'Select Month'),
            content: SizedBox(
              width: 280,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Year selector
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        onPressed: selectedYear > 2020
                            ? () => setState(() => selectedYear--)
                            : null,
                        icon: const Icon(Icons.chevron_left),
                      ),
                      Text(
                        selectedYear.toString(),
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      IconButton(
                        onPressed: selectedYear < now.year
                            ? () => setState(() => selectedYear++)
                            : null,
                        icon: const Icon(Icons.chevron_right),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // Month grid using Wrap
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: List.generate(12, (index) {
                      final month = index + 1;
                      final isSelected = selectedMonth == month;
                      final isFuture = selectedYear == now.year && month > now.month;
                      final monthName = DateFormat('MMM').format(DateTime(2024, month));

                      return InkWell(
                        onTap: isFuture
                            ? null
                            : () => setState(() => selectedMonth = month),
                        borderRadius: BorderRadius.circular(8),
                        child: Container(
                          width: 60,
                          height: 40,
                          decoration: BoxDecoration(
                            color: isSelected
                                ? Theme.of(context).colorScheme.primary
                                : isFuture
                                    ? Colors.grey.withAlpha(26)
                                    : null,
                            borderRadius: BorderRadius.circular(8),
                            border: !isSelected && !isFuture
                                ? Border.all(
                                    color: Theme.of(context).colorScheme.outline,
                                  )
                                : null,
                          ),
                          child: Center(
                            child: Text(
                              monthName,
                              style: TextStyle(
                                color: isSelected
                                    ? Theme.of(context).colorScheme.onPrimary
                                    : isFuture
                                        ? Colors.grey
                                        : null,
                                fontWeight:
                                    isSelected ? FontWeight.bold : FontWeight.normal,
                              ),
                            ),
                          ),
                        ),
                      );
                    }),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext),
                child: Text(locale == 'bn' ? 'বাতিল' : 'Cancel'),
              ),
              FilledButton(
                onPressed: () {
                  Navigator.pop(dialogContext);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ReportPreviewPage(
                        year: selectedYear,
                        month: selectedMonth,
                      ),
                    ),
                  );
                },
                child: Text(locale == 'bn' ? 'প্রিভিউ দেখুন' : 'View Preview'),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildBackupTile(BuildContext context, SettingsLoaded state, String locale) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.green.withAlpha(51),
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Icon(
          Icons.backup_outlined,
          color: Colors.green,
        ),
      ),
      title: Text(context.tr('backup')),
      subtitle: Text(
        state.settings.lastBackupDate != null
            ? '${locale == 'bn' ? 'সর্বশেষ:' : 'Last:'} ${_formatDate(state.settings.lastBackupDate!)}'
            : locale == 'bn'
                ? 'কোনো ব্যাকআপ নেই'
                : 'No backup yet',
      ),
      trailing: const Icon(Icons.chevron_right),
      onTap: () {
        // Show backup options
      },
    ).animate().fadeIn(delay: 300.ms).slideX(begin: 0.1, end: 0);
  }

  Widget _buildVersionTile(BuildContext context, String locale) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.blue.withAlpha(51),
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Icon(
          Icons.info_outline,
          color: Colors.blue,
        ),
      ),
      title: Text(context.tr('version')),
      subtitle: const Text('1.0.0'),
    ).animate().fadeIn(delay: 350.ms).slideX(begin: 0.1, end: 0);
  }

  Widget _buildPrivacyTile(BuildContext context, String locale) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.purple.withAlpha(51),
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Icon(
          Icons.privacy_tip_outlined,
          color: Colors.purple,
        ),
      ),
      title: Text(context.tr('privacy_policy')),
      trailing: const Icon(Icons.chevron_right),
      onTap: () {},
    ).animate().fadeIn(delay: 400.ms).slideX(begin: 0.1, end: 0);
  }

  void _showThemeDialog(BuildContext context, SettingsLoaded state, String locale) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(context.tr('theme')),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: AppThemeMode.values.map((mode) {
            return RadioListTile<AppThemeMode>(
              title: Text(mode.getLabel(locale)),
              value: mode,
              groupValue: AppThemeMode.fromValue(state.settings.themeMode),
              onChanged: (value) {
                if (value != null) {
                  context.read<SettingsBloc>().add(ChangeThemeMode(value.value));
                  Navigator.pop(context);
                }
              },
            );
          }).toList(),
        ),
      ),
    );
  }

  void _showLanguageDialog(BuildContext context, String currentLocale) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(context.tr('language')),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RadioListTile<String>(
              title: const Text('English'),
              value: 'en',
              groupValue: currentLocale,
              onChanged: (value) {
                if (value != null) {
                  context.read<SettingsBloc>().add(ChangeLanguage(value));
                  Navigator.pop(context);
                }
              },
            ),
            RadioListTile<String>(
              title: const Text('বাংলা'),
              value: 'bn',
              groupValue: currentLocale,
              onChanged: (value) {
                if (value != null) {
                  context.read<SettingsBloc>().add(ChangeLanguage(value));
                  Navigator.pop(context);
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showCurrencyDialog(BuildContext context, String locale) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(context.tr('currency')),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: Currency.values.map((currency) {
            return ListTile(
              leading: Text(
                currency.symbol,
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              title: Text(currency.getName(locale)),
              subtitle: Text(currency.code),
              onTap: () {
                context.read<SettingsBloc>().add(ChangeCurrency(currency.code));
                Navigator.pop(context);
              },
            );
          }).toList(),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
