import '../../services/hive_service.dart';
import '../models/sale_model.dart';

class SaleRepository {
  Future<SaleModel> create(SaleModel sale) async {
    await HiveService.saleBox.put(sale.id, sale);
    return sale;
  }

  Future<List<SaleModel>> getByBatch(String batchId) async {
    return HiveService.saleBox.values
        .where((s) => s.batchId == batchId)
        .toList()
      ..sort((a, b) => b.saleDate.compareTo(a.saleDate));
  }

  Future<double> getTotalRevenueForBatch(String batchId) async {
    return HiveService.saleBox.values
        .where((s) => s.batchId == batchId)
        .fold<double>(0.0, (sum, s) => sum + s.totalRevenue);
  }

  Future<int> getTotalSoldForBatch(String batchId) async {
    return HiveService.saleBox.values
        .where((s) => s.batchId == batchId)
        .fold<int>(0, (sum, s) => sum + s.birdsSold);
  }

  Future<void> delete(String id) async {
    await HiveService.saleBox.delete(id);
  }
}
