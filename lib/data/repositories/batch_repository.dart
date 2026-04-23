import 'package:flutter/material.dart';
import '../../services/hive_service.dart';
import '../models/batch_model.dart';

class BatchRepository {
  Future<BatchModel> create(BatchModel batch) async {
    await HiveService.batchBox.put(batch.id, batch);
    return batch;
  }

  Future<BatchModel?> getById(String id) async {
    return HiveService.batchBox.get(id);
  }

  Future<List<BatchModel>> getAll() async {
    return HiveService.batchBox.values.toList()
      ..sort((a, b) => b.startDate.compareTo(a.startDate));
  }

  Future<List<BatchModel>> getByFarm(String farmId) async {
    return HiveService.batchBox.values
        .where((b) => b.farmId == farmId)
        .toList()
      ..sort((a, b) => b.startDate.compareTo(a.startDate));
  }

  Future<List<BatchModel>> getActive() async {
    return HiveService.batchBox.values
        .where((b) => b.status == BatchStatus.active)
        .toList();
  }

  Future<BatchModel> update(BatchModel batch) async {
    batch.updatedAt = DateTime.now();
    await batch.save();
    return batch;
  }

  Future<void> delete(String id) async {
    await HiveService.batchBox.delete(id);
  }

  // Aggregated — used by dashboard
  Future<int> getCurrentAliveCount(String batchId) async {
    final batch = await getById(batchId);
    if (batch == null) return 0;
    
    final totalMortality = HiveService.getMortalityForBatch(batchId)
        .fold<int>(0, (sum, m) => sum + m.count);
        
    final soldCount = HiveService.saleBox.values
        .where((s) => s.batchId == batchId)
        .fold<int>(0, (sum, s) => sum + s.birdsSold);
        
    return batch.initialCount - totalMortality - soldCount;
  }
}
