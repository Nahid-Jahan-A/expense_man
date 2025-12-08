/// Application-wide constants
class AppConstants {
  AppConstants._();

  // App Info
  static const String appName = 'Expense Manager';
  static const String appVersion = '1.0.0';

  // Hive Box Names
  static const String expenseBox = 'expenses';
  static const String categoryBox = 'categories';
  static const String settingsBox = 'settings';

  // Default Values
  static const String defaultCurrency = 'BDT';
  static const String defaultCurrencySymbol = '৳';
  static const String defaultLocale = 'en';

  // Animation Durations
  static const Duration shortAnimation = Duration(milliseconds: 200);
  static const Duration mediumAnimation = Duration(milliseconds: 350);
  static const Duration longAnimation = Duration(milliseconds: 500);

  // Pagination
  static const int defaultPageSize = 20;

  // Date Formats
  static const String dateFormat = 'dd MMM yyyy';
  static const String timeFormat = 'hh:mm a';
  static const String dateTimeFormat = 'dd MMM yyyy, hh:mm a';
  static const String monthYearFormat = 'MMMM yyyy';
}
