import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_typography.dart';
import '../../../shared/providers/app_state_provider.dart';
import '../../../shared/providers/repository_providers.dart';
import '../../../shared/widgets/agro_app_bar.dart';
import '../../../data/models/shed_model.dart';
import '../../batch/providers/batch_providers.dart';

class ShedManagementScreen extends ConsumerWidget {
  const ShedManagementScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final shedsAsync = ref.watch(shedListProvider);

    return Scaffold(
      appBar: const AgroAppBar(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Shed Management', style: AppTypography.headlineLg),
            Text(
              'Register and configure your poultry houses.',
              style: AppTypography.bodyMd
                  .copyWith(color: AppColors.onSurfaceVariant),
            ),
            const SizedBox(height: 24),
            shedsAsync.when(
              data: (sheds) => Column(
                children: [
                  ...sheds.map((shed) => Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        child: ListTile(
                          leading: const Icon(Icons.warehouse,
                              color: AppColors.primary),
                          title: Text(shed.name,
                              style: AppTypography.bodyLg
                                  .copyWith(fontWeight: FontWeight.bold)),
                          subtitle: Text('Capacity: ${shed.capacity} birds'),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete_outline,
                                color: AppColors.error),
                            onPressed: () => _deleteShed(context, ref, shed),
                          ),
                        ),
                      )),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () => _showAddShedDialog(context, ref),
                      icon: const Icon(Icons.add),
                      label: const Text('Add New Shed'),
                    ),
                  ),
                ],
              ),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, __) => Text('Error: $e'),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddShedDialog(BuildContext context, WidgetRef ref) {
    final nameController = TextEditingController();
    final capacityController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add New Shed'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Shed Name')),
            const SizedBox(height: 16),
            TextField(
              controller: capacityController,
              decoration: const InputDecoration(labelText: 'Capacity (birds)'),
              keyboardType: TextInputType.number,
            ),
          ],
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel')),
          TextButton(
            onPressed: () async {
              final farm = ref.read(currentFarmProvider);
              if (farm == null) return;

              final shed = ShedModel.create(
                farmId: farm.id,
                name: nameController.text,
                capacity: int.tryParse(capacityController.text) ?? 0,
              );

              await ref.read(shedRepositoryProvider).create(shed);
              ref.invalidate(shedListProvider);
              if (context.mounted) Navigator.pop(context);
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  void _deleteShed(BuildContext context, WidgetRef ref, ShedModel shed) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Shed'),
        content: Text('Are you sure you want to delete ${shed.name}?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel')),
          TextButton(
            onPressed: () async {
              await ref.read(shedRepositoryProvider).delete(shed.id);
              ref.invalidate(shedListProvider);
              if (context.mounted) Navigator.pop(context);
            },
            child:
                const Text('Delete', style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
  }
}
