import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/di/service_locator.dart';
import '../../../../core/localization/app_localizations.dart';
import '../bloc/backup_bloc.dart';
import '../bloc/backup_event.dart';
import '../bloc/backup_state.dart';
import '../widgets/import_mode_dialog.dart';
import '../widgets/backup_success_dialog.dart';
import '../widgets/import_success_dialog.dart';

/// Page for managing backups
class BackupPage extends StatelessWidget {
  const BackupPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<BackupBloc>(),
      child: const BackupPageContent(),
    );
  }
}

class BackupPageContent extends StatelessWidget {
  const BackupPageContent({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(context.tr('backup_restore')),
      ),
      body: BlocConsumer<BackupBloc, BackupState>(
        listener: (context, state) {
          _handleStateChanges(context, state);
        },
        builder: (context, state) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Local Backup Section
                _buildSectionHeader(
                  context,
                  icon: Icons.phone_android,
                  title: context.tr('local_backup'),
                  subtitle: context.tr('local_backup_desc'),
                  color: colorScheme.primary,
                ),
                const SizedBox(height: 16),
                _buildLocalBackupCard(context, state),

                const SizedBox(height: 32),

                // Cloud Backup Section (Coming Soon)
                _buildSectionHeader(
                  context,
                  icon: Icons.cloud_outlined,
                  title: context.tr('cloud_backup'),
                  subtitle: context.tr('cloud_backup_desc'),
                  color: Colors.grey,
                ),
                const SizedBox(height: 16),
                _buildCloudBackupCard(context),

                const SizedBox(height: 32),

                // Info Section
                _buildInfoCard(context),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSectionHeader(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
  }) {
    return Row(
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
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              Text(
                subtitle,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildLocalBackupCard(BuildContext context, BackupState state) {
    final isLoading = state is BackupLoading;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Export Button
            _buildActionTile(
              context,
              icon: Icons.upload_file,
              title: context.tr('export_data'),
              subtitle: context.tr('export_data_desc'),
              onTap: isLoading
                  ? null
                  : () => context.read<BackupBloc>().add(const ExportBackupEvent()),
              trailing: isLoading && state.message?.contains('export') == true
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.chevron_right),
            ),

            const Divider(height: 24),

            // Import Button
            _buildActionTile(
              context,
              icon: Icons.download,
              title: context.tr('import_data'),
              subtitle: context.tr('import_data_desc'),
              onTap: isLoading ? null : () => _showImportDialog(context),
              trailing: isLoading && state.message?.contains('import') == true
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.chevron_right),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCloudBackupCard(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.orange.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.schedule, size: 16, color: Colors.orange),
                  const SizedBox(width: 4),
                  Text(
                    context.tr('coming_soon'),
                    style: const TextStyle(
                      color: Colors.orange,
                      fontWeight: FontWeight.w500,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            _buildActionTile(
              context,
              icon: Icons.cloud_upload,
              title: context.tr('enable_auto_backup'),
              subtitle: context.tr('enable_auto_backup_desc'),
              onTap: null,
              enabled: false,
              trailing: Switch(
                value: false,
                onChanged: null,
              ),
            ),
            const Divider(height: 24),
            _buildActionTile(
              context,
              icon: Icons.cloud_download,
              title: context.tr('restore_from_cloud'),
              subtitle: context.tr('restore_from_cloud_desc'),
              onTap: null,
              enabled: false,
              trailing: const Icon(Icons.chevron_right, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback? onTap,
    Widget? trailing,
    bool enabled = true,
  }) {
    final theme = Theme.of(context);
    final color = enabled ? theme.colorScheme.onSurface : Colors.grey;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: (enabled ? theme.colorScheme.primary : Colors.grey)
                    .withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                icon,
                color: enabled ? theme.colorScheme.primary : Colors.grey,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: theme.textTheme.titleSmall?.copyWith(
                      color: color,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: color.withOpacity(0.7),
                    ),
                  ),
                ],
              ),
            ),
            if (trailing != null) trailing,
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      color: theme.colorScheme.surfaceContainerHighest.withOpacity(0.5),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.info_outline,
                  size: 20,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  context.tr('about_backups'),
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _buildInfoItem(
              context,
              context.tr('backup_info_1'),
            ),
            _buildInfoItem(
              context,
              context.tr('backup_info_2'),
            ),
            _buildInfoItem(
              context,
              context.tr('backup_info_3'),
            ),
            _buildInfoItem(
              context,
              context.tr('backup_info_4'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoItem(BuildContext context, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('• ', style: TextStyle(fontWeight: FontWeight.bold)),
          Expanded(
            child: Text(
              text,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
        ],
      ),
    );
  }

  void _showImportDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => ImportModeDialog(
        onModeSelected: (mode) {
          Navigator.of(dialogContext).pop();
          context.read<BackupBloc>().add(ImportBackupEvent(mode));
        },
      ),
    );
  }

  void _handleStateChanges(BuildContext context, BackupState state) {
    if (state is BackupExported) {
      showDialog(
        context: context,
        builder: (_) => BackupSuccessDialog(
          filePath: state.filePath,
          onDismiss: () {
            Navigator.of(context).pop();
            context.read<BackupBloc>().add(const ResetBackupStateEvent());
          },
        ),
      );
    } else if (state is BackupImported) {
      showDialog(
        context: context,
        builder: (_) => ImportSuccessDialog(
          result: state.result,
          mode: state.mode,
          onDismiss: () {
            Navigator.of(context).pop();
            context.read<BackupBloc>().add(const ResetBackupStateEvent());
          },
        ),
      );
    } else if (state is BackupError) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(state.message),
          backgroundColor: Theme.of(context).colorScheme.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
      context.read<BackupBloc>().add(const ResetBackupStateEvent());
    }
  }
}
