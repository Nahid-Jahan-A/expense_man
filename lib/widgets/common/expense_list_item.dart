import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../features/expense/domain/entities/expense.dart';
import '../../features/category/domain/entities/category.dart';
import '../../core/constants/enums.dart';
import '../../core/utils/currency_utils.dart';
import '../../core/extensions/date_extensions.dart';

/// Expense list item widget
class ExpenseListItem extends StatelessWidget {
  final Expense expense;
  final Category? category;
  final Currency currency;
  final String locale;
  final VoidCallback? onTap;
  final VoidCallback? onDelete;
  final int animationIndex;

  const ExpenseListItem({
    super.key,
    required this.expense,
    this.category,
    this.currency = Currency.bdt,
    this.locale = 'en',
    this.onTap,
    this.onDelete,
    this.animationIndex = 0,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final categoryColor = category != null
        ? Color(category!.color)
        : colorScheme.primary;

    return Dismissible(
      key: Key(expense.id),
      direction: onDelete != null
          ? DismissDirection.endToStart
          : DismissDirection.none,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        color: colorScheme.errorContainer,
        child: Icon(
          Icons.delete_outline,
          color: colorScheme.onErrorContainer,
        ),
      ),
      confirmDismiss: (direction) async {
        if (onDelete != null) {
          final confirmed = await _showDeleteConfirmation(context);
          if (confirmed) {
            onDelete!.call();
          }
        }
        return false;
      },
      child: Card(
        elevation: 0,
        margin: const EdgeInsets.symmetric(vertical: 4),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                // Category icon
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: categoryColor.withAlpha(26),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    _getCategoryIcon(category?.icon),
                    color: categoryColor,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                // Details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        category?.getName(locale) ?? 'Unknown',
                        style: textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            _getPaymentIcon(expense.paymentMethod),
                            size: 14,
                            color: colorScheme.onSurfaceVariant,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            expense.dateTime.relativeDateString,
                            style: textTheme.bodySmall?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                          if (expense.note?.isNotEmpty ?? false) ...[
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                expense.note!,
                                style: textTheme.bodySmall?.copyWith(
                                  color: colorScheme.onSurfaceVariant,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
                // Amount
                Text(
                  CurrencyUtils.format(expense.amount, currency: currency),
                  style: textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: colorScheme.primary,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    )
        .animate()
        .fadeIn(delay: Duration(milliseconds: 50 * animationIndex))
        .slideX(
          begin: 0.1,
          end: 0,
          delay: Duration(milliseconds: 50 * animationIndex),
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOutCubic,
        );
  }

  Future<bool> _showDeleteConfirmation(BuildContext context) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(locale == 'bn' ? 'খরচ মুছুন?' : 'Delete Expense?'),
        content: Text(
          locale == 'bn'
              ? 'আপনি কি নিশ্চিত যে এই খরচটি মুছতে চান?'
              : 'Are you sure you want to delete this expense?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(locale == 'bn' ? 'বাতিল' : 'Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.error,
            ),
            child: Text(locale == 'bn' ? 'মুছুন' : 'Delete'),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  IconData _getCategoryIcon(String? iconName) {
    switch (iconName) {
      case 'medical_services':
        return Icons.medical_services;
      case 'checkroom':
        return Icons.checkroom;
      case 'home':
        return Icons.home;
      case 'receipt_long':
        return Icons.receipt_long;
      case 'directions_car':
        return Icons.directions_car;
      case 'restaurant':
        return Icons.restaurant;
      case 'shopping_cart':
        return Icons.shopping_cart;
      case 'movie':
        return Icons.movie;
      case 'more_horiz':
        return Icons.more_horiz;
      default:
        return Icons.category;
    }
  }

  IconData _getPaymentIcon(String paymentMethod) {
    switch (paymentMethod) {
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
}
