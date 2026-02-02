import 'package:flutter/material.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../domain/entities/backup_data.dart';

/// Dialog to select import mode (replace or merge)
class ImportModeDialog extends StatelessWidget {
  final Function(ImportMode) onModeSelected;

  const ImportModeDialog({
    super.key,
    required this.onModeSelected,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AlertDialog(
      title: Row(
        children: [
          Icon(Icons.download, color: theme.colorScheme.primary),
          const SizedBox(width: 12),
          Expanded(child: Text(context.tr('import_backup'))),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            context.tr('import_backup_question'),
            style: theme.textTheme.bodyMedium,
          ),
          const SizedBox(height: 20),

          // Replace Option
          _buildOptionCard(
            context,
            icon: Icons.refresh,
            title: context.tr('replace_all'),
            description: context.tr('replace_all_desc'),
            color: Colors.orange,
            onTap: () => onModeSelected(ImportMode.replace),
          ),

          const SizedBox(height: 12),

          // Merge Option
          _buildOptionCard(
            context,
            icon: Icons.merge,
            title: context.tr('merge'),
            description: context.tr('merge_desc'),
            color: theme.colorScheme.primary,
            onTap: () => onModeSelected(ImportMode.merge),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(context.tr('cancel')),
        ),
      ],
    );
  }

  Widget _buildOptionCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String description,
    required Color color,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(color: color.withOpacity(0.3)),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: color,
            ),
          ],
        ),
      ),
    );
  }
}
