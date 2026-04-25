import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_typography.dart';
import '../../../features/batch/providers/batch_providers.dart';
import '../../../features/dashboard/providers/dashboard_providers.dart';
import '../../../features/security/providers/security_providers.dart';
import '../../../features/shed_control/providers/shed_control_providers.dart';
import '../../../shared/providers/app_state_provider.dart';
import '../../../shared/providers/repository_providers.dart';
import '../../../shared/widgets/agro_app_bar.dart';

class BackupScreen extends ConsumerStatefulWidget {
  const BackupScreen({super.key});

  @override
  ConsumerState<BackupScreen> createState() => _BackupScreenState();
}

class _BackupScreenState extends ConsumerState<BackupScreen> {
  bool _autoBackup = false;
  String _lastBackupDate = 'Never';
  List<File> _backups = [];

  @override
  void initState() {
    super.initState();
    _loadBackupSettings();
    _refreshBackupList();
  }

  Future<void> _loadBackupSettings() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) {
      return;
    }

    setState(() {
      _autoBackup = prefs.getBool('auto_backup') ?? false;
      _lastBackupDate = prefs.getString('last_backup_date') ?? 'Never';
    });
  }

  Future<void> _refreshBackupList() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final files = directory
          .listSync()
          .whereType<File>()
          .where((file) => file.path.endsWith('.json'))
          .toList()
        ..sort((a, b) => b.lastModifiedSync().compareTo(a.lastModifiedSync()));

      if (!mounted) {
        return;
      }

      setState(() {
        _backups = files.take(5).toList();
      });
    } catch (error) {
      debugPrint('Error loading backups: $error');
    }
  }

  Future<void> _triggerBackup() async {
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    try {
      await ref.read(backupRestoreServiceProvider).exportBackupFile();

      final prefs = await SharedPreferences.getInstance();
      final now = DateFormat('MMM dd, yyyy HH:mm').format(DateTime.now());
      await prefs.setString('last_backup_date', now);

      if (mounted) {
        setState(() {
          _lastBackupDate = now;
        });
      }
      await _refreshBackupList();

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Backup completed successfully')),
        );
      }
    } catch (error) {
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Backup failed: $error')),
        );
      }
    }
  }

  Future<void> _toggleAutoBackup(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('auto_backup', value);
    if (!mounted) {
      return;
    }

    setState(() {
      _autoBackup = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const AgroAppBar(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('System Backup', style: AppTypography.headlineLg),
            Text(
              'Create and restore backups while keeping compatibility with old AgroPrecision exports.',
              style: AppTypography.bodyMd.copyWith(
                color: AppColors.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 24),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Last Backup', style: AppTypography.labelBold),
                            Text(
                              _lastBackupDate,
                              style: AppTypography.headlineMd,
                            ),
                          ],
                        ),
                        const Icon(
                          Icons.cloud_done,
                          size: 48,
                          color: AppColors.primary,
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _triggerBackup,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                        ),
                        child: const Text('Backup Now'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            SwitchListTile(
              title: Text(
                'Auto-Backup',
                style: AppTypography.bodyLg.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              subtitle: const Text('Automatically backup data every 24 hours'),
              value: _autoBackup,
              onChanged: _toggleAutoBackup,
              activeThumbColor: AppColors.primary,
            ),
            const Divider(),
            const SizedBox(height: 24),
            Text(
              'RECENT BACKUPS',
              style: AppTypography.labelBold.copyWith(
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 12),
            if (_backups.isEmpty)
              const Center(child: Text('No backups found.'))
            else
              ..._backups.map(_buildBackupItem),
          ],
        ),
      ),
    );
  }

  Widget _buildBackupItem(File file) {
    final date = DateFormat('MMM dd, yyyy HH:mm').format(file.lastModifiedSync());
    final size = (file.lengthSync() / 1024).toStringAsFixed(1);

    return ListTile(
      leading: const Icon(Icons.insert_drive_file, color: AppColors.outline),
      title: Text(
        _fileName(file),
        style: AppTypography.bodyMd.copyWith(fontWeight: FontWeight.bold),
      ),
      subtitle: Text('$date | $size KB'),
      trailing: Wrap(
        spacing: 0,
        children: [
          IconButton(
            icon: const Icon(Icons.restore, color: AppColors.primary),
            onPressed: () => _restoreBackup(file),
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline, color: AppColors.error),
            onPressed: () async {
              await file.delete();
              await _refreshBackupList();
            },
          ),
        ],
      ),
    );
  }

  Future<void> _restoreBackup(File file) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Restore Backup'),
        content: Text(
          'Restore ${_fileName(file)}? This replaces current local data.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Restore'),
          ),
        ],
      ),
    );

    if (confirmed != true) {
      return;
    }

    try {
      await ref.read(backupRestoreServiceProvider).restoreFromFile(file);
      ref.read(securityUnlockedProvider.notifier).state = true;
      await ref.read(currentFarmProvider.notifier).reloadFarm();
      ref.invalidate(shedListProvider);
      ref.invalidate(allBatchesProvider);
      ref.invalidate(dashboardSummaryProvider);
      ref.invalidate(farmInventoryProvider);
      ref.invalidate(lowStockItemsProvider);
      ref.invalidate(farmTreatmentsProvider);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Backup restored successfully')),
        );
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Restore failed: $error')),
        );
      }
    }
  }

  String _fileName(File file) {
    if (file.uri.pathSegments.isNotEmpty) {
      return file.uri.pathSegments.last;
    }
    return file.path.split(Platform.pathSeparator).last;
  }
}
