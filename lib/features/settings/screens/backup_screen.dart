import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_typography.dart';
import '../../../services/hive_service.dart';
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
    setState(() {
      _autoBackup = prefs.getBool('auto_backup') ?? false;
      _lastBackupDate = prefs.getString('last_backup_date') ?? 'Never';
    });
  }

  Future<void> _refreshBackupList() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final files = directory.listSync().whereType<File>().where((f) => f.path.endsWith('.json')).toList();
      files.sort((a, b) => b.lastModifiedSync().compareTo(a.lastModifiedSync()));
      setState(() {
        _backups = files.take(3).toList();
      });
    } catch (e) {
      debugPrint('Error loading backup list: $e');
    }
  }

  Future<void> _triggerBackup() async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    try {
      final data = HiveService.exportToJson();
      final jsonString = jsonEncode(data);
      
      final directory = await getApplicationDocumentsDirectory();
      final fileName = 'agro_precision_backup_${DateTime.now().millisecondsSinceEpoch}.json';
      final file = File('${directory.path}/$fileName');
      await file.writeAsString(jsonString);

      final prefs = await SharedPreferences.getInstance();
      final now = DateFormat('MMM dd, yyyy HH:mm').format(DateTime.now());
      await prefs.setString('last_backup_date', now);

      setState(() {
        _lastBackupDate = now;
      });

      await _refreshBackupList();

      if (mounted) Navigator.pop(context);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Backup completed successfully!')),
        );
      }
    } catch (e) {
      if (mounted) Navigator.pop(context);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Backup failed: $e')),
        );
      }
    }
  }

  Future<void> _toggleAutoBackup(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('auto_backup', value);
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
              'Manage your data security and automated backups.',
              style: AppTypography.bodyMd.copyWith(color: AppColors.onSurfaceVariant),
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
                            Text(_lastBackupDate, style: AppTypography.headlineMd),
                          ],
                        ),
                        const Icon(Icons.cloud_done, size: 48, color: AppColors.primary),
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
              title: Text('Auto-Backup', style: AppTypography.bodyLg.copyWith(fontWeight: FontWeight.bold)),
              subtitle: const Text('Automatically backup data every 24 hours'),
              value: _autoBackup,
              onChanged: _toggleAutoBackup,
              activeColor: AppColors.primary,
            ),
            const Divider(),
            const SizedBox(height: 24),
            Text('RECENT BACKUPS', style: AppTypography.labelBold.copyWith(color: AppColors.primary)),
            const SizedBox(height: 12),
            if (_backups.isEmpty)
              const Center(child: Text('No backups found.'))
            else
              ..._backups.map((file) => _buildBackupItem(file)),
          ],
        ),
      ),
    );
  }

  Widget _buildBackupItem(File file) {
    final date = DateFormat('MMM dd, yyyy • HH:mm').format(file.lastModifiedSync());
    final size = (file.lengthSync() / 1024).toStringAsFixed(1);

    return ListTile(
      leading: const Icon(Icons.insert_drive_file, color: AppColors.outline),
      title: Text(file.path.split('/').last, style: AppTypography.bodyMd.copyWith(fontWeight: FontWeight.bold)),
      subtitle: Text('$date • $size KB'),
      trailing: IconButton(
        icon: const Icon(Icons.delete_outline, color: AppColors.error),
        onPressed: () async {
          await file.delete();
          await _refreshBackupList();
        },
      ),
    );
  }
}
