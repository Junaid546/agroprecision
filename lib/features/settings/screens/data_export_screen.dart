import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:path_provider/path_provider.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_typography.dart';
import '../../../features/batch/providers/batch_providers.dart';
import '../../../shared/providers/app_state_provider.dart';
import '../../../shared/providers/repository_providers.dart';
import '../../../shared/widgets/agro_app_bar.dart';

class DataExportScreen extends ConsumerWidget {
  const DataExportScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: const AgroAppBar(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Data Export', style: AppTypography.headlineLg),
            Text(
              'Download legacy financial data plus the new shed operations records.',
              style: AppTypography.bodyMd
                  .copyWith(color: AppColors.onSurfaceVariant),
            ),
            const SizedBox(height: 24),
            _buildExportOption(
              context,
              icon: Icons.backup,
              title: 'Export as JSON',
              subtitle: 'Full backup of all farm data',
              onTap: () => _exportAsJSON(context, ref),
            ),
            const SizedBox(height: 12),
            _buildExportOption(
              context,
              icon: Icons.picture_as_pdf,
              title: 'Export as PDF Report',
              subtitle: 'Professional summary and analysis',
              onTap: () => context.push('/home/reports'),
            ),
            const SizedBox(height: 12),
            _buildExportOption(
              context,
              icon: Icons.table_chart,
              title: 'Export CSV',
              subtitle: 'Combined operations, production, and finance tables',
              onTap: () => _exportAsCSV(context, ref),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExportOption(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Card(
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: AppColors.primary),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: AppTypography.bodyLg
                          .copyWith(fontWeight: FontWeight.bold),
                    ),
                    Text(subtitle, style: AppTypography.bodyMd),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: AppColors.outline),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _exportAsJSON(BuildContext context, WidgetRef ref) async {
    try {
      final file = await ref.read(backupRestoreServiceProvider).exportBackupFile();
      final jsonString = await file.readAsString();

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Data exported to ${file.path.split('/').last}. Size: ${(jsonString.length / 1024).toStringAsFixed(2)} KB',
            ),
            action: SnackBarAction(label: 'OK', onPressed: () {}),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Export failed: $e')),
        );
      }
    }
  }

  Future<void> _exportAsCSV(BuildContext context, WidgetRef ref) async {
    try {
      final farm = ref.read(currentFarmProvider);
      if (farm == null) {
        throw Exception('No active farm found');
      }

      final sheds = await ref.read(shedListProvider.future);
      final csv = await ref.read(csvExportServiceProvider).buildFarmCsv(
            farm.id,
            shedIds: sheds.map((shed) => shed.id).toList(),
          );
      final directory = await getApplicationDocumentsDirectory();
      final file = File(
        '${directory.path}/agro_precision_export_${DateTime.now().millisecondsSinceEpoch}.csv',
      );
      await file.writeAsString(csv);

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('CSV exported to ${file.path.split('/').last}'),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('CSV export failed: $e')),
        );
      }
    }
  }
}
