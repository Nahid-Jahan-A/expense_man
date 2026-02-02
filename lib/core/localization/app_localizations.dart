import 'package:flutter/material.dart';

/// Application localization support
class AppLocalizations {
  final Locale locale;

  AppLocalizations(this.locale);

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

  static const List<Locale> supportedLocales = [
    Locale('en'),
    Locale('bn'),
  ];

  bool get isEnglish => locale.languageCode == 'en';
  bool get isBengali => locale.languageCode == 'bn';

  /// Translation map
  static final Map<String, Map<String, String>> _localizedValues = {
    'en': {
      // App
      'app_name': 'Expense Manager',

      // Navigation
      'nav_home': 'Home',
      'nav_expenses': 'Expenses',
      'nav_statistics': 'Statistics',
      'nav_settings': 'Settings',

      // Dashboard
      'dashboard': 'Dashboard',
      'total_expense': 'Total Expense',
      'this_month': 'This Month',
      'today': 'Today',
      'this_week': 'This Week',
      'recent_expenses': 'Recent Expenses',
      'view_all': 'View All',
      'no_expenses': 'No expenses yet',
      'no_expenses_desc': 'Start tracking your expenses by tapping the + button',

      // Expenses
      'expenses': 'Expenses',
      'add_expense': 'Add Expense',
      'edit_expense': 'Edit Expense',
      'delete_expense': 'Delete Expense',
      'delete_expense_confirm': 'Are you sure you want to delete this expense?',
      'amount': 'Amount',
      'category': 'Category',
      'date': 'Date',
      'time': 'Time',
      'note': 'Note',
      'note_optional': 'Note (optional)',
      'payment_method': 'Payment Method',
      'enter_amount': 'Enter amount',
      'select_category': 'Select Category',
      'select_date': 'Select Date',
      'select_time': 'Select Time',
      'expense_added': 'Expense added successfully',
      'expense_updated': 'Expense updated successfully',
      'expense_deleted': 'Expense deleted successfully',
      'invalid_amount': 'Please enter a valid amount',
      'select_category_error': 'Please select a category',

      // Categories
      'categories': 'Categories',
      'manage_categories': 'Manage Categories',
      'add_category': 'Add Category',
      'edit_category': 'Edit Category',
      'delete_category': 'Delete Category',
      'delete_category_confirm': 'Are you sure you want to delete this category?',
      'category_name': 'Category Name',
      'category_icon': 'Icon',
      'category_color': 'Color',
      'select_icon': 'Select Icon',
      'select_color': 'Select Color',
      'category_added': 'Category added successfully',
      'category_updated': 'Category updated successfully',
      'category_deleted': 'Category deleted successfully',
      'enter_category_name': 'Please enter category name',
      'default_categories': 'Default Categories',
      'custom_categories': 'Custom Categories',

      // Default Category Names
      'cat_medical': 'Medical',
      'cat_clothing': 'Clothing',
      'cat_rent': 'Rent',
      'cat_bills': 'Bills',
      'cat_transport': 'Transport',
      'cat_food': 'Food',
      'cat_shopping': 'Shopping',
      'cat_entertainment': 'Entertainment',
      'cat_other': 'Other',

      // Payment Methods
      'pay_cash': 'Cash',
      'pay_mobile_banking': 'Mobile Banking',
      'pay_card': 'Card',

      // Statistics
      'statistics': 'Statistics',
      'monthly_summary': 'Monthly Summary',
      'category_breakdown': 'Category Breakdown',
      'daily_trend': 'Daily Trend',
      'expense_by_category': 'Expense by Category',
      'expense_by_payment': 'Expense by Payment Method',
      'total': 'Total',
      'average': 'Average',
      'highest': 'Highest',
      'lowest': 'Lowest',

      // Filter
      'filter': 'Filter',
      'filter_by': 'Filter By',
      'date_range': 'Date Range',
      'amount_range': 'Amount Range',
      'from': 'From',
      'to': 'To',
      'min_amount': 'Min Amount',
      'max_amount': 'Max Amount',
      'apply': 'Apply',
      'clear': 'Clear',
      'reset': 'Reset',

      // Sort
      'sort': 'Sort',
      'sort_by': 'Sort By',
      'date_newest': 'Date (Newest)',
      'date_oldest': 'Date (Oldest)',
      'amount_highest': 'Amount (Highest)',
      'amount_lowest': 'Amount (Lowest)',

      // Settings
      'settings': 'Settings',
      'general': 'General',
      'appearance': 'Appearance',
      'language': 'Language',
      'theme': 'Theme',
      'currency': 'Currency',
      'theme_light': 'Light',
      'theme_dark': 'Dark',
      'theme_system': 'System',
      'data': 'Data',
      'backup': 'Backup',
      'restore': 'Restore',
      'backup_data': 'Backup Data',
      'restore_data': 'Restore Data',
      'export_pdf': 'Export PDF',
      'about': 'About',
      'version': 'Version',
      'privacy_policy': 'Privacy Policy',
      'terms_of_service': 'Terms of Service',

      // Backup & Restore
      'backup_restore': 'Backup & Restore',
      'local_backup': 'Local Backup',
      'local_backup_desc': 'Export your data to a file that you can save anywhere',
      'cloud_backup': 'Cloud Backup',
      'cloud_backup_desc': 'Automatically backup to your cloud account',
      'export_data': 'Export Data',
      'export_data_desc': 'Create a backup file and save it',
      'import_data': 'Import Data',
      'import_data_desc': 'Restore from a backup file',
      'coming_soon': 'Coming Soon',
      'enable_auto_backup': 'Enable Auto-Backup',
      'enable_auto_backup_desc': 'Sync your data to the cloud automatically',
      'restore_from_cloud': 'Restore from Cloud',
      'restore_from_cloud_desc': 'Download and restore your cloud backup',
      'about_backups': 'About Backups',
      'backup_info_1': 'Your backup includes all expenses, categories, and settings',
      'backup_info_2': 'Backup files are saved in JSON format for portability',
      'backup_info_3': 'You can import backups on any device with this app',
      'backup_info_4': 'Choose "Replace" to overwrite existing data, or "Merge" to combine',
      'import_backup': 'Import Backup',
      'import_backup_question': 'How would you like to import the backup data?',
      'replace_all': 'Replace All',
      'replace_all_desc': 'Delete existing expenses and import all data from the backup file. Your current data will be replaced.',
      'merge': 'Merge',
      'merge_desc': 'Keep your existing data and add new items from the backup. Duplicates will be skipped.',
      'backup_created': 'Backup Created!',
      'backup_created_desc': 'Your backup has been prepared and shared. Save it to a safe location.',
      'import_complete': 'Import Complete!',
      'import_replace_desc': 'Your data has been replaced with the backup.',
      'import_merge_desc': 'The backup has been merged with your existing data.',
      'expenses_imported': 'Expenses imported',
      'expenses_skipped': 'Expenses skipped',
      'categories_imported': 'Categories imported',
      'categories_skipped': 'Categories skipped',
      'done': 'Done',
      'transactions': 'transactions',
      'last_backup': 'Last:',
      'no_backup_yet': 'No backup yet',
      'save_locally': 'Save Locally',
      'save_locally_desc': 'Save backup file to Downloads/expense_backup folder',
      'share_export': 'Share / Export',
      'share_export_desc': 'Share backup via apps like Google Drive, Email, etc.',
      'backup_saved': 'Backup Saved!',
      'backup_saved_desc': 'Your backup has been saved to:',
      'import_success': 'Import Successful!',
      'choose_export_method': 'Choose Export Method',
      'how_to_export': 'How would you like to export your backup?',

      // PDF
      'export': 'Export',
      'monthly_report': 'Monthly Report',
      'expense_report': 'Expense Report',
      'generated_on': 'Generated on',
      'summary': 'Summary',
      'details': 'Details',
      'pdf_exported': 'PDF exported successfully',
      'pdf_export_failed': 'Failed to export PDF',

      // Common
      'save': 'Save',
      'cancel': 'Cancel',
      'delete': 'Delete',
      'edit': 'Edit',
      'add': 'Add',
      'ok': 'OK',
      'yes': 'Yes',
      'no': 'No',
      'confirm': 'Confirm',
      'error': 'Error',
      'success': 'Success',
      'warning': 'Warning',
      'loading': 'Loading...',
      'search': 'Search',
      'search_hint': 'Search expenses...',
      'no_data': 'No data available',
      'retry': 'Retry',
      'close': 'Close',
    },
    'bn': {
      // App
      'app_name': 'খরচ ম্যানেজার',

      // Navigation
      'nav_home': 'হোম',
      'nav_expenses': 'খরচ',
      'nav_statistics': 'পরিসংখ্যান',
      'nav_settings': 'সেটিংস',

      // Dashboard
      'dashboard': 'ড্যাশবোর্ড',
      'total_expense': 'মোট খরচ',
      'this_month': 'এই মাস',
      'today': 'আজ',
      'this_week': 'এই সপ্তাহ',
      'recent_expenses': 'সাম্প্রতিক খরচ',
      'view_all': 'সব দেখুন',
      'no_expenses': 'কোনো খরচ নেই',
      'no_expenses_desc': '+ বাটনে ট্যাপ করে আপনার খরচ ট্র্যাক করা শুরু করুন',

      // Expenses
      'expenses': 'খরচসমূহ',
      'add_expense': 'খরচ যোগ করুন',
      'edit_expense': 'খরচ সম্পাদনা',
      'delete_expense': 'খরচ মুছুন',
      'delete_expense_confirm': 'আপনি কি নিশ্চিত যে এই খরচটি মুছতে চান?',
      'amount': 'পরিমাণ',
      'category': 'বিভাগ',
      'date': 'তারিখ',
      'time': 'সময়',
      'note': 'নোট',
      'note_optional': 'নোট (ঐচ্ছিক)',
      'payment_method': 'পেমেন্ট পদ্ধতি',
      'enter_amount': 'পরিমাণ লিখুন',
      'select_category': 'বিভাগ নির্বাচন করুন',
      'select_date': 'তারিখ নির্বাচন করুন',
      'select_time': 'সময় নির্বাচন করুন',
      'expense_added': 'খরচ সফলভাবে যোগ করা হয়েছে',
      'expense_updated': 'খরচ সফলভাবে আপডেট করা হয়েছে',
      'expense_deleted': 'খরচ সফলভাবে মুছে ফেলা হয়েছে',
      'invalid_amount': 'অনুগ্রহ করে একটি বৈধ পরিমাণ লিখুন',
      'select_category_error': 'অনুগ্রহ করে একটি বিভাগ নির্বাচন করুন',

      // Categories
      'categories': 'বিভাগসমূহ',
      'manage_categories': 'বিভাগ ব্যবস্থাপনা',
      'add_category': 'বিভাগ যোগ করুন',
      'edit_category': 'বিভাগ সম্পাদনা',
      'delete_category': 'বিভাগ মুছুন',
      'delete_category_confirm': 'আপনি কি নিশ্চিত যে এই বিভাগটি মুছতে চান?',
      'category_name': 'বিভাগের নাম',
      'category_icon': 'আইকন',
      'category_color': 'রঙ',
      'select_icon': 'আইকন নির্বাচন',
      'select_color': 'রঙ নির্বাচন',
      'category_added': 'বিভাগ সফলভাবে যোগ করা হয়েছে',
      'category_updated': 'বিভাগ সফলভাবে আপডেট করা হয়েছে',
      'category_deleted': 'বিভাগ সফলভাবে মুছে ফেলা হয়েছে',
      'enter_category_name': 'অনুগ্রহ করে বিভাগের নাম লিখুন',
      'default_categories': 'ডিফল্ট বিভাগ',
      'custom_categories': 'কাস্টম বিভাগ',

      // Default Category Names
      'cat_medical': 'চিকিৎসা',
      'cat_clothing': 'পোশাক',
      'cat_rent': 'ভাড়া',
      'cat_bills': 'বিল',
      'cat_transport': 'পরিবহন',
      'cat_food': 'খাবার',
      'cat_shopping': 'কেনাকাটা',
      'cat_entertainment': 'বিনোদন',
      'cat_other': 'অন্যান্য',

      // Payment Methods
      'pay_cash': 'নগদ',
      'pay_mobile_banking': 'মোবাইল ব্যাংকিং',
      'pay_card': 'কার্ড',

      // Statistics
      'statistics': 'পরিসংখ্যান',
      'monthly_summary': 'মাসিক সারাংশ',
      'category_breakdown': 'বিভাগ অনুযায়ী বিশ্লেষণ',
      'daily_trend': 'দৈনিক প্রবণতা',
      'expense_by_category': 'বিভাগ অনুযায়ী খরচ',
      'expense_by_payment': 'পেমেন্ট পদ্ধতি অনুযায়ী খরচ',
      'total': 'মোট',
      'average': 'গড়',
      'highest': 'সর্বোচ্চ',
      'lowest': 'সর্বনিম্ন',

      // Filter
      'filter': 'ফিল্টার',
      'filter_by': 'ফিল্টার করুন',
      'date_range': 'তারিখের পরিসীমা',
      'amount_range': 'পরিমাণের পরিসীমা',
      'from': 'থেকে',
      'to': 'পর্যন্ত',
      'min_amount': 'সর্বনিম্ন পরিমাণ',
      'max_amount': 'সর্বোচ্চ পরিমাণ',
      'apply': 'প্রয়োগ করুন',
      'clear': 'মুছুন',
      'reset': 'রিসেট',

      // Sort
      'sort': 'সাজান',
      'sort_by': 'সাজান অনুযায়ী',
      'date_newest': 'তারিখ (নতুন)',
      'date_oldest': 'তারিখ (পুরাতন)',
      'amount_highest': 'পরিমাণ (সর্বোচ্চ)',
      'amount_lowest': 'পরিমাণ (সর্বনিম্ন)',

      // Settings
      'settings': 'সেটিংস',
      'general': 'সাধারণ',
      'appearance': 'চেহারা',
      'language': 'ভাষা',
      'theme': 'থিম',
      'currency': 'মুদ্রা',
      'theme_light': 'লাইট',
      'theme_dark': 'ডার্ক',
      'theme_system': 'সিস্টেম',
      'data': 'ডেটা',
      'backup': 'ব্যাকআপ',
      'restore': 'পুনরুদ্ধার',
      'backup_data': 'ডেটা ব্যাকআপ',
      'restore_data': 'ডেটা পুনরুদ্ধার',
      'export_pdf': 'PDF রপ্তানি',
      'about': 'সম্পর্কে',
      'version': 'সংস্করণ',
      'privacy_policy': 'গোপনীয়তা নীতি',
      'terms_of_service': 'সেবার শর্তাবলী',

      // Backup & Restore
      'backup_restore': 'ব্যাকআপ ও পুনরুদ্ধার',
      'local_backup': 'লোকাল ব্যাকআপ',
      'local_backup_desc': 'আপনার ডেটা একটি ফাইলে রপ্তানি করুন যা আপনি যেকোনো জায়গায় সংরক্ষণ করতে পারেন',
      'cloud_backup': 'ক্লাউড ব্যাকআপ',
      'cloud_backup_desc': 'স্বয়ংক্রিয়ভাবে আপনার ক্লাউড অ্যাকাউন্টে ব্যাকআপ করুন',
      'export_data': 'ডেটা রপ্তানি',
      'export_data_desc': 'একটি ব্যাকআপ ফাইল তৈরি করুন এবং সংরক্ষণ করুন',
      'import_data': 'ডেটা আমদানি',
      'import_data_desc': 'একটি ব্যাকআপ ফাইল থেকে পুনরুদ্ধার করুন',
      'coming_soon': 'শীঘ্রই আসছে',
      'enable_auto_backup': 'স্বয়ংক্রিয় ব্যাকআপ সক্রিয় করুন',
      'enable_auto_backup_desc': 'স্বয়ংক্রিয়ভাবে আপনার ডেটা ক্লাউডে সিঙ্ক করুন',
      'restore_from_cloud': 'ক্লাউড থেকে পুনরুদ্ধার',
      'restore_from_cloud_desc': 'আপনার ক্লাউড ব্যাকআপ ডাউনলোড এবং পুনরুদ্ধার করুন',
      'about_backups': 'ব্যাকআপ সম্পর্কে',
      'backup_info_1': 'আপনার ব্যাকআপে সমস্ত খরচ, বিভাগ এবং সেটিংস অন্তর্ভুক্ত',
      'backup_info_2': 'ব্যাকআপ ফাইলগুলি JSON ফরম্যাটে সংরক্ষিত হয়',
      'backup_info_3': 'আপনি এই অ্যাপ সহ যেকোনো ডিভাইসে ব্যাকআপ আমদানি করতে পারেন',
      'backup_info_4': 'বিদ্যমান ডেটা প্রতিস্থাপন করতে "প্রতিস্থাপন" বা একত্রিত করতে "মার্জ" নির্বাচন করুন',
      'import_backup': 'ব্যাকআপ আমদানি',
      'import_backup_question': 'আপনি কীভাবে ব্যাকআপ ডেটা আমদানি করতে চান?',
      'replace_all': 'সব প্রতিস্থাপন',
      'replace_all_desc': 'বিদ্যমান খরচ মুছে ফেলুন এবং ব্যাকআপ ফাইল থেকে সমস্ত ডেটা আমদানি করুন। আপনার বর্তমান ডেটা প্রতিস্থাপিত হবে।',
      'merge': 'মার্জ',
      'merge_desc': 'আপনার বিদ্যমান ডেটা রাখুন এবং ব্যাকআপ থেকে নতুন আইটেম যোগ করুন। ডুপ্লিকেট এড়িয়ে যাওয়া হবে।',
      'backup_created': 'ব্যাকআপ তৈরি হয়েছে!',
      'backup_created_desc': 'আপনার ব্যাকআপ প্রস্তুত এবং শেয়ার করা হয়েছে। একটি নিরাপদ স্থানে সংরক্ষণ করুন।',
      'import_complete': 'আমদানি সম্পন্ন!',
      'import_replace_desc': 'আপনার ডেটা ব্যাকআপ দিয়ে প্রতিস্থাপিত হয়েছে।',
      'import_merge_desc': 'ব্যাকআপ আপনার বিদ্যমান ডেটার সাথে মার্জ করা হয়েছে।',
      'expenses_imported': 'খরচ আমদানি হয়েছে',
      'expenses_skipped': 'খরচ এড়িয়ে গেছে',
      'categories_imported': 'বিভাগ আমদানি হয়েছে',
      'categories_skipped': 'বিভাগ এড়িয়ে গেছে',
      'done': 'সম্পন্ন',
      'transactions': 'টি লেনদেন',
      'last_backup': 'সর্বশেষ:',
      'no_backup_yet': 'কোনো ব্যাকআপ নেই',
      'save_locally': 'লোকালি সেভ করুন',
      'save_locally_desc': 'Downloads/expense_backup ফোল্ডারে ব্যাকআপ ফাইল সেভ করুন',
      'share_export': 'শেয়ার / এক্সপোর্ট',
      'share_export_desc': 'Google Drive, Email ইত্যাদি অ্যাপের মাধ্যমে ব্যাকআপ শেয়ার করুন',
      'backup_saved': 'ব্যাকআপ সেভ হয়েছে!',
      'backup_saved_desc': 'আপনার ব্যাকআপ সেভ করা হয়েছে:',
      'import_success': 'আমদানি সফল!',
      'choose_export_method': 'এক্সপোর্ট পদ্ধতি নির্বাচন করুন',
      'how_to_export': 'আপনি কীভাবে আপনার ব্যাকআপ এক্সপোর্ট করতে চান?',

      // PDF
      'export': 'রপ্তানি',
      'monthly_report': 'মাসিক রিপোর্ট',
      'expense_report': 'খরচের রিপোর্ট',
      'generated_on': 'তৈরির তারিখ',
      'summary': 'সারাংশ',
      'details': 'বিস্তারিত',
      'pdf_exported': 'PDF সফলভাবে রপ্তানি হয়েছে',
      'pdf_export_failed': 'PDF রপ্তানি ব্যর্থ হয়েছে',

      // Common
      'save': 'সংরক্ষণ',
      'cancel': 'বাতিল',
      'delete': 'মুছুন',
      'edit': 'সম্পাদনা',
      'add': 'যোগ করুন',
      'ok': 'ঠিক আছে',
      'yes': 'হ্যাঁ',
      'no': 'না',
      'confirm': 'নিশ্চিত করুন',
      'error': 'ত্রুটি',
      'success': 'সফল',
      'warning': 'সতর্কতা',
      'loading': 'লোড হচ্ছে...',
      'search': 'অনুসন্ধান',
      'search_hint': 'খরচ অনুসন্ধান করুন...',
      'no_data': 'কোনো তথ্য নেই',
      'retry': 'আবার চেষ্টা করুন',
      'close': 'বন্ধ করুন',
    },
  };

  String translate(String key) {
    return _localizedValues[locale.languageCode]?[key] ?? key;
  }
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    return ['en', 'bn'].contains(locale.languageCode);
  }

  @override
  Future<AppLocalizations> load(Locale locale) async {
    return AppLocalizations(locale);
  }

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

/// Extension for easy access to translations
extension LocalizationExtension on BuildContext {
  AppLocalizations get l10n => AppLocalizations.of(this)!;
  String tr(String key) => AppLocalizations.of(this)?.translate(key) ?? key;
}
