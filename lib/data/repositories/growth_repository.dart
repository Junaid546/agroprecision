import '../../services/hive_service.dart';
import '../models/growth_model.dart';

class GrowthChartPoint {
  final int day;
  final double weightKg;
  
  GrowthChartPoint({
    required this.day, 
    required this.weightKg,
  });
}

class GrowthRepository {
  Future<GrowthModel> create(GrowthModel record) async {
    await HiveService.growthBox.put(record.id, record);
    return record;
  }

  Future<List<GrowthModel>> getByBatch(String batchId) async {
    return HiveService.getGrowthForBatch(batchId);
  }

  Future<GrowthModel?> getLatest(String batchId) async {
    final logs = HiveService.getGrowthForBatch(batchId);
    return logs.isEmpty ? null : logs.last;
  }

  Future<List<GrowthChartPoint>> getChartData(String batchId) async {
    final logs = HiveService.getGrowthForBatch(batchId);
    return logs.map((g) => GrowthChartPoint(
      day: g.batchDay,
      weightKg: g.averageWeightKg,
    )).toList();
  }

  Future<void> delete(String id) async {
    await HiveService.growthBox.delete(id);
  }
}
