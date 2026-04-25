import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_typography.dart';
import '../../../data/models/health_treatment_model.dart';
import '../../../data/models/inventory_transaction_model.dart';
import '../../../features/batch/providers/batch_providers.dart';
import '../../../features/dashboard/providers/dashboard_providers.dart';
import '../../../features/shed_control/providers/shed_control_providers.dart';
import '../../../shared/providers/app_state_provider.dart';
import '../../../shared/providers/repository_providers.dart';
import '../../../shared/widgets/agro_app_bar.dart';

class HealthTreatmentsScreen extends ConsumerWidget {
  const HealthTreatmentsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final treatmentsAsync = ref.watch(farmTreatmentsProvider);

    return Scaffold(
      appBar: const AgroAppBar(),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddTreatmentDialog(context, ref),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text('Add Treatment'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Health & Treatments', style: AppTypography.headlineLg),
            Text(
              'Record vaccination, medication, and shed care while keeping all existing batch logs available.',
              style: AppTypography.bodyMd
                  .copyWith(color: AppColors.onSurfaceVariant),
            ),
            const SizedBox(height: 24),
            treatmentsAsync.when(
              data: (treatments) {
                if (treatments.isEmpty) {
                  return const Card(
                    child: Padding(
                      padding: EdgeInsets.all(20),
                      child: Text('No treatment records yet.'),
                    ),
                  );
                }
                return Column(
                  children: treatments
                      .map(
                        (treatment) => Card(
                          margin: const EdgeInsets.only(bottom: 12),
                          child: CheckboxListTile(
                            title: Text(treatment.title),
                            subtitle: Text(
                              '${treatment.type.displayName} • ${treatment.scheduledDate.toLocal().toString().split(' ').first}'
                              '${treatment.quantityUsed != null ? ' • ${treatment.quantityUsed} ${treatment.unit ?? ''}' : ''}',
                            ),
                            value: treatment.isCompleted,
                            onChanged: (value) => _toggleCompleted(
                              ref,
                              treatment,
                              value ?? false,
                            ),
                          ),
                        ),
                      )
                      .toList(),
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Card(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Text('Error loading treatments: $e'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _toggleCompleted(
    WidgetRef ref,
    HealthTreatmentModel treatment,
    bool completed,
  ) async {
    if (completed && !treatment.isCompleted) {
      if (treatment.inventoryItemId != null &&
          (treatment.quantityUsed ?? 0) > 0) {
        await ref.read(inventoryFlowServiceProvider).consumeStock(
              itemId: treatment.inventoryItemId!,
              farmId: treatment.farmId,
              quantity: treatment.quantityUsed!,
              unit: treatment.unit ?? 'unit',
              type: InventoryTransactionType.treatment,
              batchId: treatment.batchId,
              shedId: treatment.shedId,
              notes: treatment.title,
            );
      }
      treatment.completedDate = DateTime.now();
    } else if (!completed) {
      treatment.completedDate = null;
    }
    treatment.isCompleted = completed;
    await ref.read(healthTreatmentRepositoryProvider).update(treatment);
    ref.invalidate(farmTreatmentsProvider);
    ref.invalidate(farmInventoryProvider);
    ref.invalidate(lowStockItemsProvider);
    ref.invalidate(dashboardSummaryProvider);
  }

  void _showAddTreatmentDialog(BuildContext context, WidgetRef ref) {
    final farm = ref.read(currentFarmProvider);
    if (farm == null) {
      return;
    }
    final titleController = TextEditingController();
    final qtyController = TextEditingController();
    final unitController = TextEditingController(text: 'dose');
    TreatmentType treatmentType = TreatmentType.vaccination;
    String? selectedShedId;
    String? selectedBatchId;
    String? selectedInventoryId;
    bool completedNow = true;
    final scheduledDate = DateTime.now();

    showDialog(
      context: context,
      builder: (dialogContext) => Consumer(
        builder: (context, localRef, _) {
          final shedsAsync = localRef.watch(shedListProvider);
          final batchesAsync = localRef.watch(activeBatchesProvider);
          final inventoryAsync = localRef.watch(farmInventoryProvider);
          return AlertDialog(
            title: const Text('Add Treatment'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: titleController,
                    decoration: const InputDecoration(labelText: 'Title'),
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<TreatmentType>(
                    initialValue: treatmentType,
                    decoration: const InputDecoration(labelText: 'Type'),
                    items: TreatmentType.values
                        .map(
                          (value) => DropdownMenuItem(
                            value: value,
                            child: Text(value.displayName),
                          ),
                        )
                        .toList(),
                    onChanged: (value) =>
                        treatmentType = value ?? treatmentType,
                  ),
                  const SizedBox(height: 12),
                  shedsAsync.when(
                    data: (sheds) => DropdownButtonFormField<String>(
                      initialValue: selectedShedId,
                      decoration: const InputDecoration(labelText: 'Shed'),
                      items: sheds
                          .map(
                            (shed) => DropdownMenuItem(
                              value: shed.id,
                              child: Text(shed.name),
                            ),
                          )
                          .toList(),
                      onChanged: (value) => selectedShedId = value,
                    ),
                    loading: () => const SizedBox(),
                    error: (_, __) => const SizedBox(),
                  ),
                  const SizedBox(height: 12),
                  batchesAsync.when(
                    data: (batches) => DropdownButtonFormField<String>(
                      initialValue: selectedBatchId ?? '',
                      decoration: const InputDecoration(
                        labelText: 'Batch (optional)',
                      ),
                      items: [
                        const DropdownMenuItem<String>(
                          value: '',
                          child: Text('No batch link'),
                        ),
                        ...batches.map(
                          (batch) => DropdownMenuItem(
                            value: batch.id,
                            child: Text(batch.batchNumber),
                          ),
                        ),
                      ],
                      onChanged: (value) =>
                          selectedBatchId = (value?.isEmpty ?? true) ? null : value,
                    ),
                    loading: () => const SizedBox(),
                    error: (_, __) => const SizedBox(),
                  ),
                  const SizedBox(height: 12),
                  inventoryAsync.when(
                    data: (items) => DropdownButtonFormField<String>(
                      initialValue: selectedInventoryId ?? '',
                      decoration: const InputDecoration(
                        labelText: 'Inventory Item (optional)',
                      ),
                      items: [
                        const DropdownMenuItem<String>(
                          value: '',
                          child: Text('No stock deduction'),
                        ),
                        ...items.map(
                          (item) => DropdownMenuItem(
                            value: item.id,
                            child: Text(item.name),
                          ),
                        ),
                      ],
                      onChanged: (value) => selectedInventoryId =
                          (value?.isEmpty ?? true) ? null : value,
                    ),
                    loading: () => const SizedBox(),
                    error: (_, __) => const SizedBox(),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: qtyController,
                    keyboardType: TextInputType.number,
                    decoration:
                        const InputDecoration(labelText: 'Quantity used'),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: unitController,
                    decoration: const InputDecoration(labelText: 'Unit'),
                  ),
                  const SizedBox(height: 12),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Mark completed now'),
                    value: completedNow,
                    onChanged: (value) => completedNow = value,
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () async {
                  if (titleController.text.trim().isEmpty ||
                      selectedShedId == null) {
                    return;
                  }
                  final treatment = HealthTreatmentModel.create(
                    farmId: farm.id,
                    shedId: selectedShedId!,
                    batchId: selectedBatchId,
                    type: treatmentType,
                    title: titleController.text.trim(),
                    scheduledDate: scheduledDate,
                    quantityUsed: double.tryParse(qtyController.text),
                    unit: unitController.text.trim().isEmpty
                        ? null
                        : unitController.text.trim(),
                    inventoryItemId: selectedInventoryId,
                  );
                  treatment.isCompleted = completedNow;
                  treatment.completedDate =
                      completedNow ? DateTime.now() : null;

                  await ref
                      .read(healthTreatmentRepositoryProvider)
                      .create(treatment);

                  if (completedNow &&
                      treatment.inventoryItemId != null &&
                      (treatment.quantityUsed ?? 0) > 0) {
                    await ref.read(inventoryFlowServiceProvider).consumeStock(
                          itemId: treatment.inventoryItemId!,
                          farmId: farm.id,
                          quantity: treatment.quantityUsed!,
                          unit: treatment.unit ?? 'unit',
                          type: InventoryTransactionType.treatment,
                          batchId: treatment.batchId,
                          shedId: treatment.shedId,
                          notes: treatment.title,
                        );
                  }

                  ref.invalidate(farmTreatmentsProvider);
                  ref.invalidate(farmInventoryProvider);
                  ref.invalidate(lowStockItemsProvider);
                  ref.invalidate(dashboardSummaryProvider);
                  if (dialogContext.mounted) {
                    Navigator.pop(dialogContext);
                  }
                },
                child: const Text('Save'),
              ),
            ],
          );
        },
      ),
    );
  }
}
