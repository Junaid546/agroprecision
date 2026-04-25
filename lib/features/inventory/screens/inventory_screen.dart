import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_typography.dart';
import '../../../data/models/inventory_item_model.dart';
import '../../../data/models/inventory_transaction_model.dart';
import '../../../features/batch/providers/batch_providers.dart';
import '../../../features/dashboard/providers/dashboard_providers.dart';
import '../../../features/shed_control/providers/shed_control_providers.dart';
import '../../../shared/providers/app_state_provider.dart';
import '../../../shared/providers/repository_providers.dart';
import '../../../shared/widgets/agro_app_bar.dart';

class InventoryScreen extends ConsumerWidget {
  const InventoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final farm = ref.watch(currentFarmProvider);
    final inventoryAsync = ref.watch(farmInventoryProvider);

    return Scaffold(
      appBar: const AgroAppBar(),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: farm == null ? null : () => _showAddItemDialog(context, ref),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text('Add Stock'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Inventory', style: AppTypography.headlineLg),
            Text(
              'Track feed, vaccines, medicine, and shed supplies without affecting the existing expense flows.',
              style: AppTypography.bodyMd
                  .copyWith(color: AppColors.onSurfaceVariant),
            ),
            const SizedBox(height: 24),
            inventoryAsync.when(
              data: (items) {
                if (items.isEmpty) {
                  return const Card(
                    child: Padding(
                      padding: EdgeInsets.all(20),
                      child: Text('No inventory items yet.'),
                    ),
                  );
                }
                return Column(
                  children: items
                      .map(
                        (item) => Card(
                          margin: const EdgeInsets.only(bottom: 12),
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: item.isLowStock
                                  ? AppColors.errorContainer
                                  : AppColors.surfaceContainerLow,
                              child: Icon(
                                _iconForCategory(item.category),
                                color: item.isLowStock
                                    ? AppColors.error
                                    : AppColors.primary,
                              ),
                            ),
                            title: Text(item.name),
                            subtitle: Text(
                              '${item.category.displayName} • ${item.quantity.toStringAsFixed(1)} ${item.unit}'
                              '${item.isLowStock ? ' • Low stock' : ''}',
                            ),
                            trailing: PopupMenuButton<String>(
                              onSelected: (value) {
                                _showAdjustDialog(
                                  context,
                                  ref,
                                  item,
                                  isRestock: value == 'restock',
                                );
                              },
                              itemBuilder: (context) => const [
                                PopupMenuItem(
                                  value: 'restock',
                                  child: Text('Restock'),
                                ),
                                PopupMenuItem(
                                  value: 'use',
                                  child: Text('Record Usage'),
                                ),
                              ],
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
                  child: Text('Error loading inventory: $e'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _iconForCategory(InventoryCategory category) {
    switch (category) {
      case InventoryCategory.feed:
        return Icons.grass_rounded;
      case InventoryCategory.vaccine:
        return Icons.vaccines_outlined;
      case InventoryCategory.medicine:
        return Icons.medication_outlined;
      case InventoryCategory.disinfectant:
        return Icons.cleaning_services_outlined;
      case InventoryCategory.litter:
        return Icons.layers_outlined;
      case InventoryCategory.other:
        return Icons.inventory_2_outlined;
    }
  }

  void _showAddItemDialog(BuildContext context, WidgetRef ref) {
    final farm = ref.read(currentFarmProvider);
    if (farm == null) {
      return;
    }
    final nameController = TextEditingController();
    final qtyController = TextEditingController();
    final unitController = TextEditingController(text: 'kg');
    final reorderController = TextEditingController(text: '25');
    InventoryCategory category = InventoryCategory.feed;
    String? selectedShedId;

    showDialog(
      context: context,
      builder: (dialogContext) => Consumer(
        builder: (context, localRef, _) {
          final shedsAsync = localRef.watch(shedListProvider);
          return AlertDialog(
            title: const Text('Add Inventory Item'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: nameController,
                    decoration: const InputDecoration(labelText: 'Item name'),
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<InventoryCategory>(
                    initialValue: category,
                    decoration: const InputDecoration(labelText: 'Category'),
                    items: InventoryCategory.values
                        .map(
                          (value) => DropdownMenuItem(
                            value: value,
                            child: Text(value.displayName),
                          ),
                        )
                        .toList(),
                    onChanged: (value) => category = value ?? category,
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: qtyController,
                    keyboardType: TextInputType.number,
                    decoration:
                        const InputDecoration(labelText: 'Opening quantity'),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: unitController,
                    decoration: const InputDecoration(labelText: 'Unit'),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: reorderController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'Reorder level'),
                  ),
                  const SizedBox(height: 12),
                  shedsAsync.when(
                    data: (sheds) => DropdownButtonFormField<String>(
                      initialValue: selectedShedId ?? '',
                      decoration: const InputDecoration(
                        labelText: 'Shed (optional)',
                      ),
                      items: [
                        const DropdownMenuItem<String>(
                          value: '',
                          child: Text('Farm-wide item'),
                        ),
                        ...sheds.map(
                          (shed) => DropdownMenuItem<String>(
                            value: shed.id,
                            child: Text(shed.name),
                          ),
                        ),
                      ],
                      onChanged: (value) =>
                          selectedShedId = (value?.isEmpty ?? true) ? null : value,
                    ),
                    loading: () => const SizedBox(),
                    error: (_, __) => const SizedBox(),
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
                  final quantity = double.tryParse(qtyController.text) ?? 0;
                  final reorderLevel =
                      double.tryParse(reorderController.text) ?? 0;
                  if (nameController.text.trim().isEmpty || quantity < 0) {
                    return;
                  }
                  final item = InventoryItemModel.create(
                    farmId: farm.id,
                    name: nameController.text.trim(),
                    category: category,
                    quantity: quantity,
                    unit: unitController.text.trim().isEmpty
                        ? 'unit'
                        : unitController.text.trim(),
                    reorderLevel: reorderLevel,
                    shedId: selectedShedId,
                  );
                  await ref.read(inventoryRepositoryProvider).create(item);
                  ref.invalidate(farmInventoryProvider);
                  ref.invalidate(lowStockItemsProvider);
                  ref.invalidate(dashboardSummaryProvider);
                  if (dialogContext.mounted) {
                    Navigator.pop(dialogContext);
                  }
                },
                child: const Text('Add'),
              ),
            ],
          );
        },
      ),
    );
  }

  void _showAdjustDialog(
    BuildContext context,
    WidgetRef ref,
    InventoryItemModel item, {
    required bool isRestock,
  }) {
    final qtyController = TextEditingController();
    final notesController = TextEditingController();
    final farm = ref.read(currentFarmProvider);
    if (farm == null) {
      return;
    }
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(isRestock ? 'Restock ${item.name}' : 'Record Usage'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: qtyController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(labelText: 'Quantity (${item.unit})'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: notesController,
              decoration: const InputDecoration(labelText: 'Notes'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final quantity = double.tryParse(qtyController.text) ?? 0;
              if (quantity <= 0) {
                return;
              }
              if (isRestock) {
                await ref.read(inventoryFlowServiceProvider).addStock(
                      itemId: item.id,
                      farmId: farm.id,
                      quantity: quantity,
                      unit: item.unit,
                      notes: notesController.text.trim(),
                    );
              } else {
                await ref.read(inventoryFlowServiceProvider).consumeStock(
                      itemId: item.id,
                      farmId: farm.id,
                      quantity: quantity,
                      unit: item.unit,
                      type: InventoryTransactionType.usage,
                      shedId: item.shedId,
                      notes: notesController.text.trim(),
                    );
              }
              ref.invalidate(farmInventoryProvider);
              ref.invalidate(lowStockItemsProvider);
              ref.invalidate(dashboardSummaryProvider);
              if (dialogContext.mounted) {
                Navigator.pop(dialogContext);
              }
            },
            child: Text(isRestock ? 'Restock' : 'Save'),
          ),
        ],
      ),
    );
  }
}
