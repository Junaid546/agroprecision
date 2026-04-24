import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_typography.dart';
import '../../../services/hive_service.dart';
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
              'Download reports and historical data.',
              style: AppTypography.bodyMd
                  .copyWith(color: AppColors.onSurfaceVariant),
            ),
            const SizedBox(height: 24),
            _buildExportOption(
              context,
              icon: Icons.backup,
              title: 'Export as JSON',
              subtitle: 'Full backup of all farm data',
              onTap: () => _exportAsJSON(context),
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
              subtitle: 'Expenses and mortality tables',
              onTap: () => _exportAsCSV(context),
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
                    Text(title,
                        style: AppTypography.bodyLg
                            .copyWith(fontWeight: FontWeight.bold)),
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

  Future<void> _exportAsJSON(BuildContext context) async {
    try {
      final data = HiveService.exportToJson();
      final jsonString = jsonEncode(data);

      final directory = await getApplicationDocumentsDirectory();
      final file = File(
          '${directory.path}/agro_precision_backup_${DateTime.now().millisecondsSinceEpoch}.json');
      await file.writeAsString(jsonString);

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                'Data exported to ${file.path.split('/').last}. Size: ${(jsonString.length / 1024).toStringAsFixed(2)} KB'),
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

  Future<void> _exportAsCSV(BuildContext context) async {
    // Placeholder for CSV export
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('CSV export functionality coming soon!')),
    );
  }
}
