import '../../services/hive_service.dart';
import '../models/shed_model.dart';

class ShedRepository {
  Future<ShedModel> create(ShedModel shed) async {
    await HiveService.shedBox.put(shed.id, shed);
    return shed;
  }

  Future<List<ShedModel>> getByFarm(String farmId) async {
    return HiveService.shedBox.values.where((s) => s.farmId == farmId).toList()
      ..sort((a, b) => a.name.compareTo(b.name));
  }

  Future<ShedModel?> getById(String id) async {
    return HiveService.shedBox.get(id);
  }

  Future<ShedModel> update(ShedModel shed) async {
    await HiveService.shedBox.put(shed.id, shed);
    return shed;
  }

  Future<ShedModel> assignBatch(String shedId, String batchId) async {
    final shed = await getById(shedId);
    if (shed == null) throw Exception('Shed not found: $shedId');
    shed.activeBatchId = batchId;
    return await update(shed);
  }

  Future<ShedModel> clearBatch(String shedId) async {
    final shed = await getById(shedId);
    if (shed == null) throw Exception('Shed not found: $shedId');
    shed.activeBatchId = null;
    return await update(shed);
  }

  Future<void> delete(String id) async {
    await HiveService.shedBox.delete(id);
  }
}
