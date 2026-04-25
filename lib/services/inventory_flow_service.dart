import '../data/models/expense_model.dart';
import '../data/models/inventory_item_model.dart';
import '../data/models/inventory_transaction_model.dart';
import '../data/repositories/inventory_repository.dart';
import 'notification_service.dart';

class InventoryFlowService {
  final InventoryRepository inventoryRepository;

  InventoryFlowService({
    required this.inventoryRepository,
  });

  Future<void> consumeStock({
    required String itemId,
    required String farmId,
    required double quantity,
    required String unit,
    required InventoryTransactionType type,
    String? batchId,
    String? shedId,
    String? notes,
  }) async {
    final item = await inventoryRepository.getById(itemId);
    if (item == null) {
      throw Exception('Inventory item not found');
    }
    final transaction = InventoryTransactionModel.create(
      farmId: farmId,
      itemId: itemId,
      type: type,
      quantityChange: -quantity.abs(),
      unit: unit,
      date: DateTime.now(),
      batchId: batchId,
      shedId: shedId,
      notes: notes,
    );
    final updatedItem =
        await inventoryRepository.applyTransaction(item, transaction);
    if (updatedItem.isLowStock) {
      await NotificationService.showImmediateAlert(
        title: 'Low stock: ${updatedItem.name}',
        body:
            '${updatedItem.name} is at ${updatedItem.quantity.toStringAsFixed(1)} ${updatedItem.unit}.',
      );
    }
  }

  Future<void> addStock({
    required String itemId,
    required String farmId,
    required double quantity,
    required String unit,
    String? notes,
  }) async {
    final item = await inventoryRepository.getById(itemId);
    if (item == null) {
      throw Exception('Inventory item not found');
    }
    final transaction = InventoryTransactionModel.create(
      farmId: farmId,
      itemId: itemId,
      type: InventoryTransactionType.restock,
      quantityChange: quantity.abs(),
      unit: unit,
      date: DateTime.now(),
      notes: notes,
    );
    await inventoryRepository.applyTransaction(item, transaction);
  }

  Future<void> consumeFeedExpense(
    ExpenseModel expense, {
    String? shedId,
  }) async {
    if (expense.category != ExpenseCategory.feed ||
        expense.quantity == null ||
        expense.quantity! <= 0) {
      return;
    }
    final feedItems = await inventoryRepository.getByCategory(
      expense.farmId,
      InventoryCategory.feed,
    );
    if (feedItems.isEmpty) {
      return;
    }
    final matchingItem = shedId != null
        ? feedItems.firstWhere(
            (item) => item.shedId == shedId,
            orElse: () => feedItems.first,
          )
        : feedItems.first;
    await consumeStock(
      itemId: matchingItem.id,
      farmId: expense.farmId,
      quantity: expense.quantity!,
      unit: expense.unit ?? matchingItem.unit,
      type: InventoryTransactionType.usage,
      batchId: expense.batchId,
      shedId: shedId,
      notes: expense.description,
    );
  }
}
