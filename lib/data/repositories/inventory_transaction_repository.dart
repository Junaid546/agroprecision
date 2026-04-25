import '../../services/hive_service.dart';
import '../models/inventory_transaction_model.dart';

class InventoryTransactionRepository {
  Future<List<InventoryTransactionModel>> getByFarm(String farmId) async {
    return HiveService.inventoryTransactionBox.values
        .where((transaction) => transaction.farmId == farmId)
        .toList()
      ..sort((a, b) => b.date.compareTo(a.date));
  }

  Future<List<InventoryTransactionModel>> getByItem(String itemId) async {
    return HiveService.inventoryTransactionBox.values
        .where((transaction) => transaction.itemId == itemId)
        .toList()
      ..sort((a, b) => b.date.compareTo(a.date));
  }
}
