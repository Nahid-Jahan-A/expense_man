import 'package:flutter/material.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../domain/entities/backup_data.dart';

/// Dialog shown after successful backup import
class ImportSuccessDialog extends StatelessWidget {
  final ImportResult result;
  final ImportMode mode;
  final VoidCallback onDismiss;

  const ImportSuccessDialog({
    super.key,
    required this.result,
    required this.mode,
    required this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AlertDialog(
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.green.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.check_circle,
              color: Colors.green,
              size: 48,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            context.tr('import_complete'),
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            mode == ImportMode.replace
                ? context.tr('import_replace_desc')
                : context.tr('import_merge_desc'),
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 20),

          // Stats
          _buildStatRow(
            context,
            icon: Icons.receipt_long,
            label: context.tr('expenses_imported'),
            value: result.expensesImported.toString(),
            color: theme.colorScheme.primary,
          ),
          if (result.expensesSkipped > 0)
            _buildStatRow(
              context,
              icon: Icons.skip_next,
              label: context.tr('expenses_skipped'),
              value: result.expensesSkipped.toString(),
              color: Colors.orange,
            ),
          const SizedBox(height: 8),
          _buildStatRow(
            context,
            icon: Icons.category,
            label: context.tr('categories_imported'),
            value: result.categoriesImported.toString(),
            color: theme.colorScheme.secondary,
          ),
          if (result.categoriesSkipped > 0)
            _buildStatRow(
              context,
              icon: Icons.skip_next,
              label: context.tr('categories_skipped'),
              value: result.categoriesSkipped.toString(),
              color: Colors.orange,
            ),
        ],
      ),
      actions: [
        FilledButton(
          onPressed: onDismiss,
          child: Text(context.tr('done')),
        ),
      ],
    );
  }

  Widget _buildStatRow(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 20, color: color),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: theme.textTheme.bodyMedium,
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              value,
              style: theme.textTheme.titleSmall?.copyWith(
                color: color,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
