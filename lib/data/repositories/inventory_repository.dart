import '../../services/hive_service.dart';
import '../models/inventory_item_model.dart';
import '../models/inventory_transaction_model.dart';

class InventoryRepository {
  Future<InventoryItemModel> create(InventoryItemModel item) async {
    await HiveService.inventoryBox.put(item.id, item);
    return item;
  }

  Future<InventoryItemModel> update(InventoryItemModel item) async {
    item.updatedAt = DateTime.now();
    await HiveService.inventoryBox.put(item.id, item);
    return item;
  }

  Future<List<InventoryItemModel>> getByFarm(String farmId) async {
    return HiveService.inventoryBox.values
        .where((item) => item.farmId == farmId && item.isActive)
        .toList()
      ..sort((a, b) => a.name.compareTo(b.name));
  }

  Future<List<InventoryItemModel>> getByCategory(
      String farmId, InventoryCategory category) async {
    final items = await getByFarm(farmId);
    return items.where((item) => item.category == category).toList();
  }

  Future<List<InventoryItemModel>> getLowStockItems(String farmId) async {
    final items = await getByFarm(farmId);
    return items.where((item) => item.isLowStock).toList();
  }

  Future<InventoryItemModel?> getById(String id) async {
    return HiveService.inventoryBox.get(id);
  }

  Future<InventoryItemModel> applyTransaction(
    InventoryItemModel item,
    InventoryTransactionModel transaction,
  ) async {
    item.quantity += transaction.quantityChange;
    item.updatedAt = DateTime.now();
    await HiveService.inventoryBox.put(item.id, item);
    await HiveService.inventoryTransactionBox.put(transaction.id, transaction);
    return item;
  }

  Future<void> delete(String id) async {
    await HiveService.inventoryBox.delete(id);
  }
}
